import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sequence/controllers/game_copy.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  List row1 = "QWERTYUIOP".split("");
  List row2 = "ASDFGHJKL".split("");
  List row3 = "ZXCVBNM".split("");
  List row4 = ["1"];
  late final Timer tickTimer;
  late List<Widget> gameCards;

  @override
  void initState() {
    tickTimer = Timer.periodic(Duration(seconds: 1), (thisTimer) {
      int nowTick =
          Provider.of<LainGame>(context, listen: false).incrementTick();
      setState(() {});
      if (nowTick > 9) {
        Fluttertoast.showToast(
            msg: "Time up",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
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

  @override
  Widget build(BuildContext context) {
    return Consumer<LainGame>(builder: (context, lainGameState, child) {
      return Scaffold(
        backgroundColor: Color.fromRGBO(250, 202, 201, 1),
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Row(
                    children: [
                      Text("SCORE ",
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
                      Text("HIGH SCORE ",
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 242, 111, 121),
                                  fontWeight: FontWeight.w800)),
                      Text("${lainGameState.highScore}",
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 59, 65, 50),
                                  fontWeight: FontWeight.w600)),
                    ],
                  )),
              GridView.count(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  crossAxisSpacing: 3, // Add vertical spacing between boxes
                  mainAxisSpacing: 5,
                  crossAxisCount: 8,
                  shrinkWrap: true,
                  childAspectRatio: 0.99,
                  children:
                      lainGameState.flattenedGameGrid().map<Widget>((value) {
                    if (value == "")
                      return fillerRowCard();
                    else
                      return gameRowCard(value);
                  }).toList()),
            ],
          ),
        ),
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
                    children: row1.map((letter) {
                      return GestureDetector(
                        onTap: () {
                          lainGameState.userInput(letter);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Container(
                            alignment: Alignment.center,
                            height: 40,
                            width: 37,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 253, 221, 220),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              "$letter",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 242, 111, 121),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row2.map((letter) {
                      return GestureDetector(
                        onTap: () {
                          lainGameState.userInput(letter);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            alignment: Alignment.center,
                            height: 40,
                            width: 37,
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 253, 221, 220),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              "$letter",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 242, 111, 121),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row3.map((letter) {
                      return GestureDetector(
                        onTap: () {
                          lainGameState.userInput(letter);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            alignment: Alignment.center,
                            height: 40,
                            width: 37,
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 253, 221, 220),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              "$letter",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 242, 111, 121),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row4.map((letter) {
                      return GestureDetector(
                        onTap: () {
                          lainGameState.userInput(letter);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Container(
                            alignment: Alignment.center,
                            height: 37,
                            width: 150,
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 253, 221, 220),
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              "${letter == "1" ? "Delete" : letter}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 242, 111, 121),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void tutorialPressed() {}
}
