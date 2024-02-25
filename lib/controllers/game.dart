import 'dart:math';
import 'dart:convert';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lain/controllers/audio.dart';
import 'package:lain/controllers/firebase_controller.dart';
import '../constants/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

// SharedPrefs keys for high score in app cache
const String highScoreCasualPrefsKey = "LAINHighScoreCasualPrefsKey",
    highScoreCompetitivePrefsKey = "LAINHighScoreCompetitivePrefsKey",
    highScoreComplexPrefsKey = "LAINHighScoreComplexPrefsKey";
// lowercase letter list
final List<String> letterList =
    List.generate(26, (index) => String.fromCharCode(index + 97));

// indexed word dictionary maps to be used for word checking
late final Map indexedWordMap5LetterDictionary,
    indexedWordMap6LetterDictionary,
    indexedWordMap8LetterDictionary;

/// LainGame class is built on the Provider, a state management framework,
/// to implement the game logic. LainGame is ChangeNotifier class
/// that is provided to the root widget of the app using and changes to
/// LainGame class members update the Consumer widgets that apply listeners
/// using the function notifyListeners()
class LainGame extends ChangeNotifier {
  // game grid (8 x 10)
  List<List<String>> currentGameGrid =
      List.generate(10, (index) => List.generate(8, (index) => ""));
  // pointer in the grid for the active game row
  int currentGameRowPointer = 9;
  // current word length (3 - maxGameWordLength)
  int currentRandomGameRowLength = 0;
  // according to difficulty level (5 = casual, 6 = challenging, 8 = complex)
  int maxGameWordLength = 8;
  // game word current letter pointer
  int currentActiveLetterPositionPointer = 1;
  // score
  int currentScore = 0;
  // list of played words
  List<String> playedWords = [];
  // ticker (10 seconds)
  int currentTick = 0; //0-9
  // dictionary filled from json map of words
  Map indexedWordMapDictionary = {};
  // high scores based on game difficulty
  int highScoreCasual = 0, highScoreCompetitive = 0, highScoreComplex = 0;

  LainGame() {
    populateIndexedWordMap().then((_) {
      selectIndexedWordMapBasedOnDifficulty();
    });
    readHighScores();
  }

  // get random letter from letter list for first game row
  String getFirstLetter() => letterList[Random().nextInt(26)];

  // calculate random length of the word to play next
  void calculateRandomGameRowLength() {
    currentRandomGameRowLength =
        Random().nextInt((maxGameWordLength + 1) - 3) + 3;
    Helper.debugPrint(
        "CurrentRandomGameRowLength: $currentRandomGameRowLength");
  }

  // set game difficulty
  // difficulty level (5 = casual, 6 = challenging, 8 = complex)
  void setGameDifficulty(int difficultyLevel) {
    maxGameWordLength = difficultyLevel;
    selectIndexedWordMapBasedOnDifficulty();
  }

  int getGameMaxWordLength() => maxGameWordLength;

  String getGameDifficulty() {
    switch (maxGameWordLength) {
      case 5:
        return "Casual";
      case 6:
        return "Challenging";
      case 8:
        return "Competitive";
      default:
        throw RangeError(
            "maxGameWordLength is currently set to $maxGameWordLength"
            "which is not in valid range [5,6,8]");
    }
  }

  // create first game row with random first letter and random length
  // first row will be the last row in the grid [9] so that rows
  // move bottom to top
  void generateFirstGameRow() {
    // clear first game row
    currentGameGrid.last = List.generate(8, (index) => "");
    currentGameGrid[9][0] = getFirstLetter();
    calculateRandomGameRowLength();
    // keeping spaces " " indicates game row box, "" indicates filler box
    for (int i = 1; i < currentRandomGameRowLength; i++) {
      currentGameGrid[9][i] = " ";
    }
    // set the active letter pointer to the second letter
    currentActiveLetterPositionPointer = 1;
    // set current active game row to the last
    currentGameRowPointer = 9;
    // send update to UI (Consumers)
    notifyListeners();
  }

