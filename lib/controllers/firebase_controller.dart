import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AnalyticsEvents {
  static const String GAME_START = "game_start",
      GAME_END = "game_end",
      INVALID_WORD = "invalid_word_played",
      WORD_PLAYED = "word_played";
}

class PerformanceCustomTraces {
  static const String VALIDATE_WORD = 'validateWord',
      INCREMENT_TICK = "incrementTick",
      GENERATE_NEXT_GAME_ROW = "generateNextGameRow",
      USER_INPUT = "userInput";
}

class FirebaseController {
  static Future<void> initializeFirebaseApp(
      {bool collectionEnabled = true}) async {
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
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(collectionEnabled);
    await FirebasePerformance.instance
        .setPerformanceCollectionEnabled(collectionEnabled);
    await FirebaseAnalytics.instance
        .setAnalyticsCollectionEnabled(collectionEnabled);
  }

  /// Firebase Crashlytics`
  static void initializeFirebaseCrashlytics() {
    FirebaseCrashlytics.instance.sendUnsentReports();
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Firebase Performance Monitoring
  static Future<Trace?> createAndStartNewTrace(String traceName,
      {Map<String, String>? attributes}) async {
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      Trace customTrace = FirebasePerformance.instance.newTrace(traceName);
      attributes?.forEach((key, value) => customTrace.putAttribute(key, value));
      await customTrace.start();
      return customTrace;
    }
    return null;
  }

  /// Firebase Analytics
  static Future logEvent({
    required String event,
    Map<String, String>? params,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: event,
      parameters: params,
    );
  }

  static Future<void> setAnalyticsAppVersion() async {
    String version = await PackageInfo.fromPlatform()
        .then<String>((packageInfo) => packageInfo.version);
    await FirebaseAnalytics.instance
        .setDefaultEventParameters({'version': version});
  }
}
