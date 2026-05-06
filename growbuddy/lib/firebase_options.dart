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

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _required('FIREBASE_WEB_API_KEY'),
    appId: _required('FIREBASE_WEB_APP_ID'),
    messagingSenderId: _required('FIREBASE_WEB_MESSAGING_SENDER_ID'),
    projectId: _required('FIREBASE_WEB_PROJECT_ID'),
    authDomain: _required('FIREBASE_WEB_AUTH_DOMAIN'),
    databaseURL: _required('FIREBASE_WEB_DATABASE_URL'),
    storageBucket: _required('FIREBASE_WEB_STORAGE_BUCKET'),
    measurementId: _optional('FIREBASE_WEB_MEASUREMENT_ID'),
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _required('FIREBASE_ANDROID_API_KEY'),
    appId: _required('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: _required('FIREBASE_ANDROID_MESSAGING_SENDER_ID'),
    projectId: _required('FIREBASE_ANDROID_PROJECT_ID'),
    databaseURL: _required('FIREBASE_ANDROID_DATABASE_URL'),
    storageBucket: _required('FIREBASE_ANDROID_STORAGE_BUCKET'),
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _required('FIREBASE_IOS_API_KEY'),
    appId: _required('FIREBASE_IOS_APP_ID'),
    messagingSenderId: _required('FIREBASE_IOS_MESSAGING_SENDER_ID'),
    projectId: _required('FIREBASE_IOS_PROJECT_ID'),
    databaseURL: _required('FIREBASE_IOS_DATABASE_URL'),
    storageBucket: _required('FIREBASE_IOS_STORAGE_BUCKET'),
    iosBundleId: _required('FIREBASE_IOS_BUNDLE_ID'),
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: _required('FIREBASE_MACOS_API_KEY'),
    appId: _required('FIREBASE_MACOS_APP_ID'),
    messagingSenderId: _required('FIREBASE_MACOS_MESSAGING_SENDER_ID'),
    projectId: _required('FIREBASE_MACOS_PROJECT_ID'),
    databaseURL: _required('FIREBASE_MACOS_DATABASE_URL'),
    storageBucket: _required('FIREBASE_MACOS_STORAGE_BUCKET'),
    iosBundleId: _required('FIREBASE_MACOS_BUNDLE_ID'),
  );

  static FirebaseOptions get linux => FirebaseOptions(
    apiKey: _required('FIREBASE_LINUX_API_KEY'),
    appId: _required('FIREBASE_LINUX_APP_ID'),
    messagingSenderId: _required('FIREBASE_LINUX_MESSAGING_SENDER_ID'),
    projectId: _required('FIREBASE_LINUX_PROJECT_ID'),
    databaseURL: _required('FIREBASE_LINUX_DATABASE_URL'),
    storageBucket: _required('FIREBASE_LINUX_STORAGE_BUCKET'),
  );

  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: _required('FIREBASE_WINDOWS_API_KEY'),
    appId: _required('FIREBASE_WINDOWS_APP_ID'),
    messagingSenderId: _required('FIREBASE_WINDOWS_MESSAGING_SENDER_ID'),
    projectId: _required('FIREBASE_WINDOWS_PROJECT_ID'),
    authDomain: _required('FIREBASE_WINDOWS_AUTH_DOMAIN'),
    databaseURL: _required('FIREBASE_WINDOWS_DATABASE_URL'),
    storageBucket: _required('FIREBASE_WINDOWS_STORAGE_BUCKET'),
    measurementId: _optional('FIREBASE_WINDOWS_MEASUREMENT_ID'),
  );

  static String _required(String key) {
    const values = {
      'FIREBASE_WEB_API_KEY': String.fromEnvironment('FIREBASE_WEB_API_KEY'),
      'FIREBASE_WEB_APP_ID': String.fromEnvironment('FIREBASE_WEB_APP_ID'),
      'FIREBASE_WEB_MESSAGING_SENDER_ID': String.fromEnvironment(
        'FIREBASE_WEB_MESSAGING_SENDER_ID',
      ),
      'FIREBASE_WEB_PROJECT_ID': String.fromEnvironment(
        'FIREBASE_WEB_PROJECT_ID',
      ),
      'FIREBASE_WEB_AUTH_DOMAIN': String.fromEnvironment(
        'FIREBASE_WEB_AUTH_DOMAIN',
      ),
      'FIREBASE_WEB_DATABASE_URL': String.fromEnvironment(
        'FIREBASE_WEB_DATABASE_URL',
      ),
      'FIREBASE_WEB_STORAGE_BUCKET': String.fromEnvironment(
        'FIREBASE_WEB_STORAGE_BUCKET',
      ),
      'FIREBASE_WEB_MEASUREMENT_ID': String.fromEnvironment(
        'FIREBASE_WEB_MEASUREMENT_ID',
      ),
      'FIREBASE_ANDROID_API_KEY': String.fromEnvironment(
        'FIREBASE_ANDROID_API_KEY',
      ),
      'FIREBASE_ANDROID_APP_ID': String.fromEnvironment(
        'FIREBASE_ANDROID_APP_ID',
      ),
      'FIREBASE_ANDROID_MESSAGING_SENDER_ID': String.fromEnvironment(
        'FIREBASE_ANDROID_MESSAGING_SENDER_ID',
      ),
      'FIREBASE_ANDROID_PROJECT_ID': String.fromEnvironment(
        'FIREBASE_ANDROID_PROJECT_ID',
      ),
      'FIREBASE_ANDROID_DATABASE_URL': String.fromEnvironment(
        'FIREBASE_ANDROID_DATABASE_URL',
      ),
      'FIREBASE_ANDROID_STORAGE_BUCKET': String.fromEnvironment(
        'FIREBASE_ANDROID_STORAGE_BUCKET',
      ),
      'FIREBASE_IOS_API_KEY': String.fromEnvironment('FIREBASE_IOS_API_KEY'),
      'FIREBASE_IOS_APP_ID': String.fromEnvironment('FIREBASE_IOS_APP_ID'),
      'FIREBASE_IOS_MESSAGING_SENDER_ID': String.fromEnvironment(
        'FIREBASE_IOS_MESSAGING_SENDER_ID',
      ),
      'FIREBASE_IOS_PROJECT_ID': String.fromEnvironment(
        'FIREBASE_IOS_PROJECT_ID',
      ),
      'FIREBASE_IOS_DATABASE_URL': String.fromEnvironment(
        'FIREBASE_IOS_DATABASE_URL',
      ),
      'FIREBASE_IOS_STORAGE_BUCKET': String.fromEnvironment(
        'FIREBASE_IOS_STORAGE_BUCKET',
      ),
      'FIREBASE_IOS_BUNDLE_ID': String.fromEnvironment(
        'FIREBASE_IOS_BUNDLE_ID',
      ),
      'FIREBASE_MACOS_API_KEY': String.fromEnvironment(
        'FIREBASE_MACOS_API_KEY',
      ),
      'FIREBASE_MACOS_APP_ID': String.fromEnvironment('FIREBASE_MACOS_APP_ID'),
      'FIREBASE_MACOS_MESSAGING_SENDER_ID': String.fromEnvironment(
        'FIREBASE_MACOS_MESSAGING_SENDER_ID',
      ),
      'FIREBASE_MACOS_PROJECT_ID': String.fromEnvironment(
        'FIREBASE_MACOS_PROJECT_ID',
      ),
      'FIREBASE_MACOS_DATABASE_URL': String.fromEnvironment(
        'FIREBASE_MACOS_DATABASE_URL',
      ),
      'FIREBASE_MACOS_STORAGE_BUCKET': String.fromEnvironment(
        'FIREBASE_MACOS_STORAGE_BUCKET',
      ),
      'FIREBASE_MACOS_BUNDLE_ID': String.fromEnvironment(
        'FIREBASE_MACOS_BUNDLE_ID',
      ),
      'FIREBASE_LINUX_API_KEY': String.fromEnvironment(
        'FIREBASE_LINUX_API_KEY',
      ),
      'FIREBASE_LINUX_APP_ID': String.fromEnvironment('FIREBASE_LINUX_APP_ID'),
      'FIREBASE_LINUX_MESSAGING_SENDER_ID': String.fromEnvironment(
        'FIREBASE_LINUX_MESSAGING_SENDER_ID',
      ),
      'FIREBASE_LINUX_PROJECT_ID': String.fromEnvironment(
        'FIREBASE_LINUX_PROJECT_ID',
      ),
      'FIREBASE_LINUX_DATABASE_URL': String.fromEnvironment(
        'FIREBASE_LINUX_DATABASE_URL',
      ),
      'FIREBASE_LINUX_STORAGE_BUCKET': String.fromEnvironment(
        'FIREBASE_LINUX_STORAGE_BUCKET',
      ),
      'FIREBASE_WINDOWS_API_KEY': String.fromEnvironment(
        'FIREBASE_WINDOWS_API_KEY',
      ),
      'FIREBASE_WINDOWS_APP_ID': String.fromEnvironment(
        'FIREBASE_WINDOWS_APP_ID',
      ),
      'FIREBASE_WINDOWS_MESSAGING_SENDER_ID': String.fromEnvironment(
        'FIREBASE_WINDOWS_MESSAGING_SENDER_ID',
      ),
      'FIREBASE_WINDOWS_PROJECT_ID': String.fromEnvironment(
        'FIREBASE_WINDOWS_PROJECT_ID',
      ),
      'FIREBASE_WINDOWS_AUTH_DOMAIN': String.fromEnvironment(
        'FIREBASE_WINDOWS_AUTH_DOMAIN',
      ),
      'FIREBASE_WINDOWS_DATABASE_URL': String.fromEnvironment(
        'FIREBASE_WINDOWS_DATABASE_URL',
      ),
      'FIREBASE_WINDOWS_STORAGE_BUCKET': String.fromEnvironment(
        'FIREBASE_WINDOWS_STORAGE_BUCKET',
      ),
      'FIREBASE_WINDOWS_MEASUREMENT_ID': String.fromEnvironment(
        'FIREBASE_WINDOWS_MEASUREMENT_ID',
      ),
    };

    final value = values[key] ?? '';
    if (value.isEmpty) {
      throw UnsupportedError(
        'Missing Firebase configuration: $key. Run Flutter with --dart-define-from-file=.env.',
      );
    }
    return value;
  }

  static String? _optional(String key) {
    const values = {
      'FIREBASE_WEB_MEASUREMENT_ID': String.fromEnvironment(
        'FIREBASE_WEB_MEASUREMENT_ID',
      ),
      'FIREBASE_WINDOWS_MEASUREMENT_ID': String.fromEnvironment(
        'FIREBASE_WINDOWS_MEASUREMENT_ID',
      ),
    };

    final value = values[key] ?? '';
    return value.isEmpty ? null : value;
  }
}
