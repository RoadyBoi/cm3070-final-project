import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../controllers/game.dart';
import '../constants/settings.dart';
import '../constants/theme.dart';
import '../route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  /// Firebase Craslytics
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(ChangeNotifierProvider(
      lazy: false,
      create: (BuildContext context) => LainGame(),
      child: LainApp()));
}

class LainApp extends StatefulWidget {
  const LainApp({super.key});
  @override
  State<LainApp> createState() => _LainAppState();
}

class _LainAppState extends State<LainApp> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      Provider.of<LainGame>(context, listen: false).populateIndexedWordMap();
      Provider.of<LainGame>(context, listen: false).readHighScore();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LAIN',
      navigatorKey: Settings.navigatorKey,
      scaffoldMessengerKey: Settings.scaffoldMessengerKey,
      onGenerateRoute: RouteGenerator.onGenerateRoute,
      initialRoute: "/SplashScreen",
      theme: LainAppTheme.baseTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
