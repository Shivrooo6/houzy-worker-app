
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyDW-tyQ-IQsrNN-gHX3hLkkqa_3ONcIabQ",
      authDomain: "houzy-7f021.firebaseapp.com",
      projectId: "houzy-7f021",
      storageBucket: "houzy-7f021.firebasestorage.app",
      messagingSenderId: "507138808114",
      appId: "1:507138808114:web:24d5986619e2be25e99f2b",
      measurementId: "G-8G50XFERMH"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCUClhHsM74cT-yhlDEVdW8BRq6GYmFHEU',
    appId: '1:507138808114:web:24d5986619e2be25e99f2b',
    messagingSenderId: '507138808114',
    projectId: 'houzy-7f021',
    storageBucket: 'personalapp-6s41zz.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'xxx',
    appId: 'xxx',
    messagingSenderId: 'xxx',
    projectId: 'xxx',
    iosBundleId: 'xxx',
    iosClientId: 'xxx',
    storageBucket: 'xxx.appspot.com',
  );
}
