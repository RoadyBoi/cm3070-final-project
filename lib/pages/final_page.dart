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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(10, height / 7, 10, 0),
                    child: Text("FINAL SCORE",
                        style: Theme.of(context).textTheme.headline1?.copyWith(
                            fontSize: 45 * (width / 393),
                            color: Color.fromARGB(255, 242, 111, 121)))),
                Text(
                  "${Provider.of<LainGame>(context, listen: false).currentScore}",
                  style: Theme.of(context).textTheme.headline1?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: width * 0.3,
                        color: const Color.fromARGB(255, 66, 71, 86),
                      ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, height / 17),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "HIGH SCORE: ",
                        style: Theme.of(context).textTheme.headline1?.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 25 * (width / 393),
                              color: Color.fromARGB(255, 66, 71, 86),
                            ),
                      ),
                      Text(
                        "${Provider.of<LainGame>(context, listen: false).highScore}",
                        style: Theme.of(context).textTheme.headline1?.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: width * 0.07,
                              color: const Color.fromARGB(255, 242, 111, 121),
                            ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<LainGame>(context, listen: false).resetGame();
                    Navigator.of(context).pushReplacementNamed('/StartScreen');
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
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "PLAY AGAIN",
                      style: Theme.of(context).textTheme.headline1?.copyWith(
                          fontSize: width * 0.1,
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
}
