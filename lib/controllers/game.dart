import 'dart:math';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

// cache (SharedPrefs) key-value pair for high score
const String highScorePrefsKey = "LAINHighScorePrefsKey";
// lowercase letter list
final List<String> letterList =
    List.generate(26, (index) => String.fromCharCode(index + 97));

/// LainGame class uses provider architecture for state management
/// to implement the game logic. LainGame is ChangeNotifier class
/// that is provided to the root widget of the app and changes to
/// LainGame class members update the Consumer widgets that are listening
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
  // high score
  int highScore = 0;

  LainGame() {
    populateIndexedWordMap();
    readHighScore();
    generateFirstGameRow();
  }

  // get random letter from letter list for first game row
  String getFirstLetter() => letterList[Random().nextInt(26)];

  // calculate random length of the word to play next
  void calculateRandomGameRowLength() {
    currentRandomGameRowLength =
        3 + Random().nextInt((maxGameWordLength + 1) - 3);
  }

  // set game difficulty
  // difficulty level (5 = casual, 6 = challenging, 8 = complex)
  void setGameDifficulty(int difficultyLevel) {
    maxGameWordLength = difficultyLevel;
  }

  // create first game row with random first letter and random length
  // first row will be the last row in the grid [9] so that rows
  // move bottom to top
  void generateFirstGameRow() {
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
  void generateNextGameRow(String lastGameWordLetter) {
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

  // user game input handler
  void userInput(String keyInput) {
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
        "currentActiveLetterPositionPointer: $currentActiveLetterPositionPointer");
    Helper.debugPrint(
        "currentRandomGameRowLength: $currentRandomGameRowLength");
    Helper.debugPrint(
        "currentGameRow: ${currentGameGrid[currentGameRowPointer]}");

    // if game row is filled, validate word
    if (currentActiveLetterPositionPointer == currentRandomGameRowLength) {
      if (validateWord(currentGameGrid[currentGameRowPointer])) {
        // if valid word, add to score and played words
        currentScore += currentRandomGameRowLength;
        // if high score beaten, update high score
        if (currentScore > highScore) {
          highScore = currentScore;
        }
        addCurrentValidWordtoPlayedWords();
        // generate next game row
        generateNextGameRow(currentGameGrid[currentGameRowPointer]
            [currentRandomGameRowLength - 1]);
      }
    }
    // else if (keyInput.isNotEmpty) {
    //    keyInput.trim().toLowerCase()[0];
    // } else {
    //   return null;
    // }
  }

  bool validateWord(List<String> wordArray) {
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

    Fluttertoast.cancel();

    // show toast prompt if word is already played
    if (!isNotAlreadyPlayed)
      Fluttertoast.showToast(
          msg: "Word played already",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    // since word played before is definitely in dictionary,
    // safe to add prompt for invalid word together here without additional condition
    if (!isInDictionary)
      Fluttertoast.showToast(
          msg: "Invalid word",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

    return isNotAlreadyPlayed && isInDictionary;
  }

  int incrementTick() {
    currentTick += 1;
    // shift currentgamerowpointer up
    currentGameRowPointer -= 1;
    // remove first row
    currentGameGrid.removeAt(0);
    // add a filler row to the last
    currentGameGrid.add(List.generate(8, (index) => ""));
    // ticker limit logic in UI file
    notifyListeners();
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
    generateFirstGameRow();
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

  // one-time use only (command-line dart)
  void generateIndexedJson() {
    File jsonSourceFile = File("assets/words_dictionary.json");
    Map wordMap = json.decode(jsonSourceFile.readAsStringSync());
    String currentWord;

    wordMap.entries.forEach((entry) {
      // word in json list
      currentWord = entry.key.trim().toLowerCase();
      // if no first letter entry in result json map, create entry with key = word and value = empty list
      if (!indexedWordMapDictionary.containsKey(currentWord[0])) {
        indexedWordMapDictionary[currentWord[0]] = [];
      }
      // filter word in word list by length and add to result json map inside the key index list
      if (currentWord.length > 2 && currentWord.length < 9) {
        indexedWordMapDictionary[currentWord[0]].add(currentWord);
      }
    });

    // save the indexed word list
    File jsonResultFile = File("assets/words_dictionary_index.json");
    jsonResultFile.writeAsStringSync(json.encode(indexedWordMapDictionary));
  }

  // To be called on app start or game start for refreshing of list
  Future<void> populateIndexedWordMap() async {
    final jsonString =
        await rootBundle.loadString("assets/words_dictionary_index.json");
    indexedWordMapDictionary = json.decode(jsonString);
  }

  // read high score from app key-value pair cache (SharedPreferences)
  Future<void> readHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt(highScorePrefsKey) ?? 0;
    notifyListeners();
  }

  // save high score to app key-value pair cache (SharedPreferences)
  Future<void> saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(highScorePrefsKey, highScore);
  }
}
