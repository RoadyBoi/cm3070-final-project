// From the repository https://github.com/firebase/flutterfire
// analytics mock code: https://github.com/firebase/flutterfire/blob/master/packages/firebase_analytics/firebase_analytics/test/mock.dart
// crashlytics mock code: https://github.com/firebase/flutterfire/blob/master/packages/firebase_crashlytics/firebase_crashlytics/test/mock.dart

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_crashlytics_platform_interface/firebase_crashlytics_platform_interface.dart';
import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';

typedef Callback = void Function(MethodCall call);
final List<MethodCall> methodCallLog = <MethodCall>[];

void setupFirebaseCrashlyticsMocks([Callback? customHandlers]) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(MethodChannelFirebaseCrashlytics.channel,
          (MethodCall methodCall) async {
    methodCallLog.add(methodCall);
    switch (methodCall.method) {
      case 'Crashlytics#checkForUnsentReports':
        return {
          'unsentReports': true,
        };
      case 'Crashlytics#setCrashlyticsCollectionEnabled':
        return {
          'isCrashlyticsCollectionEnabled': methodCall.arguments['enabled']
        };
      case 'Crashlytics#didCrashOnPreviousExecution':
        return {
          'didCrashOnPreviousExecution': true,
        };
      case 'Crashlytics#recordError':
        return null;
      default:
        return false;
    }
  });
}

void setupFirebaseAnalyticsMocks([Callback? customHandlers]) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(MethodChannelFirebaseAnalytics.channel,
          (MethodCall methodCall) async {
    methodCallLog.add(methodCall);
    switch (methodCall.method) {
      case 'Analytics#getAppInstanceId':
        return 'ABCD1234';

      default:
        return false;
    }
  });
}
