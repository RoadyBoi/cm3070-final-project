import 'package:audioplayers/audioplayers.dart';

class AudioController {
  static void playGameStartSound() async =>
      await AudioPlayer().play(AssetSource("sounds/game_win.mp3"));
}
