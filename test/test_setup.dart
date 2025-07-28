import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MockFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'test-api-key',
    appId: 'test-app-id',
    messagingSenderId: 'test-sender-id',
    projectId: 'test-project-id',
  );
}

Future<void> setupFirebaseForTests() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Mock the method channel for Firebase
  const MethodChannel('plugins.flutter.io/firebase_core')
      .setMockMethodCallHandler((methodCall) async {
    if (methodCall.method == 'Firebase#initializeCore') {
      return [
        {
          'name': '[DEFAULT]',
          'options': {
            'apiKey': 'test-api-key',
            'appId': 'test-app-id',
            'messagingSenderId': 'test-sender-id',
            'projectId': 'test-project-id',
          },
          'pluginConstants': {},
        }
      ];
    }
    if (methodCall.method == 'Firebase#initializeApp') {
      return {
        'name': methodCall.arguments['appName'],
        'options': methodCall.arguments['options'],
        'pluginConstants': {},
      };
    }
    return null;
  });

  const MethodChannel('plugins.flutter.io/cloud_firestore')
      .setMockMethodCallHandler((methodCall) async {
    return null;
  });

  const MethodChannel('plugins.flutter.io/firebase_auth')
      .setMockMethodCallHandler((methodCall) async {
    return null;
  });

  await Firebase.initializeApp(
    options: MockFirebaseOptions.android,
  );
}