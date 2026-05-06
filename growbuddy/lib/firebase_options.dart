import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBzwUzzyXuLAP5Dxhk31wSz00bbT1RS6mY',
    appId: '1:1064950733261:web:03f446e5fa1ad448ea4c84',
    messagingSenderId: '1064950733261',
    projectId: 'grow-buddy-34262',
    authDomain: 'grow-buddy-34262.firebaseapp.com',
    databaseURL:
        'https://grow-buddy-34262-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'grow-buddy-34262.firebasestorage.app',
    measurementId: 'G-2MNZ23EMXS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBCmSZ64Fl-ni8QC-D1JOIYlykUNVp5XvU',
    appId: '1:1064950733261:android:512d9e9770fcb3c7ea4c84',
    messagingSenderId: '1064950733261',
    projectId: 'grow-buddy-34262',
    databaseURL:
        'https://grow-buddy-34262-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'grow-buddy-34262.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCYjGbsLydSHXoOiPo_kGyLTi1RUacChUk',
    appId: '1:1064950733261:ios:719c09d5f252fe87ea4c84',
    messagingSenderId: '1064950733261',
    projectId: 'grow-buddy-34262',
    databaseURL:
        'https://grow-buddy-34262-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'grow-buddy-34262.firebasestorage.app',
    iosBundleId: 'com.example.growbuddy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCYjGbsLydSHXoOiPo_kGyLTi1RUacChUk',
    appId: '1:1064950733261:ios:719c09d5f252fe87ea4c84',
    messagingSenderId: '1064950733261',
    projectId: 'grow-buddy-34262',
    databaseURL:
        'https://grow-buddy-34262-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'grow-buddy-34262.firebasestorage.app',
    iosBundleId: 'com.example.growbuddy',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDemo1234567890ABCDEFGHIJKLMNOPQR',
    appId: '1:123456789000:linux:abcdef1234567890',
    messagingSenderId: '123456789000',
    projectId: 'growbuddy-demo',
    databaseURL:
        'https://growbuddy-demo-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'growbuddy-demo.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBzwUzzyXuLAP5Dxhk31wSz00bbT1RS6mY',
    appId: '1:1064950733261:web:e033295fa69321dfea4c84',
    messagingSenderId: '1064950733261',
    projectId: 'grow-buddy-34262',
    authDomain: 'grow-buddy-34262.firebaseapp.com',
    databaseURL:
        'https://grow-buddy-34262-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'grow-buddy-34262.firebasestorage.app',
    measurementId: 'G-DGG67C4JL7',
  );
}
