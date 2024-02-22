import 'package:flutter/material.dart';
import '../widgets/circle_loader.dart';

//import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});
  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    // simulated crash for firebase crashlytics to complete setup (to use once per platform)
    //FirebaseCrashlytics.instance.crash();

    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed("/StartScreen");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/background.png"),
                  fit: BoxFit.fill)),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "LAIN",
                        style: Theme.of(context).textTheme.headline1?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: width * 0.35,
                            color: const Color.fromARGB(255, 66, 71, 86),
                            letterSpacing: width / 80),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.1,
                    ),
                    CircleLoader(),
                    SizedBox(
                      height: height * 0.2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
