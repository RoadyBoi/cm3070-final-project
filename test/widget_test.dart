// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:lain/controllers/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

import 'mock_audio.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() async {
  // Ensure widgets binding is initialized before mocking packages
  TestWidgetsFlutterBinding.ensureInitialized();

  // setup mock firebase app environment
  TestFirebaseCoreHostApi.setup(MockFirebaseApp());
  // initialize mock firebase app
  await Firebase.initializeApp();

  // set mock handlers for analytics and crashlytics platform method calls
  setupFirebaseAnalyticsMocks();
  setupFirebaseCrashlyticsMocks();

  // set mock values for app sharedPreferences
  SharedPreferences.setMockInitialValues({
    highScoreCasualPrefsKey: 15,
    highScoreCompetitivePrefsKey: 21,
    highScoreComplexPrefsKey: 44,
  });

  // set mock audio players platform instance
  // to mock audio players, path_provider has to be mocked as well
  AudioplayersPlatformInterface.instance = FakeAudioplayersPlatform();
  PathProviderPlatform.instance = FakePathProviderPlatform();

  // could not mock packages fluttertoast, firebase_performance
  // related code in LainGame class is commented for tests to run

  // instance of LAIN game for following tests
  LainGame gameInstance = LainGame();

  // check populated word maps
  test('Test populating the runtime word maps', () async {
    // maps are populated in LainGame instantiation
    await Future.delayed(Duration(seconds: 1));
    // 26 letters in the alphabet hence 26 keys in all maps
    expect(indexedWordMap5LetterDictionary.keys.length, 26);
    expect(indexedWordMap6LetterDictionary.keys.length, 26);
    expect(indexedWordMap8LetterDictionary.keys.length, 26);

    // all words must be strings in the value of the map entry
    expect(indexedWordMap5LetterDictionary.entries.first.value,
        everyElement(isA<String>()));
  });

  // test getFirstLetter()
  test('Test create first letter', () {
    expect(gameInstance.getFirstLetter(), isIn(letterList));
  });

  // test generateFirstGameRow()
  test('Test generate first game row', () {
    gameInstance.generateFirstGameRow();

    // game row should contain spaces, empty strings and lowercase letter
    if (gameInstance.currentRandomGameRowLength < 8) {
      expect(gameInstance.currentGameGrid[gameInstance.currentGameRowPointer],
          contains(""));
    }
    expect(gameInstance.currentGameGrid[gameInstance.currentGameRowPointer],
        contains(" "));
    expect(
        gameInstance.currentGameGrid[gameInstance.currentGameRowPointer].first,
        isIn(letterList));
    // reset game instance to default values
    gameInstance.resetGame();
  });

  // test calculateRandomGameRowLength
  test('Test new random game row length calculation', () {
    gameInstance.calculateRandomGameRowLength();

    // current game row length should be 3 - maxGameWordLength
    expect(
        gameInstance.currentRandomGameRowLength,
        allOf(isNotNull, greaterThanOrEqualTo(3),
            lessThanOrEqualTo(gameInstance.maxGameWordLength)));

    // reset game instance to default values
    gameInstance.resetGame();
  });

  // test userInput with a single letter input on new row
  test("Test single letter input handle", () async {
    gameInstance.generateFirstGameRow();
    await gameInstance.userInput("e");

    // game row must have 2 letters
    // and acive pointer should be at 2
    expect(
        gameInstance.currentGameGrid[gameInstance.currentGameRowPointer]
          ..removeWhere((element) => element == "")
          ..removeWhere((element) => element == " "),
        hasLength(2));
    expect(gameInstance.currentActiveLetterPositionPointer, 2);

    // reset game instance to default values
    gameInstance.resetGame();
  });

  // test delete 2nd letter on game row
  test('Test delete letter input', () async {
    gameInstance.generateFirstGameRow();
    await gameInstance.userInput('e');
    // delete input
    await gameInstance.userInput('1');

    // game row should have one letter remaining
    // and active pointer should be 1
    expect(
        gameInstance.currentGameGrid[gameInstance.currentGameRowPointer]
          ..removeWhere((element) => element == "")
          ..removeWhere((element) => element == " "),
        hasLength(1));
    expect(gameInstance.currentActiveLetterPositionPointer, 1);

    // reset game instance to default values
    gameInstance.resetGame();
  });

  // test delete last letter
  test('Test delete last letter', () async {
    gameInstance.generateFirstGameRow();

    // fill word
    Iterable.generate(gameInstance.currentRandomGameRowLength)
        .forEach((element) async {
      await gameInstance.userInput('x');
    });

    // active pointer should be current random game row length
    expect(gameInstance.currentActiveLetterPositionPointer,
        gameInstance.currentRandomGameRowLength);

    // delete operation
    await gameInstance.userInput("1");

    // active pointer should be random game row length - 1
    // element at active pointer should be space character
    expect(gameInstance.currentActiveLetterPositionPointer,
        gameInstance.currentRandomGameRowLength - 1);
    expect(
        gameInstance.currentGameGrid[gameInstance.currentGameRowPointer]
            [gameInstance.currentActiveLetterPositionPointer],
        " ");

    // reset game instance to default values
    gameInstance.resetGame();
  });

  // test filling invalid word
  test('Test filling invalid word', () async {
    gameInstance.generateFirstGameRow();

    // fill word
    Iterable.generate(gameInstance.currentRandomGameRowLength)
        .forEach((element) async {
      await gameInstance.userInput('x');
    });

    // validate word should return false when current game row is filled
    // and played words list should be empty
    expect(
        await gameInstance.validateWord(
            gameInstance.currentGameGrid[gameInstance.currentGameRowPointer]),
        false);
    expect(gameInstance.playedWords.length, 0);

    // reset game instance to default values
    gameInstance.resetGame();
  });
}
