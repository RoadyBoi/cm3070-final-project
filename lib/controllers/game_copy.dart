import 'dart:math';
import 'dart:io';

void main() {
  int rnd = getRandomNumber();
  String firstLetter = getFirstLetter();
  List<String> gameArray = generateGameArray(rnd, firstLetter);
  print(gameArray); // Print initial gameArray
  fillGameArray(gameArray, rnd);
  // print(gameArray); // Print gameArray after filling
  print(userInput(rnd, gameArray));
}

String getFirstLetter() {
  Random random = Random();
  int randomNumber = random.nextInt(26);
  List<String> outputArray =
      List.generate(26, (index) => String.fromCharCode(index + 65));
  return outputArray[randomNumber];
}

int getRandomNumber() {
  Random random = Random();
  int min = 3;
  int max = 9;
  int r = min + random.nextInt(max - min);
  return r;
}

List<String> generateGameArray(int randomNumber, String firstLetter) {
  List<String> emptyStringArray = List<String>.filled(randomNumber, '');
  emptyStringArray[0] = firstLetter;
  return emptyStringArray;
}

List<String> userInput(int rndNum, List<String> gArray) {
  String? input = stdin.readLineSync();
  // Check if input is not empty
  if (input != null && input.isNotEmpty) {
    return input
        .substring(0, input.length <= rndNum ? input.length : rndNum)
        .split('')
        .map((x) => x.toUpperCase())
        .toList();
  } else {
    return [];
  }
}

List<String> fillGameArray(List<String> gArray, int rndNum) {
  for (int i = 1; i < rndNum; i++) {
    if (gArray[i] == '') {
      List<String> userInputList = userInput(1, gArray);
      if (userInputList.isNotEmpty) {
        gArray[i] = userInputList[0];
        print(gArray); // Print gameArray after each modification
      } else {
        i--; // Decrement i to reprocess the same index in case of empty input
      }
    }
  }
  return gArray;
}
