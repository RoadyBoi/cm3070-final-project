import 'package:flutter/material.dart';
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
        Provider.of<LainGame>(context, listen: false).intGetGameMaxWordLength();
    AudioController.playGameStartSound();
    super.initState();
  }

  Widget difficultyRadioTile(int value, String displayText) => Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: RadioListTile<int>(
          contentPadding: EdgeInsets.only(left: 30),
          dense: true,
          title: Text(
            displayText,
            style: Theme.of(context).textTheme.headline1?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: const Color.fromARGB(255, 66, 71, 86),
                ),
          ),
          value: value,
          activeColor: Color.fromARGB(255, 145, 162, 113),
          hoverColor: Color.fromARGB(255, 145, 162, 113),
          groupValue: _difficultyRadioValue,
          onChanged: (int? valueInside) {
            Provider.of<LainGame>(context, listen: false)
                .setGameDifficulty(value);
            setState(() {
              _difficultyRadioValue = value;
            });
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.fill)),
        child: SafeArea(
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
                        fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, height / 12, 10, 0),
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
              difficultyRadioTile(5, "Casual (3-5 letter words)"),
              difficultyRadioTile(6, "Challenging (3-6 letter words)"),
              difficultyRadioTile(8, "Complex (3-8 letter words)"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Align(
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
