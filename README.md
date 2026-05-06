Smart Plant Watering Game — Integration README

Overview
- ESP32 -> Firebase Realtime Database -> Flutter app (mobile)
- Device id pairing via `users/{uid}/device_id`

Quick setup

1) Firebase
- Create a Firebase project and enable Realtime Database (native mode).
- Add Android/iOS apps and download `google-services.json` / `GoogleService-Info.plist` into `growbuddy/android/app/` and `growbuddy/ios/Runner/` respectively.
- Set Realtime Database rules (for dev use): upload `growbuddy/firebase.rules` or paste into Console > Realtime Database > Rules.

2) Flutter app
- From workspace root:
```bash
cd growbuddy
flutter pub get
flutter run
```
- The app signs in anonymously on startup. Enter your device id (e.g., `device_001`) when prompted.

3) ESP32 (Arduino sketch)
- File: `esp32/SmartPlant_ESP32_REST.ino`
- Edit the top constants: `WIFI_SSID`, `WIFI_PASSWORD`, `DB_URL` (your RTDB base URL, e.g. `https://project-id-default-rtdb.firebaseio.com`), and `DEVICE_ID`.
- Install ArduinoJson and necessary libraries in Arduino IDE.
- Upload sketch to ESP32 via Arduino IDE or PlatformIO.

Commands to monitor
- Check DB updates in Firebase Console under `/devices/{device_id}`
- When app writes `devices/{device_id}/control/siram = true`, ESP32 will detect, run pump, reset flag, and update `/devices/{device_id}/moisture` and `/devices/{device_id}/last_update`.

Safety & notes
- For production, tighten RTDB rules to limit writes to control paths by authenticated users and devices.
- ESP32 uses REST polling in this demo; for lower latency use the Firebase streaming API or WebSockets client libraries.
- Adjust ADC calibration mapping in `esp32/SmartPlant_ESP32_REST.ino` to match your soil sensor.

Integration checklist (short)
- [ ] Configure Firebase project + Database + rules
- [ ] Add Android/iOS app config files to Flutter project
- [ ] Update ESP32 constants and flash device
- [ ] Pair device_id in Flutter app and verify real-time updates
- [ ] Test 'Siram' flow end-to-end and verify cooldown

If you want, I can: add PlatformIO project for the ESP32, or convert additional HTML pages into Flutter screens.
