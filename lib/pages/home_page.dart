// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:lain/controllers/firebase_controller.dart';
import 'package:provider/provider.dart';
import '../controllers/game.dart';
import '../controllers/audio.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _difficultyRadioValue = 5; //5,6,8

  @override
  void initState() {
    _difficultyRadioValue =
        Provider.of<LainGame>(context, listen: false).getGameMaxWordLength();
    AudioController.playGameStartSound();
    super.initState();
  }

  Widget difficultyRadioTile(int value, String displayText) => Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: RadioListTile<int>(
          contentPadding: EdgeInsets.only(
              left: 35 * (MediaQuery.of(context).size.width / 393)),
          dense: true,
          title: Text(
            displayText,
            style: Theme.of(context).textTheme.headline1?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 17 * (MediaQuery.of(context).size.width / 393),
                  color: const Color.fromARGB(255, 66, 71, 86),
                ),
          ),
          value: value,
          activeColor: Color.fromARGB(255, 145, 162, 113),
          hoverColor: Color.fromARGB(255, 145, 162, 113),
          groupValue: _difficultyRadioValue,
          onChanged: (int? valueInside) {
            setState(() {
              Provider.of<LainGame>(context, listen: false)
                  .setGameDifficulty(value);
              _difficultyRadioValue = value;
            });
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/background.png"),
                  fit: BoxFit.fill)),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10 * (height / 852)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RawMaterialButton(
                      onPressed: tutorialPressed,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(1),
                      fillColor: Color.fromARGB(255, 145, 162, 113),
                      child: Text(
                        "?",
                        style: Theme.of(context).textTheme.headline1?.copyWith(
                            fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ),
                    RawMaterialButton(
                        onPressed: () async {
                          await AudioController.toggleMute();
                          setState(() {});
                        },
                        shape: CircleBorder(),
                        fillColor: Color.fromARGB(255, 145, 162, 113),
                        child: Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: AudioController.isMuted.value
                              ? Icon(Icons.volume_off_rounded,
                                  size: 30, color: Colors.white)
                              : Icon(Icons.volume_up_rounded,
                                  size: 30, color: Colors.white),
                        )),
                  ],
                ),
                SizedBox(
                  height: 40 * (height / 852),
                ),
                Text(
                  "LAIN",
                  style: Theme.of(context).textTheme.headline1?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 140 * (width / 393),
                        color: const Color.fromARGB(255, 66, 71, 86),
                      ),
                ),
                SizedBox(
                  height: 5 * (height / 852),
                ),
                difficultyRadioTile(5, "Casual (3-5 letter words)"),
                difficultyRadioTile(6, "Challenging (3-6 letter words)"),
                difficultyRadioTile(8, "Complex (3-8 letter words)"),
                SizedBox(
                  height: 20 * (height / 852),
                ),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<LainGame>(context, listen: false)
                        .generateFirstGameRow();
                    // log game start event
                    FirebaseController.logEvent(
                        event: AnalyticsEvents.GAME_START,
                        params: {
                          "difficulty":
                              Provider.of<LainGame>(context, listen: false)
                                  .getGameDifficulty()
                                  .toLowerCase()
                        });

                    Navigator.of(context)
                        .pushReplacementNamed('/GameRoomScreen');
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll<Color>(
                          Color.fromARGB(255, 145, 162, 113)),
                      shape:
                          MaterialStatePropertyAll<ContinuousRectangleBorder>(
                              ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void tutorialPressed() {}
}
