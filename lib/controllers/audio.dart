import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioController {
  static const String mutePrefsKey = "LAINMuteSharedPrefsKey";
  static ValueNotifier<bool> isMuted = ValueNotifier(false);

  static Future<void> toggleMute() async {
    isMuted.value = !isMuted.value;
    saveMuteStatus();
  }

  static Future<void> mute() async {
    isMuted.value = true;
    saveMuteStatus();
  }

  static Future<void> unmute() async {
    isMuted.value = false;
    saveMuteStatus();
  }

  static void playGameOverSound() async => !isMuted.value
      ? await AudioPlayer().play(AssetSource("sounds/time_up.mp3"))
      : "Muted";

  static void playInvalidWordSound() async => !isMuted.value
      ? await AudioPlayer().play(AssetSource("sounds/invalid_word.mp3"))
      : "Muted";

  static void playGameStartSound() async => !isMuted.value
      ? await AudioPlayer().play(AssetSource("sounds/game_win.mp3"))
      : "Muted";

  static void playValidWordSound() async => !isMuted.value
      ? await AudioPlayer().play(AssetSource("sounds/valid_word.mp3"))
      : "Muted";

  // read mute status from app key-value pair cache (SharedPreferences)
  static Future<void> readMuteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isMuted.value = prefs.getBool(mutePrefsKey) ?? false;
  }

  // save mute status to app key-value pair cache (SharedPreferences)
  static Future<void> saveMuteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(mutePrefsKey, isMuted.value);
  }
}
