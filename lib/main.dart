import 'package:flutter/material.dart';
import 'controllers/game.dart';
import '../constants/settings.dart';
import '../constants/theme.dart';
import '../route_generator.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
      lazy: false,
      create: (BuildContext context) => LainGame(),
      child: SequenceApp()));
}

class SequenceApp extends StatefulWidget {
  const SequenceApp({super.key});
  @override
  State<SequenceApp> createState() => _SequenceAppState();
}

class _SequenceAppState extends State<SequenceApp> with WidgetsBindingObserver {
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
      title: 'Sequence',
      navigatorKey: Settings.navigatorKey,
      scaffoldMessengerKey: Settings.scaffoldMessengerKey,
      onGenerateRoute: RouteGenerator.onGenerateRoute,
      initialRoute: "/SplashScreen",
      theme: SequenceAppTheme.baseTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
