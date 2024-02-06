import 'dart:async';

import 'package:flutter/material.dart';
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
  List row4 = ["DELETE"];
  late final Timer tickTimer;

  // @override
  // void initState() {
  //   tickTimer = Timer(Duration(seconds: 1), () {
  //     int nowTick =
  //         Provider.of<LainGame>(context, listen: false).incrementTick();
  //     if (nowTick > 9) {
  //       Navigator.of(context).pushReplacementNamed("/FinalPageScreen");
  //       //Provider.of<LainGame>(context, listen: false).resetGame();
  //     }
  //   });
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   tickTimer.cancel();
  //   super.dispose();
  // }

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
            letter,
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
                      Text("SCORE: ",
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 242, 111, 121),
                                  fontWeight: FontWeight.w800)),
                      Text("6",
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(
                                  fontSize: 27,
                                  color: Color.fromARGB(255, 59, 65, 50),
                                  fontWeight: FontWeight.w600)),
                      Spacer(),
                      Text("HIGH SCORE: ",
                          style: Theme.of(context)
                              .textTheme
                              .headline1
                              ?.copyWith(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 242, 111, 121),
                                  fontWeight: FontWeight.w800)),
                      Text("600",
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
                crossAxisSpacing: 3, // Add vertical spacing between boxes
                mainAxisSpacing: 5,
                crossAxisCount: 8,
                shrinkWrap: true,
                childAspectRatio: 0.99,
                children: List.generate(80, (index) {
                  return gameRowCard("t");
                }),
              ),
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
                    children: row1.map((e) {
                      return GestureDetector(
                        onTap: () {},
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
                              "$e",
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
                    children: row2.map((e) {
                      return GestureDetector(
                        onTap: () {},
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
                              "$e",
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
                    children: row3.map((e) {
                      return GestureDetector(
                        onTap: () {},
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
                              "$e",
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
                    children: row4.map((e) {
                      return GestureDetector(
                        onTap: () {},
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
                              "$e",
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
