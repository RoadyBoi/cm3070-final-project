import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lain/controllers/audio.dart';
import 'package:lain/controllers/firebase_controller.dart';
import 'package:provider/provider.dart';
import '../controllers/game.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  final List row1 = "qwertyuiop".split("");
  final List row2 = "asdfghjkl".split("");
  final List row3 = "zxcvbnm".split("");
  final List row4 = ["1"];

  late final Timer tickTimer;
  late List<Widget> gameCards;

  @override
  void initState() {
    // ticker (0-9 secornds)
    tickTimer = Timer.periodic(Duration(seconds: 1), (thisTimer) async {
      // increment and get current tick
      int nowTick =
          await Provider.of<LainGame>(context, listen: false).incrementTick();
      // if game time is up
      if (nowTick > 9) {
        // close existing toasts
        await Fluttertoast.cancel();
        // show toast for time up
        Fluttertoast.showToast(
            msg: "Time up",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        // log game over event
        FirebaseController.logEvent(event: AnalyticsEvents.GAME_END, params: {
          "difficulty": Provider.of<LainGame>(context, listen: false)
              .getGameDifficulty()
              .toLowerCase()
        });
        // play time up sound
        AudioController.playGameOverSound();
        // cancel ticker
        thisTimer.cancel();
        Navigator.of(context).pushReplacementNamed("/FinalPageScreen");
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    tickTimer.cancel();
    super.dispose();
  }

  Widget fillerRowCard() => Container(
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 253, 221, 220),
            borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            "",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24,
                color: Color.fromARGB(255, 242, 111, 121),
                fontWeight: FontWeight.w600),
          ),
        ),
      );

  Widget gameRowCard(String letter) => Container(
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 145, 162, 113),
            borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            letter.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );

  Widget keyboardCard(String letter) => GestureDetector(
      onTap: () async {
        await Provider.of<LainGame>(context, listen: false).userInput(letter);
        HapticFeedback.lightImpact();
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2),
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height * (40 / 820),
        width: MediaQuery.of(context).size.width *
            (letter == "1" ? 150 : 36) /
            411,
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 253, 221, 220),
            borderRadius: BorderRadius.circular(8)),
        child: Text(
          letter == "1" ? "DELETE" : letter.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 25,
              color: Color.fromARGB(255, 242, 111, 121),
              fontWeight: FontWeight.w600),
        ),
      ));

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Color.fromRGBO(250, 202, 201, 1),
        body: Consumer<LainGame>(builder: (context, lainGameState, child) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Row(
                      children: [
                        Text("SCORE  ",
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                ?.copyWith(
                                    fontSize: 22,
                                    color: Color.fromARGB(255, 242, 111, 121),
                                    fontWeight: FontWeight.w800)),
                        Text("${lainGameState.currentScore}",
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                ?.copyWith(
                                    fontSize: 22,
                                    color: Color.fromARGB(255, 59, 65, 50),
                                    fontWeight: FontWeight.w600)),
                        Spacer(),
                        Text("HIGH SCORE  ",
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                ?.copyWith(
                                    fontSize: 22,
                                    color: Color.fromARGB(255, 242, 111, 121),
                                    fontWeight: FontWeight.w800)),
                        Text("${lainGameState.getHighScore()}",
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                ?.copyWith(
                                    fontSize: 22,
                                    color: Color.fromARGB(255, 59, 65, 50),
                                    fontWeight: FontWeight.w600)),
                      ],
                    )),
                GridView.count(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    crossAxisSpacing: 5, // Add horizontal spacing between boxes
                    mainAxisSpacing: 5,
                    crossAxisCount: 8,
                    shrinkWrap: true,
                    childAspectRatio: 0.97,
                    children:
                        lainGameState.flattenedGameGrid().map<Widget>((value) {
                      if (value == "")
                        return fillerRowCard();
                      else
                        return gameRowCard(value);
                    }).toList()),
              ],
            ),
          );
        }),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //Start from here for grid
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        row1.map((letter) => keyboardCard(letter)).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        row2.map((letter) => keyboardCard(letter)).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        row3.map((letter) => keyboardCard(letter)).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        row4.map((letter) => keyboardCard(letter)).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void tutorialPressed() {}
}
