import 'package:flutter/material.dart';
import 'package:lain/controllers/audio.dart';
import 'package:lain/controllers/firebase_controller.dart';
import 'package:provider/provider.dart';

import '../controllers/game.dart';
import '../constants/settings.dart';
import '../constants/theme.dart';
import '../route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LainGame.populateIndexedWordMap();
  await FirebaseController.initializeFirebaseApp();
  FirebaseController.initializeFirebaseCrashlytics();
  FirebaseController.setAnalyticsAppVersion();

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
      // await Provider.of<LainGame>(context, listen: false)
      //     .populateIndexedWordMap();
      await Provider.of<LainGame>(context, listen: false).readHighScores();
      await AudioController.readMuteStatus();
    } else {
      await AudioController.saveMuteStatus();
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
