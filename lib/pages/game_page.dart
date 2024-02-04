import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/audio.dart';
import '../widgets/circle_loader.dart';

import '../controllers/game.dart';

class StartScreenPage extends StatefulWidget {
  const StartScreenPage({Key? key}) : super(key: key);

  @override
  State<StartScreenPage> createState() => _StartScreenPageState();
}

class _StartScreenPageState extends State<StartScreenPage> {
  List row1 = "QWERTYUIOP".split("");
  List row2 = "ASDFGHJKL".split("");
  List row3 = "ZXCVBNM".split("");
  List row4 = ["DELETE", "ENTER"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 202, 201, 1),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Row(
                  children: [
                    Text("SCORE: ",
                        style: Theme.of(context).textTheme.headline1?.copyWith(
                            fontSize: 25,
                            color: Color.fromARGB(255, 242, 111, 121),
                            fontWeight: FontWeight.w800)),
                    Text("6",
                        style: Theme.of(context).textTheme.headline1?.copyWith(
                            fontSize: 27,
                            color: Color.fromARGB(255, 59, 65, 50),
                            fontWeight: FontWeight.w600)),
                    Spacer(),
                    Text("HIGH SCORE: ",
                        style: Theme.of(context).textTheme.headline1?.copyWith(
                            fontSize: 20,
                            color: Color.fromARGB(255, 242, 111, 121),
                            fontWeight: FontWeight.w800)),
                    Text("600",
                        style: Theme.of(context).textTheme.headline1?.copyWith(
                            fontSize: 22,
                            color: Color.fromARGB(255, 59, 65, 50),
                            fontWeight: FontWeight.w600)),
                  ],
                )),
            Expanded(
              child: GridView.count(
                crossAxisSpacing: 0, // Add vertical spacing between boxes
                mainAxisSpacing: 0,
                crossAxisCount: 8,
                children: List.generate(80, (index) {
                  return Center(
                    child: Container(
                      alignment: Alignment.center,
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 253, 221, 220),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        " ",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 25,
                            color: Color.fromARGB(255, 242, 111, 121),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  );
                }),
              ),
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
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: row1.map((e) {
                        return InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: Column(
                              children: [
                                Container(
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
                                        color:
                                            Color.fromARGB(255, 242, 111, 121),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
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
                        return InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  height: 40,
                                  width: 37,
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 253, 221, 220),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(
                                    "$e",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 25,
                                        color:
                                            Color.fromARGB(255, 242, 111, 121),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
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
                        return InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  height: 40,
                                  width: 37,
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 253, 221, 220),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(
                                    "$e",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 25,
                                        color:
                                            Color.fromARGB(255, 242, 111, 121),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
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
                        return InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  height: 37,
                                  width: 150,
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 253, 221, 220),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(
                                    "$e",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 25,
                                        color:
                                            Color.fromARGB(255, 242, 111, 121),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void tutorialPressed() {}
}
