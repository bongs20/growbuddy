# GrowBuddy

GrowBuddy adalah aplikasi Flutter untuk smart plant watering game yang terhubung ke Firebase Authentication dan Realtime Database.

## Firebase yang sudah dipakai

- Project ID: `grow-buddy-34262`
- Realtime Database:
  `https://grow-buddy-34262-default-rtdb.asia-southeast1.firebasedatabase.app/`
- Auth: Anonymous Sign-In
- Flutter config: `DefaultFirebaseOptions.currentPlatform`

## Flow aplikasi

Saat aplikasi dibuka:

1. Firebase diinisialisasi dari `lib/firebase_options.dart`
2. User login anonymous otomatis
3. App membaca `users/{uid}/device_id`
4. Jika belum ada device, user diminta input Device ID
5. Dashboard membaca data dari `devices/{deviceId}`

## Struktur Realtime Database

```text
users/{uid}/device_id
devices/{deviceId}/moisture
devices/{deviceId}/status
devices/{deviceId}/online
devices/{deviceId}/last_update
devices/{deviceId}/control/siram
devices/{deviceId}/game/score
devices/{deviceId}/game/level
devices/{deviceId}/history
```

Saat tombol `Siram Sekarang` ditekan, app akan:

- menulis `devices/{deviceId}/control/siram = true`
- menulis `devices/{deviceId}/control/requested_at`
- menulis `devices/{deviceId}/control/requested_by`
- menambah history baru di `devices/{deviceId}/history`

## File penting

- `lib/main.dart`
- `lib/firebase_options.dart`
- `lib/services/firebase_service.dart`
- `lib/screens/device_selection.dart`
- `lib/screens/home_dashboard.dart`
- `lib/screens/history_screen.dart`
- `lib/screens/settings_screen.dart`
- `database.rules.json`
- `firebase.seed.device_001.json`

## Seed data contoh

File contoh data ada di `firebase.seed.device_001.json`.

Contoh device testing:

- Device ID: `device_001`
- Moisture: `42`
- Status: `idle`
- Online: `true`
- Score: `120`
- Level: `3`

Sebelum memakai seed ini, ganti:

- `replace_with_anonymous_uid`

dengan UID anonymous user dari aplikasi Anda.

## Deploy rules Firebase

Project ini sudah mengarah ke file rules berikut:

- `database.rules.json`
- `firebase.json` sudah berisi `"database": { "rules": "database.rules.json" }`

Command deploy:

```bash
firebase deploy --only database --project grow-buddy-34262
```

## Menjalankan app

```bash
flutter pub get
flutter run
```

## Catatan implementasi

- App tidak meminta web credentials manual lagi.
- Inisialisasi Firebase menggunakan `DefaultFirebaseOptions.currentPlatform`.
- Device bisa di-unlink dari settings, lalu app kembali ke screen input Device ID.
- `control/siram` saat ini di-set ke `true` oleh app. Reset kembali ke `false` sebaiknya dilakukan oleh device/ESP32 setelah proses penyiraman selesai.
