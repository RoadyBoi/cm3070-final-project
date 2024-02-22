import 'dart:io';
import 'dart:convert';

// one-time use only (command-line dart)
/// EXTENSION maxLimit (generateIndexedJSON for different game difficulties: 5,6,8 to improve performance)
void generateIndexedJson(int maxLimit) {
  File jsonSourceFile = File("assets/words_dictionary.json");
  Map wordMap = json.decode(jsonSourceFile.readAsStringSync());
  String currentWord;
  Map indexedJsonMap = {};

  wordMap.entries.forEach((entry) {
    // word in json list
    currentWord = entry.key.trim().toLowerCase();
    // if no first letter entry in result json map, create entry with key = word and value = empty list
    if (!indexedJsonMap.containsKey(currentWord[0])) {
      indexedJsonMap[currentWord[0]] = [];
    }
    // filter word in word list by length and add to result json map inside the key index list
    if (currentWord.length > 2 && currentWord.length <= maxLimit) {
      indexedJsonMap[currentWord[0]].add(currentWord);
    }
  });

  // save the indexed word list
  File jsonResultFile = File("assets/words_dictionary_index_$maxLimit.json");
  jsonResultFile.writeAsStringSync(json.encode(indexedJsonMap));
}

// one-time use only (command-line dart)
// to generate indexed maps from open-source word dictionary text file
void main() {
  generateIndexedJson(5);
  generateIndexedJson(6);
  generateIndexedJson(8);
}