  // create next active game row
  Future<void> generateNextGameRow(String lastGameWordLetter) async {
    Trace performanceTrace = await FirebaseController.createAndStartNewTrace(
        PerformanceCustomTraces.GENERATE_NEXT_GAME_ROW,
        attributes: {'difficulty': getGameDifficulty()});

    // remove the top row of the grid
    currentGameGrid.removeAt(0);
    // create new row as game row with first letter as last game word letter
    List<String> newRow = [lastGameWordLetter];
    // calculate random length of new game row
    calculateRandomGameRowLength();
    // add game boxes and filler boxes to the game row
    for (int i = 1; i < 8; i++) {
      if (i < currentRandomGameRowLength)
        newRow.add(" ");
      else
        newRow.add("");
    }
    // add the created game row to end of grid
    currentGameGrid.add(newRow);
    // set current active game row to the last
    currentGameRowPointer = 9;
    // set the active letter pointer to the second letter
    currentActiveLetterPositionPointer = 1;
    // reset tick
    currentTick = 0;
    // send update to UI (Consumers)
    notifyListeners();
    await performanceTrace.stop();
  }

  // flatten the 2d game grid for GridView widget's children
  List<String> flattenedGameGrid() =>
      [for (List<String> row in currentGameGrid) ...row];

  // add the last played valid word to played words for current game
  void addCurrentValidWordtoPlayedWords() {
    String playedWord =
        currentGameGrid[currentGameRowPointer].join().trim().toLowerCase();
    playedWords.add(playedWord);
  }

  void updateHighScore() {
    switch (maxGameWordLength) {
      case 5:
        if (currentScore > highScoreCasual) highScoreCasual = currentScore;
        break;
      case 6:
        if (currentScore > highScoreCompetitive)
          highScoreCompetitive = currentScore;
        break;
      case 8:
        if (currentScore > highScoreComplex) highScoreComplex = currentScore;
        break;
    }
  }

  int getHighScore() {
    switch (maxGameWordLength) {
      case 5:
        return highScoreCasual;
      case 6:
        return highScoreCompetitive;
      case 8:
        return highScoreComplex;
      default:
        return 0;
    }
  }

  // user game input handler
  Future<void> userInput(String keyInput) async {
    Trace performanceTrace = await FirebaseController.createAndStartNewTrace(
        PerformanceCustomTraces.USER_INPUT,
        attributes: {'difficulty': getGameDifficulty()});
    // if input is delete flag ("1"), delete last letter from game row
    if (keyInput == "1") {
      // limit deletion up to second letter
      if (currentActiveLetterPositionPointer >= 2) {
        currentActiveLetterPositionPointer -= 1;
        currentGameGrid[currentGameRowPointer]
            [currentActiveLetterPositionPointer] = " ";
      }
      // send update to UI (Consumers)
      notifyListeners();
      return;
      // add tapped letter to word if not filled
    } else if (keyInput != "1" &&
        currentActiveLetterPositionPointer < currentRandomGameRowLength) {
      currentGameGrid[currentGameRowPointer]
          [currentActiveLetterPositionPointer] = keyInput;
      // move active letter pointer to the next position
      currentActiveLetterPositionPointer += 1;
      // send update to UI (Consumers)
      notifyListeners();
    }
    Helper.debugPrint(
        "currentActiveLetterPositionPointer: $currentActiveLetterPositionPointer\n"
        "currentRandomGameRowLength: $currentRandomGameRowLength\n"
        "currentGameRow: ${currentGameGrid[currentGameRowPointer]}");

    // if game row is filled, validate word
    if (currentActiveLetterPositionPointer == currentRandomGameRowLength) {
      if (await validateWord(currentGameGrid[currentGameRowPointer])) {
        // play played word sound
        AudioController.playValidWordSound();
        // if valid word, add to score and played words
        currentScore += currentRandomGameRowLength;
        addCurrentValidWordtoPlayedWords();
        // if high score beaten, update high score
        updateHighScore();
        // log played word event
        FirebaseController.logEvent(
            event: AnalyticsEvents.WORD_PLAYED,
            params: {
              "difficulty": getGameDifficulty().toLowerCase(),
              "word_length": currentRandomGameRowLength.toString()
            });
        // generate next game row
        await generateNextGameRow(currentGameGrid[currentGameRowPointer]
            [currentRandomGameRowLength - 1]);
      } else {
        // if word was not valid, play invalid word sound
        AudioController.playInvalidWordSound();
      }
    }
    await performanceTrace.stop();
  }

