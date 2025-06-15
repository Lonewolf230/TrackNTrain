import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      print('Playing beep sound');
      await _audioPlayer.play(AssetSource('audio/beep.mp3'));
      print('Beep sound played successfully');
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

Future<SharedPreferences> getPrefs()async{
  SharedPreferences prefs=await SharedPreferences.getInstance();
  return prefs;
}

Future<bool> hasWorkedOut() async{
  final prefs=await getPrefs();
  final hasWorked=prefs.getBool('hasWorkedOut')?? false;
  return hasWorked;
}

Future<void> setHasWorkedOut(bool value) async {
  final prefs = await getPrefs();
  await prefs.setBool('hasWorkedOut', value);
}

Future<void> setMood(String mood) async {
  final prefs = await getPrefs();
  await prefs.setString('mood', mood);
}

Future<String?> getMood() async{
  final prefs = await getPrefs();
  return prefs.getString('mood');
}

Future<void> checkAndResetDailyPrefs() async {
  final prefs = await getPrefs();

  final today = DateTime.now().toIso8601String().split("T")[0];
  final lastReset = prefs.getString('lastResetDate');

  if (lastReset != today) {
    await prefs.setBool('hasWorkedOut', false);
    await prefs.remove('mood');
    await prefs.setString('lastResetDate', today);

    print("Daily prefs reset");
  } else {
    print("Already reset today");
  }
}

Future<void> setName(String name) async {
  final prefs = await getPrefs();
  await prefs.setString('name', name);
}

Future<String> getName() async{
  final prefs = await getPrefs();
  String? name = prefs.getString('name');
  return name ?? "User";
}

Future<void> removePref(String key)async{
  final prefs = await getPrefs();
  if (prefs.containsKey(key)) {
    await prefs.remove(key);
    print("Preference '$key' removed successfully.");
  } else {
    print("Preference '$key' does not exist.");
  }
}

String cleanErrorMessage(String error) {
  return error.replaceFirst('Exception:', '').trim();
}

Future<void> clearAllPrefs() async {
  final prefs = await getPrefs();
  await prefs.clear();
  print("All preferences cleared");
}