import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// These values were extracted directly from:
///   - Android: android/app/src/dev/google-services.json  (dev flavor)
///              android/app/src/prod/google-services.json (prod flavor)
///   - iOS:     ios/Runner/GoogleService-Info.plist
///
/// DO NOT read Firebase credentials from .env files. Firebase SDKs require
/// these to be compile-time constants (or at least known at initialization).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Android – values from google-services.json (both dev and prod share the
  // same Firebase project "vihome-cf8ab" and the same app / API key).
  // ---------------------------------------------------------------------------
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCXmPAciqzyrVJCEE8mggNDchAHg5X4oV4',
    appId: '1:1018516867485:android:7078f67a92246e4067c774',
    messagingSenderId: '1018516867485',
    projectId: 'vihome-cf8ab',
    storageBucket: 'vihome-cf8ab.firebasestorage.app',
  );

  // ---------------------------------------------------------------------------
  // iOS – values from ios/Runner/GoogleService-Info.plist
  // ACTION REQUIRED: If the GoogleService-Info.plist is not yet added to
  // ios/Runner/, download it from the Firebase Console (Project Settings →
  // Your apps → iOS) and copy it there. Then replace the placeholder values
  // below with the actual ones from that file.
  // ---------------------------------------------------------------------------
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCXmPAciqzyrVJCEE8mggNDchAHg5X4oV4',
    appId: '1:1018516867485:ios:9e86a112f04d19ca67c774',
    messagingSenderId: '1018516867485',
    projectId: 'vihome-cf8ab',
    storageBucket: 'vihome-cf8ab.firebasestorage.app',
    iosBundleId: 'com.vihomeapp.vihomeapp',
  );
}
