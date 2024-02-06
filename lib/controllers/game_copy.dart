import 'dart:math';
import 'dart:io';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

const String highScorePrefsKey = "LAINHighScorePrefsKey";

class LainGame extends ChangeNotifier {
  List<List<String>> currentGameGrid =
      List.generate(10, (index) => List.generate(8, (index) => ""));
  int currentGameRowIndex = 9;
  int currentRandomGameRowLength = 0;
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
    currentGameRowIndex = 9;
    notifyListeners();
  }

  void generateNextGameRow(String lastGameWordLetter) {
    currentGameGrid[9][0] = lastGameWordLetter;
    calculateRandomGameRowLength();
    for (int i = 1; i < currentRandomGameRowLength; i++) {
      currentGameGrid[9][i] = " ";
    }
    currentGameRowIndex = 9;
    resetTick();
    notifyListeners();
  }

  void userInput(String keyInput) {
    // if delete input, delete last letter from gamerow
    if (keyInput == "DELETE" &&
        currentGameGrid[currentGameRowIndex].length > 1) {
      currentGameGrid[currentGameRowIndex].removeLast();
      notifyListeners();
      // if filling word, keep adding to game row
    } else if (currentGameGrid[currentGameRowIndex].length <
        currentRandomGameRowLength) {
      currentGameGrid[currentGameRowIndex].add(keyInput);
      notifyListeners();
    }
    // if game row is filled, validate word
    if (currentGameGrid[currentGameRowIndex].length ==
        currentRandomGameRowLength) {
      if (validateWord(currentGameGrid[currentGameRowIndex])) {
        // if valid word, add to score and played words
        String playedWord =
            currentGameGrid[currentGameRowIndex].join().trim().toLowerCase();
        currentScore += playedWord.length;
        playedWords.add(playedWord);
        // if high score beaten, update high score
        if (currentScore > highScore) {
          highScore = currentScore;
        }
        // generate next game row
        generateNextGameRow(currentGameGrid[currentGameRowIndex].last);
      } else {
        Fluttertoast.showToast(
            msg: "Invalid word",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
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
    String firstLetter = wordArray[0];
    String currentPlayedWord = wordArray.join().trim().toLowerCase();

    return (!playedWords.contains(currentPlayedWord)) &&
        (indexedWordMapDictionary[firstLetter]?.contains(currentPlayedWord) ??
            false);
  }

  int incrementTick() {
    currentTick += 1;
    // remove first row
    currentGameGrid.removeAt(0);
    // add a row to the last
    currentGameGrid.add(List.generate(8, (index) => ""));
    // move current game row up
    currentGameRowIndex -= 1;
    // ticker limit logic in UI file
    // if (currentTick > 9)
    return incrementTick();
  }

  void resetTick() {
    currentTick = 0;
  }

  void resetGame() {
    currentGameGrid =
        List.generate(10, (index) => List.generate(8, (index) => ""));
    currentGameRowIndex = 9;
    currentRandomGameRowLength = 0;
    currentScore = 0;
    playedWords = [];
    currentTick = 0; //0-9 seconds
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
    File jsonSourceFile = File("../../assets/words_dictionary.json");
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
    File jsonResultFile = File("../../assets/words_dictionary_index.json");
    jsonResultFile.writeAsStringSync(json.encode(indexedWordMapDictionary));
  }

  // To be called on app start or game start for refreshing of list
  void populateIndexedWordMap() {
    indexedWordMapDictionary = json.decode(
        File("../../assets/words_dictionary_index.json").readAsStringSync());
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
