// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyABkRd1CWKmfHpCQSsZMrRFrjn_wcU8QUI',
    appId: '1:371704635186:web:8479b6e561fd221a2bc12b',
    messagingSenderId: '371704635186',
    projectId: 'dream-events-82cfc',
    authDomain: 'dream-events-82cfc.firebaseapp.com',
    storageBucket: 'dream-events-82cfc.appspot.com',
    measurementId: 'G-1X9B1GZM3B',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCYHAWGm3xWiBVQM5aKQ2K4xlGQO9S1nXg',
    appId: '1:371704635186:android:403a00abcc0f39f52bc12b',
    messagingSenderId: '371704635186',
    projectId: 'dream-events-82cfc',
    storageBucket: 'dream-events-82cfc.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChLL4mgJ0GTAa6IAQVh8PyTgvav6jcJEM',
    appId: '1:371704635186:ios:14f5ad8b502f88022bc12b',
    messagingSenderId: '371704635186',
    projectId: 'dream-events-82cfc',
    storageBucket: 'dream-events-82cfc.appspot.com',
    iosBundleId: 'com.example.maroro',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyChLL4mgJ0GTAa6IAQVh8PyTgvav6jcJEM',
    appId: '1:371704635186:ios:14f5ad8b502f88022bc12b',
    messagingSenderId: '371704635186',
    projectId: 'dream-events-82cfc',
    storageBucket: 'dream-events-82cfc.appspot.com',
    iosBundleId: 'com.example.maroro',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyABkRd1CWKmfHpCQSsZMrRFrjn_wcU8QUI',
    appId: '1:371704635186:web:16f7f821920c506a2bc12b',
    messagingSenderId: '371704635186',
    projectId: 'dream-events-82cfc',
    authDomain: 'dream-events-82cfc.firebaseapp.com',
    storageBucket: 'dream-events-82cfc.appspot.com',
    measurementId: 'G-M2XX8B4ZYD',
  );
}
