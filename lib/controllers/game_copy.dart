import 'dart:math';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

const String highScorePrefsKey = "LAINHighScorePrefsKey";

class LainGame extends ChangeNotifier {
  List<List<String>> currentGameGrid =
      List.generate(10, (index) => List.generate(8, (index) => ""));
  int currentGameRowIndex = 9;
  int currentRandomGameRowLength = 0;
  int currentActiveLetterPositionPointer = 1;
  int currentScore = 0;
  List<String> playedWords = [];
  int currentTick = 0; //0-9 seconds

  Map indexedWordMapDictionary = {};
  int highScore = 0;

  LainGame() {
    populateIndexedWordMap();
    readHighScore();
    generateFirstGameRow();
  }

  String getFirstLetter() {
    Random random = Random();
    int randomNumber = random.nextInt(26);
    List<String> letterList =
        List.generate(26, (index) => String.fromCharCode(index + 97));
    return letterList[randomNumber];
  }

  void calculateRandomGameRowLength() {
    currentRandomGameRowLength = 3 + Random().nextInt(9 - 3);
  }

  void generateFirstGameRow() {
    currentGameGrid[9][0] = getFirstLetter();
    calculateRandomGameRowLength();
    // keeping spaces indicates game row box
    for (int i = 1; i < currentRandomGameRowLength; i++) {
      currentGameGrid[9][i] = " ";
    }
    currentActiveLetterPositionPointer = 1;
    currentGameRowIndex = 9;
    notifyListeners();
  }

  void generateNextGameRow(String lastGameWordLetter) {
    currentGameGrid.removeAt(0);
    notifyListeners();
    List<String> newRow = [lastGameWordLetter];
    calculateRandomGameRowLength();
    for (int i = 1; i < 8; i++) {
      if (i < currentRandomGameRowLength)
        newRow.add(" ");
      else
        newRow.add("");
    }
    currentGameGrid.add(newRow);
    currentGameRowIndex = 9;
    currentActiveLetterPositionPointer = 1;
    currentTick = 0; //reset tick
    notifyListeners();
  }

  List<String> flattenedGameGrid() {
    return [for (List<String> row in currentGameGrid) ...row];
  }

  void addCurrentValidWordtoPlayedWords() {
    String playedWord =
        currentGameGrid[currentGameRowIndex].join().trim().toLowerCase();
    playedWords.add(playedWord);
  }

  void userInput(String keyInput) {
    // if delete input (1), delete last letter from gamerow
    if (keyInput == "1") {
      // if word is filled (pointer = length), put pointer at length - 1
      if (currentActiveLetterPositionPointer == currentGameRowIndex)
        currentActiveLetterPositionPointer -= 1;

      // go back one space, but not change first letter
      if (currentActiveLetterPositionPointer >= 2)
        currentActiveLetterPositionPointer -= 1;

      // delete word
      currentGameGrid[currentGameRowIndex][currentActiveLetterPositionPointer] =
          " ";

      notifyListeners();
      return;
      // add tapped letter to word if not filled
    } else if (keyInput != "1" &&
        currentActiveLetterPositionPointer < currentRandomGameRowLength) {
      currentGameGrid[currentGameRowIndex][currentActiveLetterPositionPointer] =
          keyInput;
      currentActiveLetterPositionPointer += 1;
      notifyListeners();
    }
    print(
        "currentActiveLetterPositionPointer: $currentActiveLetterPositionPointer");
    print("currentRandomGameRowLength: $currentRandomGameRowLength");

    // if game row is filled, validate word
    if (currentActiveLetterPositionPointer == currentRandomGameRowLength) {
      if (validateWord(currentGameGrid[currentGameRowIndex])) {
        // if valid word, add to score and played words
        currentScore += currentRandomGameRowLength;
        // if high score beaten, update high score
        if (currentScore > highScore) {
          highScore = currentScore;
        }
        addCurrentValidWordtoPlayedWords();
        // generate next game row
        generateNextGameRow(currentGameGrid[currentGameRowIndex]
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
    print("Validating: $currentPlayedWord");

    bool isNotAlreadyPlayed = !playedWords.contains(currentPlayedWord);
    print("isAlreadyPlayed: $isNotAlreadyPlayed");

    bool isInDictionary =
        indexedWordMapDictionary[firstLetter].contains(currentPlayedWord);
    print("isInDictionary: $isInDictionary");

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
    // shift currentgamerow up
    // currentGameGrid[currentGameRowIndex - 1] =
    //     currentGameGrid[currentGameRowIndex];
    // currentGameGrid[currentGameRowIndex] = List.generate(8, (index) => "");
    currentGameRowIndex -= 1;
    // remove first row
    currentGameGrid.removeAt(0);
    // add a filler row to the last
    currentGameGrid.add(List.generate(8, (index) => ""));
    // ticker limit logic in UI file
    notifyListeners();
    return currentTick;
  }

  void resetGame() {
    currentGameGrid =
        List.generate(10, (index) => List.generate(8, (index) => ""));
    currentGameRowIndex = 9;
    currentRandomGameRowLength = 0;
    currentScore = 0;
    playedWords = [];
    currentTick = 0; //0-9 seconds
    generateFirstGameRow();
  }

  // static List<String> fillGameArray(List<String> gArray, int gameWordLength) {
  //   for (int i = 1; i < gameWordLength; i++) {
  //     print(i);
  //     if (gArray[i] == '') {
  //       String? userInputLetter = userInput();
  //       if (userInputLetter != null && userInputLetter.isNotEmpty) {
  //         gArray[i] = userInputLetter;
  //         print(gArray); // Print gameArray after each modification
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

  Future<void> readHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt(highScorePrefsKey) ?? 0;
    notifyListeners();
  }

  Future<void> saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(highScorePrefsKey, highScore);
  }
}
