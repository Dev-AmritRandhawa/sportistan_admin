// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB3UX-i3zW0iDWnsaOLHDIN6CeE6IqTBEg',
    appId: '1:39436193342:android:680290f318be9d79e0cb6f',
    messagingSenderId: '39436193342',
    projectId: 'yoursportistan',
    storageBucket: 'yoursportistan.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBRr1EZfSgJavW_hfBYZWXh3EkGkPFmZCc',
    appId: '1:39436193342:ios:494f8cb4b01427c2e0cb6f',
    messagingSenderId: '39436193342',
    projectId: 'yoursportistan',
    storageBucket: 'yoursportistan.appspot.com',
    androidClientId: '39436193342-f51m9dcpa43bad00u02lu2ggr593nd89.apps.googleusercontent.com',
    iosClientId: '39436193342-h9pnv2qf1hm184mnu930hcqotujhjkut.apps.googleusercontent.com',
    iosBundleId: 'co.in.sportistan.sportistanAdmin',
  );
}
