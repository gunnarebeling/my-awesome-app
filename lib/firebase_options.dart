// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBkkfQfA7At9J7Q2A-1brShO3r-UY4A9FM',
    appId: '1:548746061485:android:71905375df6e53cd450824',
    messagingSenderId: '548746061485',
    projectId: 'holonet-api-347016',
    storageBucket: 'holonet-api-347016.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBt2OOiTgL-xcfAYTG59R1C0b9EPzK_b54',
    appId: '1:548746061485:ios:2238ec2c37d3a2ad450824',
    messagingSenderId: '548746061485',
    projectId: 'holonet-api-347016',
    storageBucket: 'holonet-api-347016.firebasestorage.app',
    androidClientId: '548746061485-1ol5a496vq9ukn1ju5bn3810pd1e9699.apps.googleusercontent.com',
    iosClientId: '548746061485-cq1h6c0sfgcf2m52j983c4ekbv39998i.apps.googleusercontent.com',
    iosBundleId: 'dev.twinsun.MyAwesomeApp',
  );

}