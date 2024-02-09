import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game.dart';

class FinalPage extends StatelessWidget {
  FinalPage({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<LainGame>(context, listen: false).saveHighScore();

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Form(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.fromLTRB(10, height / 7, 10, 0),
                  child: Text("FINAL SCORE",
                      style: Theme.of(context).textTheme.headline1?.copyWith(
                          fontSize: width * 0.13,
                          color: Color.fromARGB(255, 242, 111, 121)))),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "${Provider.of<LainGame>(context, listen: false).currentScore}",
                  style: Theme.of(context).textTheme.headline1?.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: width * 0.3,
                      color: const Color.fromARGB(255, 66, 71, 86),
                      letterSpacing: width / 80),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, height / 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "HIGH SCORE: ",
                      style: Theme.of(context).textTheme.headline1?.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: width * 0.07,
                            color: const Color.fromARGB(255, 246, 170, 175),
                          ),
                    ),
                    Text(
                      "${Provider.of<LainGame>(context, listen: false).highScore}",
                      style: Theme.of(context).textTheme.headline1?.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: width * 0.07,
                            color: const Color.fromARGB(255, 145, 162, 113),
                          ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Provider.of<LainGame>(context, listen: false).resetGame();
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
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "PLAY AGAIN",
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
}
