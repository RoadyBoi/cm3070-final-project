import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/audio.dart';
import '../widgets/circle_loader.dart';

import '../controllers/game.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Form(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: RawMaterialButton(
                  onPressed: tutorialPressed,
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(1),
                  fillColor: Color.fromARGB(255, 145, 162, 113),
                  child: Text(
                    "?",
                    style: Theme.of(context).textTheme.headline1?.copyWith(
                        fontWeight: FontWeight.w500, color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, height / 8, 10, 0),
                child: Align(
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
              ),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed('/GameRoomScreen');
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll<Color>(
                          Color.fromARGB(255, 145, 162, 113)),
                      shape:
                          MaterialStatePropertyAll<ContinuousRectangleBorder>(
                              ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ))),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      "START",
                      style: Theme.of(context).textTheme.headline1?.copyWith(
                          fontSize: width * 0.12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void tutorialPressed() {}
}
