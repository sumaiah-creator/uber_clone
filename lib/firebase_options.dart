// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyC92lzPMzFifW8-Nf8V5o3g3VOv3Y6PoN8',
    appId: '1:714715224762:web:d4653be62005b23f89c083',
    messagingSenderId: '714715224762',
    projectId: 'uber-clone-3eb83',
    authDomain: 'uber-clone-3eb83.firebaseapp.com',
    storageBucket: 'uber-clone-3eb83.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCsFIatCX98fxNnJ0b8OZuxTEAM6CLxhdc',
    appId: '1:714715224762:android:9fc6623ebac8867b89c083',
    messagingSenderId: '714715224762',
    projectId: 'uber-clone-3eb83',
    storageBucket: 'uber-clone-3eb83.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCrNskur2tEpuhmLZ_xo0d9C4dQfWycY0o',
    appId: '1:714715224762:ios:b5cfd73ea739625f89c083',
    messagingSenderId: '714715224762',
    projectId: 'uber-clone-3eb83',
    storageBucket: 'uber-clone-3eb83.appspot.com',
    iosBundleId: 'com.example.uberClone',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCrNskur2tEpuhmLZ_xo0d9C4dQfWycY0o',
    appId: '1:714715224762:ios:b5cfd73ea739625f89c083',
    messagingSenderId: '714715224762',
    projectId: 'uber-clone-3eb83',
    storageBucket: 'uber-clone-3eb83.appspot.com',
    iosBundleId: 'com.example.uberClone',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC92lzPMzFifW8-Nf8V5o3g3VOv3Y6PoN8',
    appId: '1:714715224762:web:7966feae463382dc89c083',
    messagingSenderId: '714715224762',
    projectId: 'uber-clone-3eb83',
    authDomain: 'uber-clone-3eb83.firebaseapp.com',
    storageBucket: 'uber-clone-3eb83.appspot.com',
  );
}
