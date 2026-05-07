#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <time.h>

// ======================
// PIN
// ======================
#define SOIL_PIN 34
#define PUMP_PIN 26

// ======================
// WIFI & FIREBASE
// ======================
const char* WIFI_SSID = "Redmi-15";
const char* WIFI_PASSWORD = "11111111";
const char* DB_URL = "https://grow-buddy-34262-default-rtdb.asia-southeast1.firebasedatabase.app";
const char* DEVICE_ID = "device_001";

// ======================
// TIMING (DI-OPTIMASI)
// ======================
const unsigned long SAMPLE_INTERVAL_MS = 10000;
const unsigned long CONTROL_POLL_INTERVAL_MS = 1000;
const unsigned long WATER_COOLDOWN_MS = 5000;
const unsigned long HEARTBEAT_INTERVAL_MS = 10000;
const unsigned long CONFIG_FETCH_INTERVAL_MS = 30000;

// ======================
// SENSOR
// ======================
const int SOIL_RAW_DRY = 3200;
const int SOIL_RAW_WET = 1400;

// ======================
// POMPA NON-BLOCKING
// ======================
bool pumpActive = false;
unsigned long pumpStart = 0;
unsigned long pumpDuration = 0;

// ======================
unsigned long lastSampleMs = 0;
unsigned long lastControlPollMs = 0;
unsigned long lastWateredMs = 0;
unsigned long lastHeartbeatMs = 0;
unsigned long lastConfigFetchMs = 0;
int pumpDurationSeconds = 3; // Default, will be updated from Firebase
int calibrationOffset = 0; // Default offset

// ======================
// STRUCT
// ======================
struct WaterCommand {
  bool siram;
  int durationSeconds;
};

// ======================
// WIFI
// ======================
void connectWiFi() {
  if (WiFi.status() == WL_CONNECTED) return;

  WiFi.mode(WIFI_STA);
  WiFi.disconnect(true); // Bersihkan sisa memori WiFi
  delay(100);
  
  // Turunkan sedikit daya pancar WiFi (TX Power) untuk mencegah 
  // lonjakan listrik (Brownout) saat dicolok ke powerbank / daya eksternal.
  // Nilai standar adalah WIFI_POWER_19_5dBm, kita turunkan ke 8.5dBm
  WiFi.setTxPower(WIFI_POWER_8_5dBm);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting WiFi");

  unsigned long start = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - start < 12000UL) {
    delay(500);
    Serial.print(".");
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nConnected!");
  } else {
    Serial.println("\nWiFi connect timeout");
  }
}

// ======================
// HTTP
// ======================
String buildUrl(String path) {
  return String(DB_URL) + path + ".json";
}

String httpGet(String url) {
  if (WiFi.status() != WL_CONNECTED) return "";

  HTTPClient http;
  http.begin(url);
  int code = http.GET();

  String payload = "";
  if (code == 200) payload = http.getString();

  http.end();
  return payload;
}

void httpPut(String url, String data) {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  http.PUT(data);
  http.end();
}

void httpPatch(String url, String data) {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  http.PATCH(data);
  http.end();
}

uint64_t currentUnixMillis() {
  time_t now = time(nullptr);
  if (now <= 1000) return 0;
  return static_cast<uint64_t>(now) * 1000ULL;
}

void fetchConfig() {
  Serial.println("Fetching config from Firebase...");
  String urlSettings = buildUrl("/devices/" + String(DEVICE_ID) + "/settings");
  String payloadSettings = httpGet(urlSettings);
  
  if (payloadSettings.length() > 0 && payloadSettings != "null") {
    DynamicJsonDocument doc(512);
    DeserializationError err = deserializeJson(doc, payloadSettings);
    if (!err) {
      pumpDurationSeconds = doc["pump_duration_seconds"] | pumpDurationSeconds;
      Serial.print("Config Updated! Pump Duration: ");
      Serial.print(pumpDurationSeconds);
      Serial.println("s");
    }
  }

  String urlCal = buildUrl("/devices/" + String(DEVICE_ID) + "/calibration");
  String payloadCal = httpGet(urlCal);
  if (payloadCal.length() > 0 && payloadCal != "null") {
    DynamicJsonDocument doc(512);
    DeserializationError err = deserializeJson(doc, payloadCal);
    if (!err) {
      calibrationOffset = doc["offset_percent"] | calibrationOffset;
      Serial.print("Config Updated! Calibration Offset: ");
      Serial.println(calibrationOffset);
    }
  }
}

// ======================
// SENSOR
// ======================
int readSoilPercent() {
  int raw = analogRead(SOIL_PIN);
  if (raw < 100 || raw > 4000) {
    return -1; // Sensor error / disconnected
  }
  int pct = map(raw, SOIL_RAW_DRY, SOIL_RAW_WET, 0, 100);
  pct += calibrationOffset;
  return constrain(pct, 0, 100);
}

String moistureLabelFromPct(int pct) {
  if (pct == -1) return "sensor_error";
  if (pct < 25) return "critical_dry";
  if (pct < 40) return "dry";
  if (pct <= 70) return "healthy";
  if (pct <= 85) return "wet";
  return "overwatered";
}

