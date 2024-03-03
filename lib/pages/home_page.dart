// ignore_for_file: deprecated_member_use

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../controllers/firebase_controller.dart';
import '../controllers/game.dart';
import '../controllers/audio.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _difficultyRadioValue = 5; //5,6,8
  final List<String> rulesTextLines = [
    'The game begins with a random letter appearing in a green box followed by additional green boxes on the grid representing the number of letters in the word.',
    'The user must then guess a word that begins with the random letter and that also fulfills the letter count upon entering a correct word.',
    'The last letter subsequently becomes the first letter for the next iteration.',
    'The number of letters to guess also varies with every iteration.',
    'The game signals diminishing time by gradually sliding up the green box or the word up the grid from the bottom like this.',
    'When it reaches the top, the guessing time is over, the duration varies based on the number of letters in the word.'
  ];

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
                  key: Key("start_game_button"),
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

  void tutorialPressed() async {
    await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 70),
            backgroundColor: Color(0xfffcbcbb),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Column(
              children: [
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Color(0xfffceaea),
                            size:
                                30 * (MediaQuery.of(context).size.width / 428),
                          ),
                        ),
                        Text(
                          "  RULES",
                          style: TextStyle(
                              color: Color(0xfff26f79),
                              fontWeight: FontWeight.w600,
                              fontSize: 30 *
                                  (MediaQuery.of(context).size.width / 428)),
                        )
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 5,
                  child: Scrollbar(
                    thumbVisibility: true,
                    trackVisibility: true,
                    thickness: 6,
                    radius: Radius.circular(16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                      itemBuilder: (context, index) => ListTile(
                        horizontalTitleGap: 5,
                        titleAlignment: ListTileTitleAlignment.titleHeight,
                        leading: Icon(
                          Icons.cloud,
                          color: Color(0xfffceaea),
                          size: 21 * (MediaQuery.of(context).size.width / 428),
                        ),
                        title: Text(rulesTextLines[index],
                            style: TextStyle(
                                color: Color(0xfff26f79),
                                fontWeight: FontWeight.w600,
                                fontSize: 18 *
                                    (MediaQuery.of(context).size.width / 428))),
                      ),
                      itemCount: rulesTextLines.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
