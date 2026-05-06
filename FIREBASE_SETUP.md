# Firebase Configuration Guide - GrowBuddy

## Quick Start

Ikuti langkah-langkah berikut untuk mengkonfigurasi Firebase project Anda dengan GrowBuddy.

---

## Step 1: Buat atau Pilih Firebase Project

1. Buka [Firebase Console](https://firebase.google.com/console)
2. Sign in dengan Google account Anda
3. Klik "Create Project" atau pilih project yang sudah ada
4. Nama project: `growbuddy` (atau nama pilihan Anda)
5. Pilih Realtime Database location: `asia-southeast1` (Indonesia) atau pilih region terdekat
6. Klik "Create Project"

---

## Step 2: Setup Realtime Database

1. Di Firebase Console, pilih project Anda
2. Buka menu **Build** > **Realtime Database**
3. Klik **Create Database**
4. Pilih lokasi: `asia-southeast1` (atau region pilihan Anda)
5. Mode: **Start in test mode** (untuk development; ubah ke production rules nanti)
6. Klik **Enable**

Database akan dibuat dengan URL seperti:
```
https://growbuddy-XXXXX-default-rtdb.asia-southeast1.firebasedatabase.app
```

**Catat URL ini!** Anda akan membutuhkannya di `firebase_options.dart`

---

## Step 3: Enable Anonymous Authentication

1. Di Firebase Console, buka **Build** > **Authentication**
2. Klik tab **Sign-in method**
3. Klik **Anonymous**
4. Toggle **Enable**
5. Klik **Save**

---

## Step 4: Copy Credentials untuk Web/Flutter

1. Di Firebase Console, klik **Project Settings** (gear icon di atas)
2. Scroll down ke bagian **Your apps**
3. Cari app dengan nama seperti `growbuddy (web)` atau platform lainnya
4. Jika belum ada, klik **Add app** dan pilih platform (Web / Android / iOS)

### Untuk Web:
```
Klik pada app Web Anda untuk melihat config:
apiKey
appId  
messagingSenderId
projectId
authDomain
```

---

## Step 5: Update firebase_options.dart

File yang perlu diupdate: `lib/firebase_options.dart`

Ganti nilai-nilai `YOUR_XXX_HERE` dengan credentials dari Firebase Console:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyDxxx...', // Dari Firebase Console
  appId: '1:123456789:web:abc123def456',
  messagingSenderId: '123456789',
  projectId: 'growbuddy-xxxxx',
  authDomain: 'growbuddy-xxxxx.firebaseapp.com',
  databaseURL: 'https://growbuddy-xxxxx-default-rtdb.asia-southeast1.firebasedatabase.app',
  storageBucket: 'growbuddy-xxxxx.appspot.com',
);
```

---

## Step 6: Setup untuk Android (Optional)

1. Di Firebase Console, **Add app** → Android
2. Package name: `com.example.growbuddy`
3. Download `google-services.json`
4. Letakkan di: `android/app/google-services.json`

---

## Step 7: Setup untuk iOS (Optional)

1. Di Firebase Console, **Add app** → iOS
2. iOS Bundle ID: `com.example.growbuddy`
3. Download `GoogleService-Info.plist`
4. Letakkan di: `ios/Runner/GoogleService-Info.plist`

---

## Step 8: Deploy Firebase Rules

1. Install Firebase CLI (jika belum):
   ```bash
   npm install -g firebase-tools
   ```

2. Login ke Firebase:
   ```bash
   firebase login
   ```

3. Di project root (`growbuddy/`), init Firebase project:
   ```bash
   firebase init
   ```
   - Pilih **Realtime Database** saat ditanya
   - Pilih project Anda
   - Gunakan file default `firebase.rules`

4. Deploy rules:
   ```bash
   firebase deploy --only database
   ```

---

## Step 9: Test Konfigurasi

### Run di Web:
```bash
cd growbuddy
flutter run -d chrome
```

Anda seharusnya melihat:
- Splash screen
- Device selection screen
- Home dashboard screen (setelah memasukkan device ID)

### Test Firebase Connection:
1. Buka home dashboard
2. Ketik device ID (contoh: `device_001`)
3. Tekan "Siram Sekarang"
4. Cek di Firebase Console → Realtime Database apakah data tertulis

---

## Troubleshooting

### Error: "api-key-not-valid"
- Pastikan `apiKey` di `firebase_options.dart` sudah benar
- Cek bahwa Web App sudah ditambahkan di Firebase Console

### Error: "Permission denied"
- Cek `firebase.rules` sudah benar
- Pastikan Anonymous Authentication sudah di-enable
- Deploy ulang rules: `firebase deploy --only database`

### Database tidak terlihat
- Pastikan Realtime Database sudah di-enable (bukan Firestore!)
- Cek URL database di Project Settings

---

## Struktur Database yang Diharapkan

```
growbuddy-xxxxx (Database)
├── users/
│   └── {uid}/
│       └── device_id: "device_001"
└── devices/
    └── device_001/
        ├── moisture: 65
        ├── status: "sehat"
        ├── online: true
        ├── last_update: 1704067200
        ├── control/
        │   └── siram: false
        ├── game/
        │   ├── score: 150
        │   └── level: 3
        └── history/
            └── {timestamp}/
                ├── before_moisture: 45
                └── after_moisture: 78
```

---

## Next: ESP32 Configuration

Setelah Firebase siap, update `esp32/SmartPlant_ESP32_REST.ino`:

```cpp
#define FIREBASE_HOST "growbuddy-xxxxx-default-rtdb.asia-southeast1.firebasedatabase.app"
#define DEVICE_ID "device_001"
```

---

## Support

Jika ada pertanyaan, cek:
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Firebase Plugin](https://firebase.flutter.dev)