  Future<bool> validateWord(List<String> wordArray) async {
    // cancel any open toasts
    await Fluttertoast.cancel();

    // start performance custom trace
    Trace performanceTrace = await FirebaseController.createAndStartNewTrace(
        PerformanceCustomTraces.VALIDATE_WORD,
        attributes: {'difficulty': getGameDifficulty()});

    // first letter to be used as index
    String currentPlayedWord = wordArray.join().trim().toLowerCase();
    String firstLetter = currentPlayedWord[0];
    Helper.debugPrint("Validating: $currentPlayedWord");

    // check if word is already played
    bool isNotAlreadyPlayed = !playedWords.contains(currentPlayedWord);
    Helper.debugPrint("isAlreadyPlayed: $isNotAlreadyPlayed");

    // check if word is valid (in the dictionary)
    bool isInDictionary =
        indexedWordMapDictionary[firstLetter].contains(currentPlayedWord);
    Helper.debugPrint("isInDictionary: $isInDictionary");

    await performanceTrace.stop();

    // show toast prompt if word is already played
    // since word played before is definitely in dictionary,
    // it is safe to add prompt for invalid word together here without additional condition
    if (!isNotAlreadyPlayed)
      Fluttertoast.showToast(
          msg: "Word played already",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

    // if word is not in dictionary
    if (!isInDictionary) {
      Fluttertoast.showToast(
          msg: "Invalid word",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      // log invalid word event
      FirebaseController.logEvent(event: AnalyticsEvents.INVALID_WORD, params: {
        "difficulty": getGameDifficulty().toLowerCase(),
        "word_length": currentRandomGameRowLength.toString()
      });
    }

    return isNotAlreadyPlayed && isInDictionary;
  }

  Future<int> incrementTick() async {
    Trace performanceTrace = await FirebaseController.createAndStartNewTrace(
        PerformanceCustomTraces.INCREMENT_TICK,
        attributes: {'difficulty': getGameDifficulty()});
    currentTick += 1;
    // shift currentgamerowpointer up
    currentGameRowPointer -= 1;
    // remove first row
    currentGameGrid.removeAt(0);
    // add a filler row to the last
    currentGameGrid.add(List.generate(8, (index) => ""));
    // ticker limit logic in UI file
    notifyListeners();
    await performanceTrace.stop();
    return currentTick;
  }

  // reset game with initial values values
  void resetGame() {
    currentGameGrid =
        List.generate(10, (index) => List.generate(8, (index) => ""));
    currentGameRowPointer = 9;
    currentRandomGameRowLength = 0;
    currentScore = 0;
    playedWords = [];
    currentTick = 0; //0-9 seconds
  }

  // To be called on app start or game start for refreshing of list
  Future<void> populateIndexedWordMap() async {
    await Future.wait([
      rootBundle.loadString("assets/words_dictionary_index_5.json").then(
          (value) => indexedWordMap5LetterDictionary = json.decode(value)),
      rootBundle.loadString("assets/words_dictionary_index_6.json").then(
          (value) => indexedWordMap6LetterDictionary = json.decode(value)),
      rootBundle.loadString("assets/words_dictionary_index_8.json").then(
          (value) => indexedWordMap8LetterDictionary = json.decode(value)),
    ]);
  }

  /// EXTENSION condition on maxGameWordLength to select word dictionary
  /// map for improving performance
  void selectIndexedWordMapBasedOnDifficulty() {
    switch (maxGameWordLength) {
      case 5:
        indexedWordMapDictionary = indexedWordMap5LetterDictionary;
        break;
      case 6:
        indexedWordMapDictionary = indexedWordMap6LetterDictionary;
        break;
      case 8:
        indexedWordMapDictionary = indexedWordMap8LetterDictionary;
        break;
    }
  }

  // read high score from app key-value pair cache (SharedPreferences)
  Future<void> readHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    highScoreCasual = prefs.getInt(highScoreCasualPrefsKey) ?? 0;
    highScoreCompetitive = prefs.getInt(highScoreCompetitivePrefsKey) ?? 0;
    highScoreComplex = prefs.getInt(highScoreComplexPrefsKey) ?? 0;
    notifyListeners();
  }

  // save high score to app key-value pair cache (SharedPreferences)
  Future<void> saveHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(highScoreCasualPrefsKey, highScoreCasual);
    await prefs.setInt(highScoreCompetitivePrefsKey, highScoreCompetitive);
    await prefs.setInt(highScoreComplexPrefsKey, highScoreComplex);
  }

  /// function for testing game logic with command-line input
  // static List<String> fillGameArray(List<String> gArray, int gameWordLength) {
  //   for (int i = 1; i < gameWordLength; i++) {
  //     Helper.debugPrint(i);
  //     if (gArray[i] == '') {
  //       String? userInputLetter = userInput();
  //       if (userInputLetter != null && userInputLetter.isNotEmpty) {
  //         gArray[i] = userInputLetter;
  //         Helper.debugPrint(gArray); // Print gameArray after each modification
  //       } else {
  //         i--; // Decrement i to reprocess the same index in case of empty input
  //       }
  //     }
  //   }
  //   return gArray;
  // }
}
