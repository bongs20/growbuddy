# GrowBuddy Firebase - Quick Start Card

## 5-Minute Setup Guide

### Step 1: Create Firebase Project
```
1. Go to https://firebase.google.com/console
2. Create Project → Name: "growbuddy"
3. Region: "asia-southeast1"
```

### Step 2: Enable Services
```
✓ Realtime Database (Build > Realtime Database > Create)
✓ Anonymous Auth (Build > Authentication > Enable)
```

### Step 3: Copy Credentials
```
Project Settings > Your apps > Web
Copy these values:
- apiKey
- appId
- messagingSenderId
- projectId
- authDomain
- databaseURL
- storageBucket
```

### Step 4: Fill firebase_options.dart
Edit: `lib/firebase_options.dart`

Replace `YOUR_XXX_HERE` with actual values from Firebase Console

Example:
```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyD...',  // Your apiKey
  appId: '1:123456789:web:abc123',
  messagingSenderId: '123456789',
  projectId: 'growbuddy-abc123',
  authDomain: 'growbuddy-abc123.firebaseapp.com',
  databaseURL: 'https://growbuddy-abc123-default-rtdb.asia-southeast1.firebasedatabase.app',
  storageBucket: 'growbuddy-abc123.appspot.com',
);
```

### Step 5: Test
```bash
flutter run -d chrome
```

---

## File Locations

| File | Purpose |
|------|---------|
| `lib/firebase_options.dart` | Firebase credentials (EDIT THIS) |
| `firebase.rules` | Database security rules |
| `lib/main.dart` | Firebase initialization |
| `lib/services/firebase_service.dart` | Firebase API calls |

---

## Error Fixes

| Error | Fix |
|-------|-----|
| `api-key-not-valid` | Check apiKey in firebase_options.dart |
| `Permission denied` | Enable Anonymous Auth in Firebase Console |
| No database | Use **Realtime Database**, not Firestore |

---

## Database URL Format

✅ Correct (Realtime Database):
```
https://growbuddy-abc123-default-rtdb.asia-southeast1.firebasedatabase.app
```

❌ Wrong (Firestore):
```
https://firestore.googleapis.com/...
```

---

## Testing Connection

1. Run app: `flutter run -d chrome`
2. Input Device ID: `device_001`
3. Click "Siram Sekarang"
4. Go to Firebase Console > Realtime Database
5. Should see `devices/device_001` with data

---

## Docs
- Firebase: https://firebase.google.com
- Flutter Firebase: https://firebase.flutter.dev
- Full guide: See `FIREBASE_SETUP.md`
