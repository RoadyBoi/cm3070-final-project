import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lain/controllers/game.dart';
import 'package:lain/main.dart';
import 'package:lain/route_generator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

// using 'flutter run -d [emulator-id] test/widget_test.dart' to run the tests in an emulator

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

  // no need to mock audioplayers, fluttertoast, path_provider for widget tests
  // as they are run on emulator and will support these packages in the runtime

  setUpAll(() async => await // populate indexed wordmaps
      LainGame.populateIndexedWordMap());

  WidgetTests.testSplash();
  WidgetTests.testPlayButton();
  WidgetTests.testPlayAgainButton();
  WidgetTests.testKeyboardInput();
  WidgetTests.testInvalidWord();
  WidgetTests.testValidWord();
  WidgetTests.testGameEndUI();
}

class WidgetTests {
  static void testSplash() {
    testWidgets('Test splash screen navigates to home page after 3 seconds',
        (widgetTester) async {
      await widgetTester.binding.setSurfaceSize(Size(400, 900));

      await widgetTester.pumpWidget(ChangeNotifierProvider(
          lazy: false, create: (context) => LainGame(), child: LainApp()));
      // this renders frames on the same page for 3 seconds
      await widgetTester.pump(Duration(seconds: 3));
      // after 3 seconds splash screen should navigate to home screen
      // additional 300 milliseconds allowed for frame rendering
      expect(RouteGenerator.currentRoute.value, "/StartScreen");
    }, tags: ['splash']);
  }

  // limita
  static void testPlayButton() {
    testWidgets('Test play button navigating to game page',
        (widgetTester) async {
      await widgetTester.binding.setSurfaceSize(Size(400, 900));

      // render home page with LainGame provider
      await widgetTester.pumpWidget(ChangeNotifierProvider(
          lazy: false,
          create: (context) => LainGame(),
          child: LainApp(
            initialRoute: "/StartScreen",
          )));

      // tap the elevated button to start the game and navigate to game page
      await widgetTester.tap(find.byKey(Key("start_game_button")));

      // the game page should be on screen now
      expect(RouteGenerator.currentRoute.value, "/GameRoomScreen");
    }, tags: ['playButton']);
  }

  static void testPlayAgainButton() {
    testWidgets('Test game replay from final screen', (widgetTester) async {
      await widgetTester.binding.setSurfaceSize(Size(400, 900));

      await widgetTester.pumpWidget(ChangeNotifierProvider(
          lazy: false,
          create: (context) => LainGame(),
          child: LainApp(
            initialRoute: '/FinalPageScreen',
          )));

      // tap the elevated button to start the game and navigate to game page
      await widgetTester.tap(find.byKey(Key("rematch_button")));

      // start screen should be the current route
      expect(RouteGenerator.currentRoute.value, "/StartScreen");
    }, tags: ['rematch']);
  }

  static void testKeyboardInput() {
    testWidgets('Test keyboard input on game page', (widgetTester) async {
      await widgetTester.binding.setSurfaceSize(Size(400, 900));

      LainGame gameInstance = LainGame();

      // render home page with LainGame provider
      await widgetTester.pumpWidget(ChangeNotifierProvider(
          lazy: false,
          create: (context) => gameInstance,
          child: LainApp(
            initialRoute: "/StartScreen",
          )));

      // tap the elevated button to start the game and navigate to game page
      await widgetTester.tap(find.byKey(Key("start_game_button")));

      // wait for the game page frame to render and widgets to be initialized
      await widgetTester.pump(Duration(milliseconds: 500));

      // tap the keyboard key for test input
      await widgetTester.tap(find.byKey(Key("q")));

      // allow the changenotifier to update state
      await widgetTester.pump(Duration(seconds: 1));

      // the test button was the letter q, the current game row's second letter should be q
      expect(
          gameInstance.currentGameGrid[gameInstance.currentGameRowPointer][1],
          "q");
    }, tags: ["keyboard"]);
  }

