// firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Web config
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web config
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "",
    authDomain: "",
    projectId: "",
    storageBucket:"", // FIXED
    messagingSenderId: "",
    appId: "",
    measurementId: "",
  );

  // Android config
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_ANDROID_MESSAGING_SENDER_ID',
    projectId: ""',
    storageBucket: "", // FIXED
  );

  // iOS config
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_IOS_MESSAGING_SENDER_ID',
    projectId: 'business-world-bcc01',
    storageBucket: 'business-world-bcc01.appspot.com', // FIXED
    iosBundleId: 'YOUR_IOS_BUNDLE_ID',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
  );

  // macOS config
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MACOS_MESSAGING_SENDER_ID',
    projectId: 'business-world-bcc01',
    storageBucket: 'business-world-bcc01.appspot.com', // FIXED
    iosBundleId: 'YOUR_MACOS_BUNDLE_ID',
  );
}
