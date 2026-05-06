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
const unsigned long CONTROL_POLL_INTERVAL_MS = 500;
const unsigned long WATER_COOLDOWN_MS = 3000;
const unsigned long HEARTBEAT_INTERVAL_MS = 15000;

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

unsigned long currentUnixMillis() {
  time_t now = time(nullptr);
  if (now <= 1000) return 0;
  return static_cast<unsigned long>(now) * 1000UL;
}

// ======================
// SENSOR
// ======================
int readSoilPercent() {
  int raw = analogRead(SOIL_PIN);
  int pct = map(raw, SOIL_RAW_DRY, SOIL_RAW_WET, 0, 100);
  return constrain(pct, 0, 100);
}

String moistureLabelFromPct(int pct) {
  if (pct < 25) return "critical_dry";
  if (pct < 40) return "dry";
  if (pct <= 70) return "healthy";
  if (pct <= 85) return "wet";
  return "overwatered";
}

void updateDeviceState(int moisture, const String& status) {
  String base = "/devices/" + String(DEVICE_ID);
  unsigned long nowMs = currentUnixMillis();

  httpPut(buildUrl(base + "/moisture"), String(moisture));
  httpPut(buildUrl(base + "/status"), "\"" + status + "\"");
  httpPut(buildUrl(base + "/online"), "true");
  if (nowMs > 0) {
    httpPut(buildUrl(base + "/last_update"), String(nowMs));
  }
}

void sendHeartbeat() {
  String base = "/devices/" + String(DEVICE_ID);
  unsigned long nowMs = currentUnixMillis();

  httpPut(buildUrl(base + "/online"), "true");
  if (nowMs > 0) {
    httpPut(buildUrl(base + "/last_update"), String(nowMs));
  }
  httpPut(buildUrl(base + "/fw_version"), "\"esp32-rest-3.0.0\"");
  httpPut(buildUrl(base + "/wifi_ssid"), "\"" + String(WIFI_SSID) + "\"");
}

// ======================
// POMPA
// ======================
void startPump(unsigned long durationMs) {
  digitalWrite(PUMP_PIN, HIGH);
  pumpActive = true;
  pumpStart = millis();
  pumpDuration = durationMs;
  Serial.println("Pompa ON");

  int moisture = readSoilPercent();
  updateDeviceState(moisture, "watering");
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
          continue;
        }

        // cooldown biar tidak spam
        if (millis() - lastWateredMs > WATER_COOLDOWN_MS) {

          int durasi = doc["duration_seconds"] | 3;

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