void updateDeviceState(int moisture, const String& status) {
  String base = "/devices/" + String(DEVICE_ID);
  uint64_t nowMs = currentUnixMillis();

  StaticJsonDocument<256> doc;
  doc["moisture"] = moisture == -1 ? 0 : moisture;
  doc["status"] = status;
  doc["online"] = true;
  if (nowMs > 0) {
    doc["last_update"] = nowMs;
  }

  String json;
  serializeJson(doc, json);
  httpPatch(buildUrl(base), json);
}

void sendHeartbeat() {
  String base = "/devices/" + String(DEVICE_ID);
  uint64_t nowMs = currentUnixMillis();

  StaticJsonDocument<256> doc;
  doc["online"] = true;
  if (nowMs > 0) {
    doc["last_update"] = nowMs;
  }
  doc["fw_version"] = "esp32-rest-3.1.0";
  doc["wifi_ssid"] = String(WIFI_SSID);

  String json;
  serializeJson(doc, json);
  httpPatch(buildUrl(base), json);
}

// ======================
// POMPA
// ======================
void startPump(unsigned long durationMs) {
  digitalWrite(PUMP_PIN, HIGH);
  pumpActive = true;
  pumpStart = millis();
  pumpDuration = durationMs;
  Serial.print("Pompa ON selama ");
  Serial.print(durationMs / 1000);
  Serial.println(" detik");

  int moisture = readSoilPercent();
  updateDeviceState(moisture, moisture == -1 ? "sensor_error" : "watering");
}

// ======================
// SETUP
// ======================
void setup() {
  Serial.begin(115200);

  pinMode(SOIL_PIN, INPUT);
  pinMode(PUMP_PIN, OUTPUT);
  digitalWrite(PUMP_PIN, LOW);

  connectWiFi();
  configTime(0, 0, "pool.ntp.org", "time.google.com");

  // Tunggu sampai waktu sinkron
  Serial.print("Menunggu sinkronisasi waktu NTP");
  time_t now = time(nullptr);
  int ntp_timeout = 0;
  while (now < 24 * 3600 && ntp_timeout < 20) {
    delay(500);
    Serial.print(".");
    now = time(nullptr);
    ntp_timeout++;
  }
  if (now > 24 * 3600) {
    Serial.println("\nWaktu tersinkron!");
  } else {
    Serial.println("\nGagal sinkron waktu, beberapa fitur timestamp mungkin tidak akurat.");
  }
  
  fetchConfig(); // Ambil konfigurasi dari Firebase
  lastConfigFetchMs = millis();

  int moisture = readSoilPercent();
  updateDeviceState(moisture, moistureLabelFromPct(moisture));
  sendHeartbeat();
}

// ======================
// LOOP
// ======================
void loop() {

  if (WiFi.status() != WL_CONNECTED) {
    connectWiFi();
    delay(250);
    return;
  }

  // ======================
  // HANDLE POMPA (NON BLOCKING)
  // ======================
  if (pumpActive && millis() - pumpStart >= pumpDuration) {
    digitalWrite(PUMP_PIN, LOW);
    pumpActive = false;
    Serial.println("Pompa OFF");

    int afterMoisture = readSoilPercent();
    updateDeviceState(afterMoisture, moistureLabelFromPct(afterMoisture));
  }

  // ======================
  // KIRIM DATA SENSOR
  // ======================
  if (millis() - lastSampleMs > SAMPLE_INTERVAL_MS) {
    lastSampleMs = millis();

    int moisture = readSoilPercent();
    String status = moistureLabelFromPct(moisture);
    Serial.print("Moisture: ");
    Serial.println(moisture);

    updateDeviceState(moisture, status);
  }

  // ======================
  // HEARTBEAT PERIODIK
  // ======================
  if (millis() - lastHeartbeatMs > HEARTBEAT_INTERVAL_MS) {
    lastHeartbeatMs = millis();
    sendHeartbeat();
  }

  // ======================
  // FETCH CONFIG PERIODIK
  // ======================
  if (millis() - lastConfigFetchMs > CONFIG_FETCH_INTERVAL_MS) {
    lastConfigFetchMs = millis();
    fetchConfig();
  }

  // ======================
  // CEK PERINTAH SIRAM
  // ======================
  if (millis() - lastControlPollMs > CONTROL_POLL_INTERVAL_MS) {
    lastControlPollMs = millis();

    String payload = httpGet(buildUrl("/devices/" + String(DEVICE_ID) + "/control"));

    if (payload.length() > 0) {
      DynamicJsonDocument doc(256);
      DeserializationError err = deserializeJson(doc, payload);
      if (err) {
        Serial.println("Control JSON parse error");
      }

      bool siram = err ? false : (doc["siram"] | false);

      if (siram) {

        if (pumpActive) {
          return;
        }

        // cooldown biar tidak spam
        if (millis() - lastWateredMs > WATER_COOLDOWN_MS) {

          int durasi = doc["duration_seconds"] | pumpDurationSeconds;

          // reset ke false
          httpPut(buildUrl("/devices/" + String(DEVICE_ID) + "/control/siram"), "false");

          startPump(durasi * 1000UL);
          lastWateredMs = millis();
        }
      }
    }
  }

  delay(20);
}
