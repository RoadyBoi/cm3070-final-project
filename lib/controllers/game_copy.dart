import 'dart:math';
import 'dart:io';
import 'dart:convert';

void main() {
  LaneGame.populateIndexedWordMap();
}

class LaneGame {
  static List<String> currentGameArray = [];
  static int currentRandomNumber = 0;

  static Map indexedWordMap = {};
  static List<String> playedWords = [];

  static String getFirstLetter() {
    Random random = Random();
    int randomNumber = random.nextInt(26);
    List<String> letterList =
        List.generate(26, (index) => String.fromCharCode(index + 97));
    return letterList[randomNumber];
  }

  static void calculateRandomNumber() {
    currentRandomNumber = 3 + Random().nextInt(9 - 3);
  }

  static List<String> generateFirstGameArray() {
    List<String> emptyStringArray =
        List<String>.filled(currentRandomNumber, '');
    emptyStringArray[0] = getFirstLetter();
    return emptyStringArray;
  }

  static String? userInput() {
    String? input = stdin.readLineSync();
    // Check if input is not empty
    if (input != null && input.isNotEmpty) {
      return input.trim().toLowerCase()[0];
    } else {
      return null;
    }
  }

  static List<String> fillGameArray(List<String> gArray, int gameWordLength) {
    for (int i = 1; i < gameWordLength; i++) {
      print(i);
      if (gArray[i] == '') {
        String? userInputLetter = userInput();
        if (userInputLetter != null && userInputLetter.isNotEmpty) {
          gArray[i] = userInputLetter;
          print(gArray); // Print gameArray after each modification
        } else {
          i--; // Decrement i to reprocess the same index in case of empty input
        }
      }
    }
    return gArray;
  }

  // one-time use only (command-line dart)
  static void generateIndexedJson() {
    File jsonSourceFile = File("../../assets/words_dictionary.json");
    Map wordMap = json.decode(jsonSourceFile.readAsStringSync());
    Map indexedWordMap = {};
    String currentWord;

    wordMap.entries.forEach((entry) {
      // word in json list
      currentWord = entry.key.trim().toLowerCase();
      // if no first letter entry in result json map, create entry with key = word and value = empty list
      if (!indexedWordMap.containsKey(currentWord[0])) {
        indexedWordMap[currentWord[0]] = [];
      }
      // filter word in word list by length and add to result json map inside the key index list
      if (currentWord.length > 2 && currentWord.length < 9) {
        indexedWordMap[currentWord[0]].add(currentWord);
      }
    });

    // save the indexed word list
    File jsonResultFile = File("../../assets/words_dictionary_index.json");
    jsonResultFile.writeAsStringSync(json.encode(indexedWordMap));
  }

  // To be called on app start or game start for refreshing of list
  static void populateIndexedWordMap() {
    indexedWordMap = json.decode(
        File("../../assets/words_dictionary_index.json").readAsStringSync());
  }

  static bool validateWord(List<String> wordArray) {
    // first letter to be used as index
    String firstLetter = wordArray[0];
    String currentPlayedWord = wordArray.join().trim().toLowerCase();

    return (!playedWords.contains(currentPlayedWord)) &&
        (indexedWordMap[firstLetter]?.contains(currentPlayedWord) ?? false);
  }
}
