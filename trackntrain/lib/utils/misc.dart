import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioManager {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isInitialized = false;

  static Future<void> _initialize() async {
    if (!_isInitialized) {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      _isInitialized = true;
    }
  }

  static Future<void> playBeep() async {
    try {
      await _initialize();
      await _audioPlayer.play(AssetSource('audio/beep.mp3'));
    } catch (e) {
      print('Error playing beep: $e');
      // Fallback to system sound
      SystemSound.play(SystemSoundType.click);
    }
  }

  static void dispose() {
    _audioPlayer.dispose();
  }
}