# GrowBuddy Firebase Configuration Checklist

Ikuti checklist ini untuk mengkonfigurasi Firebase dengan cepat.

## ✅ Checklist Setup

### 1. Firebase Project Setup
- [✅ ] Buka https://firebase.google.com/console
- [✅ ] Buat project baru atau gunakan yang sudah ada
- [ ✅] Nama: `growbuddy` (atau pilihan Anda)
- [ ✅] Pilih region: `asia-southeast1` (Indonesia)

### 2. Realtime Database
- [✅ ] Aktifkan **Realtime Database** di Build menu
- [✅ ] Mode: **Test mode** (untuk development)
- [✅ ] Catat URL database: `https://grow-buddy-34262-default-rtdb.asia-southeast1.firebasedatabase.app/`

### 3. Authentication
- [✅ ] Buka **Authentication** di Build menu
- [ ✅] Aktifkan **Anonymous** sign-in method

### 4. Get Credentials
- [ ] Buka **Project Settings** (gear icon)
- [ ] Scroll ke **Your apps**
- [ ] Klik app **Web** (jika belum ada, buat baru)
- [ ] Copy credentials:
  - apiKey
  - appId
  - messagingSenderId
  - projectId
  - authDomain
  - databaseURL
  - storageBucket

### 5. Update Firebase Config File
- [ ] Edit: `lib/firebase_options.dart`
- [ ] Update semua `YOUR_XXX_HERE` dengan credentials dari Firebase Console
- [ ] Pastikan `databaseURL` benar (harus RTDB, bukan Firestore)

### 6. Deploy Security Rules (Optional - untuk production)
```bash
npm install -g firebase-tools
firebase login
cd growbuddy
firebase deploy --only database
```

### 7. Test Configuration
```bash
flutter run -d chrome
```

- [ ] Splash screen muncul
- [ ] Device selection screen muncul
- [ ] Bisa input Device ID
- [ ] Home dashboard muncul
- [ ] Tombol "Siram Sekarang" responsif

### 8. Verify Firebase Connection
1. Di app, input device ID: `device_001`
2. Klik "Siram Sekarang"
3. Buka Firebase Console → Realtime Database
4. Cek apakah struktur data muncul di `devices/device_001`

---

## 📋 Expected Database Structure

Setelah app berjalan, Anda seharusnya melihat struktur seperti ini:

```
growbuddy-xxxxx/
├── users/
│   └── {random-uid}/
│       └── device_id: "device_001"
└── devices/
    └── device_001/
        ├── moisture: 45
        ├── status: "sehat"
        ├── online: true
        ├── last_update: 1704067200
        ├── control/
        │   └── siram: false
        ├── game/
        │   ├── score: 0
        │   └── level: 1
        └── history/ (akan bertambah saat menyiram)
```

---

## 🆘 Troubleshooting

### Problem: "api-key-not-valid"
**Solution:**
1. Cek credentials di `firebase_options.dart` sudah benar
2. Pastikan Web App sudah ditambahkan di Firebase Console
3. Copy ulang dari Project Settings

### Problem: "Permission denied" saat baca/tulis database
**Solution:**
1. Cek `firebase.rules` sudah di-deploy
2. Pastikan Anonymous authentication sudah enabled
3. Test dengan mode "Public (test mode)" dulu

### Problem: Database tidak appear di Realtime Database
**Solution:**
1. Cek apakah Anda menggunakan **Realtime Database** (bukan Firestore!)
2. Di Project Settings, cek URL database berakhir dengan `.firebasedatabase.app`

### Problem: Credentials not found errors
**Solution:**
1. Pastikan file `lib/firebase_options.dart` sudah ada
2. Cek import di `lib/main.dart`: `import 'firebase_options.dart';`
3. Flutter analyze harus tanpa error

---

## 📱 Setup untuk Android & iOS (Optional)

### Android Setup
1. Di Firebase Console, **Add app** → Android
2. Package name: `com.example.growbuddy`
3. SHA-1 (opsional untuk test)
4. Download `google-services.json`
5. Letakkan di: `android/app/google-services.json`

### iOS Setup
1. Di Firebase Console, **Add app** → iOS
2. Bundle ID: `com.example.growbuddy`
3. Download `GoogleService-Info.plist`
4. Di Xcode, add file ke `ios/Runner/`

---

## 🔐 Security Rules untuk Production

Sebelum production, ubah `firebase.rules` dengan:

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "devices": {
      "$device_id": {
        ".read": "auth != null && root.child('users').child(auth.uid).child('device_id').val() === $device_id",
        ".write": "auth != null && root.child('users').child(auth.uid).child('device_id').val() === $device_id"
      }
    }
  }
}
```

Deploy:
```bash
firebase deploy --only database
```

---

## 📚 Resources

- [Firebase Console](https://firebase.google.com/console)
- [Firebase Docs](https://firebase.google.com/docs)
- [Flutter Firebase](https://firebase.flutter.dev)
- [Realtime Database Security Rules](https://firebase.google.com/docs/database/security)

---

## ✨ Next Steps

Setelah Firebase siap:
1. Setup ESP32: Update `SmartPlant_ESP32_REST.ino` dengan Firebase URL
2. Deploy ke production
3. Configure proper security rules
4. Setup monitoring dan alerts
