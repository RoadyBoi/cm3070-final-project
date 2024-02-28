// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lain/controllers/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

import 'mock_audio.dart';
import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

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
    highScoreCasualPrefsKey: 0,
    highScoreCompetitivePrefsKey: 0,
    highScoreComplexPrefsKey: 0,
  });

  // set mock audio players platform instance
  // to mock audio players, path_provider has to be mocked as well
  AudioplayersPlatformInterface.instance = FakeAudioplayersPlatform();
  PathProviderPlatform.instance = FakePathProviderPlatform();

  // could not mock packages fluttertoast, firebase_performance
  // related code in LainGame class is commented for tests to run

  setUpAll(() async => await // populate indexed wordmaps
      LainGame.populateIndexedWordMap());

  // check populated word maps
  test('Test populating the runtime word maps', () async {
    // 26 letters in the alphabet hence 26 keys in all maps
    expect(indexedWordMap5LetterDictionary.keys.length, 26);
    expect(indexedWordMap6LetterDictionary.keys.length, 26);
    expect(indexedWordMap8LetterDictionary.keys.length, 26);

    // all words must be strings in the value of the map entry
    expect(indexedWordMap5LetterDictionary.entries.first.value,
        everyElement(isA<String>()));
  });

  test('Test flattening of game grid', () {
    LainGame gameInstance = LainGame();

    // gameInstance.currentgamegrid.length is the number of rows
    // gameInstance.currentGamegrid.first.length is the number of columns
    // flattened list must be rows x columns
    expect(
        gameInstance.flattenedGameGrid(),
        hasLength(gameInstance.currentGameGrid.length *
            gameInstance.currentGameGrid.first.length));
  });

  // test getFirstLetter()
  test('Test create first letter', () {
    LainGame gameInstance = LainGame();

    expect(gameInstance.getFirstLetter(), isIn(letterList));
  });

  // test generateFirstGameRow()
  test('Test generate first game row', () {
    LainGame gameInstance = LainGame();

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
  });

  // test calculateRandomGameRowLength
  test('Test new random game row length calculation', () {
    LainGame gameInstance = LainGame();

    gameInstance.calculateRandomGameRowLength();

    // current game row length should be 3 - maxGameWordLength
    expect(
        gameInstance.currentRandomGameRowLength,
        allOf(isNotNull, greaterThanOrEqualTo(3),
            lessThanOrEqualTo(gameInstance.maxGameWordLength)));
  });

  // test userInput with a single letter input on new row
  test("Test single letter input handle", () async {
    LainGame gameInstance = LainGame();

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
  });

  // test delete 2nd letter on game row
  test('Test delete letter input handle', () async {
    LainGame gameInstance = LainGame();

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
  });

  // test delete last letter
  test('Test delete last letter handle', () async {
    LainGame gameInstance = LainGame();

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
  });

  // test filling invalid word
  test('Test filling invalid word', () async {
    LainGame gameInstance = LainGame();

    gameInstance.generateFirstGameRow();

    // fill word
    for (int i = 1; i < gameInstance.currentRandomGameRowLength; i++) {
      await gameInstance.userInput('x');
    }

    // validate word should return false when current game row is filled
    // and played words list should be empty
    expect(
        await gameInstance.validateWord(
            gameInstance.currentGameGrid[gameInstance.currentGameRowPointer]),
        false);
    expect(gameInstance.playedWords.length, 0);
  });

  // test filling valid word
  test('Test filling valid word', () async {
    LainGame gameInstance = LainGame();

    // generate first game row and store the first letter
    gameInstance.generateFirstGameRow();
    String currentFirstWord =
        gameInstance.currentGameGrid[gameInstance.currentGameRowPointer].first;

    // store first game row length
    int initialGameRowLength = gameInstance.currentRandomGameRowLength;

    // find a valid word's letters from word dictionary
    List<String> validWordLetters =
        indexedWordMap8LetterDictionary[currentFirstWord]
            .firstWhere((element) =>
                element.length == gameInstance.currentRandomGameRowLength)
            .split('');
    validWordLetters.removeAt(0);

    // fill the valid word to the current game row
    for (String letter in validWordLetters) {
      await gameInstance.userInput(letter);
    }

    // the game row should move up the grid (index -= 1)
    // validateWord(played word game row) should return false (already played word)
    // playedwords should contain the valid word
    // the new row should be a game row
    // the new row should start with last letter of the played word
    // current active letter position pointer should be 1 (since first letter at 0)
    // current score should include the played word length
    // current high score should include the played word length (when high score is 0)
    expect(gameInstance.currentGameRowPointer,
        gameInstance.currentGameGrid.length - 1);
    expect(
        await gameInstance.validateWord(gameInstance
            .currentGameGrid[gameInstance.currentGameRowPointer - 1]),
        false);
    expect(
        gameInstance.playedWords,
        contains(gameInstance
            .currentGameGrid[gameInstance.currentGameRowPointer - 1]
            .join('')
            .trim()));
    expect(
        gameInstance.currentGameGrid[gameInstance.currentGameRowPointer].first,
        gameInstance.currentGameGrid[gameInstance.currentGameRowPointer - 1]
            [initialGameRowLength - 1]);
    expect(
        gameInstance.currentGameGrid[gameInstance.currentGameRowPointer],
        anyOf(
            containsAll([
              ' ',
              gameInstance
                  .currentGameGrid[gameInstance.currentGameRowPointer].first,
              ''
            ]),
            containsAll([
              ' ',
              gameInstance
                  .currentGameGrid[gameInstance.currentGameRowPointer].first
            ])));
    expect(gameInstance.currentActiveLetterPositionPointer, 1);
    expect(gameInstance.currentScore, initialGameRowLength);
    expect(gameInstance.getHighScore(), initialGameRowLength);
  });

  test('Test ticking', () async {
    LainGame gameInstance = LainGame();

    gameInstance.generateFirstGameRow();

    // input a letter
    await gameInstance.userInput('x');

    String currentGameWordBeforeTick = gameInstance
        .currentGameGrid[gameInstance.currentGameRowPointer]
        .join('')
        .trim();

    // simulate tick
    gameInstance.incrementTick();

    // game row pointer should be game grid's max index - 1
    // last game grid row should be a filler row
    // game grid moved up should have the input carried as well
    expect(gameInstance.currentGameRowPointer,
        gameInstance.currentGameGrid.length - 2);
    expect(gameInstance.currentGameGrid.last, everyElement(""));
    expect(
        gameInstance.currentGameGrid[gameInstance.currentGameRowPointer]
            .join('')
            .trim(),
        currentGameWordBeforeTick);
  });

  test('Test game over state (tick 0-9)', () async {
    LainGame gameInstance = LainGame();

    gameInstance.generateFirstGameRow();

    // tick 10 times
    for (int i = 0; i < 10; i++) {
      await gameInstance.incrementTick();
    }

    // game grid should have all filler rows
    // game row pointer should be -1
    expect(gameInstance.currentGameGrid,
        everyElement(allOf(hasLength(8), everyElement(""))));
    expect(gameInstance.currentGameRowPointer, -1);
  });

  test('Test ticker periodic timer for UI', () async {
    LainGame gameInstance = LainGame();

    Timer? tickTimer;

    // Periodic timer ticker
    tickTimer = Timer.periodic(Duration(seconds: 1), (thisTimer) async {
      int nowTick = await gameInstance.incrementTick();
      if (nowTick > 9) thisTimer.cancel();
    });

    // after 10 seconds, the periodic timer must cancel for UI to relect game end
    // 50ms delay to allow updating of timer active status after timer is cancelled
    await Future.delayed(Duration(milliseconds: 10050), () {
      expect(tickTimer!.isActive, false);
    });
  });
}