  static void testInvalidWord() {
    testWidgets("Test invalid word entry", (widgetTester) async {
      await widgetTester.binding.setSurfaceSize(Size(400, 900));

      LainGame gameInstance = LainGame();

      // render home page with LainGame provider
      await widgetTester.pumpWidget(ChangeNotifierProvider(
          lazy: false,
          create: (context) => gameInstance,
          child: LainApp(
            initialRoute: "/StartScreen",
          )));

      // tap the elevated button to start the game and navigate to game page
      await widgetTester.tap(find.byKey(Key("start_game_button")));

      // wait for the game page frame to render and widgets to be initialized
      await widgetTester.pump(Duration(milliseconds: 200));

      for (int i = 1; i < gameInstance.currentRandomGameRowLength; i++) {
        // tap the 'x' key to input invalid word
        await widgetTester.tap(find.byKey(Key("z")));
        // allow the changenotifier to update state
        await widgetTester.pump(Duration(seconds: 1));
      }

      // the invalid word was made by inputting the letter x for word length
      // validateword should return false for the current word
      // playedWords should not contain current word
      expect(
          await gameInstance.validateWord(
              gameInstance.currentGameGrid[gameInstance.currentGameRowPointer]),
          false);
      expect(
          gameInstance.playedWords,
          isNot(contains(gameInstance
              .currentGameGrid[gameInstance.currentGameRowPointer]
              .join('')
              .trim()
              .toLowerCase())));
    }, tags: ["invalid_word"]);
  }

  static void testValidWord() {
    testWidgets('Test valid word entry', (widgetTester) async {
      await widgetTester.binding.setSurfaceSize(Size(400, 900));

      LainGame gameInstance = LainGame();

      // render home page with LainGame provider
      await widgetTester.pumpWidget(ChangeNotifierProvider(
          lazy: false,
          create: (context) => gameInstance,
          child: LainApp(
            initialRoute: "/StartScreen",
          )));

      // tap the elevated button to start the game and navigate to game page
      await widgetTester.tap(find.byKey(Key("start_game_button")));

      // wait for the game page frame to render and widgets to be initialized
      await widgetTester.pump(Duration(milliseconds: 500));

      // store current first word
      String currentFirstWord = gameInstance
          .currentGameGrid[gameInstance.currentGameRowPointer].first;

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
        // tap the keyboard key for test input
        await widgetTester.tap(find.byKey(Key(letter)));
        await widgetTester.pump(Duration(milliseconds: 100));
      }

      // allow all state changes from letter inputs to complete
      await widgetTester.pump(Duration(milliseconds: 400));

      // playedwords should contain the valid word
      // the new row should be a game row
      // the new row should start with last letter of the played word
      // current active letter position pointer should be 1 (since first letter at 0)
      // current score should include the played word length
      // current high score should include the played word length (when high score is 0)
      expect(gameInstance.playedWords, isNotEmpty);
      expect(
          await gameInstance
              .validateWord(gameInstance.playedWords.first.split('')),
          false);
      expect(
          gameInstance
              .currentGameGrid[gameInstance.currentGameRowPointer].first,
          gameInstance
              .playedWords.first[gameInstance.playedWords.first.length - 1]);
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
    }, tags: ["valid_word"]);
  }

  static void testGameEndUI() {
    testWidgets('Test game end UI', (widgetTester) async {
      await widgetTester.binding.setSurfaceSize(Size(400, 900));

      LainGame gameInstance = LainGame();

      // render home page with LainGame provider
      await widgetTester.pumpWidget(ChangeNotifierProvider(
          lazy: false,
          create: (context) => gameInstance,
          child: LainApp(
            initialRoute: "/StartScreen",
          )));

      // tap the elevated button to start the game and navigate to game page
      await widgetTester.tap(find.byKey(Key("start_game_button")));

      // wait for the game page frame to render and widgets to be initialized
      await widgetTester.pump(Duration(milliseconds: 500));

      // wait 10 seconds (0-9) tick for game to end
      await widgetTester.pump(Duration(seconds: 10));

      // final screen should be the current route after game end
      expect(RouteGenerator.currentRoute.value, "/FinalPageScreen");
    }, tags: ["game_end"]);
  }
}
