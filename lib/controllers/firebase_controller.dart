import 'dart:io';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FirebaseController {
  static Future<void> initializeFirebaseApp() async {
    await Firebase.initializeApp(
        name: "Lain",
        options: FirebaseOptions(
            apiKey: Platform.isAndroid
                ? "AIzaSyCCIvNlfeUAimm6nHB3IyuxkwcULgtme"
                : "AIzaSyCa1diU5Dv_E5VS8lb7pD5y0mUA6elmPow",
            appId: Platform.isIOS
                ? "1:497802509816:ios:2a3b9cddcafb873c2a6a0d"
                : "1:497802509816:android:ad904f05188baec12a6a0d",
            messagingSenderId: "497802509816",
            projectId: "497802509816"));
  }

  static void initializeFirebaseCrashlytics() {
    /// Firebase Crashlytics
    FirebaseCrashlytics.instance.sendUnsentReports();
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static Future<Trace> createAndStartNewTrace(String traceName,
      {Map<String, String>? attributes}) async {
    Trace customTrace = FirebasePerformance.instance.newTrace(traceName);
    attributes?.forEach((key, value) => customTrace.putAttribute(key, value));
    await customTrace.start();

    return customTrace;
  }
}
