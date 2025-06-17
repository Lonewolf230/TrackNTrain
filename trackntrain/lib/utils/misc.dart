import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackntrain/components/custom_snack_bar.dart';
import 'package:trackntrain/utils/auth_service.dart';

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
  print('Has worked out: $hasWorked');
  return hasWorked;
}

Future<void> setHasWorkedOut(bool value) async {
  final prefs = await getPrefs();
  print('Setting hasWorkedOut to: $value');
  await prefs.setBool('hasWorkedOut', value);
}

String _getUserMoodKey({String? userId, String? date}) {
  final uid = userId ?? AuthService.currentUser?.uid ?? 'anonymous';
  final today = date ?? DateTime.now().toIso8601String().split('T')[0];
  return 'mood_${uid}_$today';
}

Future<void> setMood(String mood, {String? userId, String? date}) async {
  final prefs = await getPrefs();
  final key = _getUserMoodKey(userId: userId, date: date);
  print('Setting mood with key: $key');
  print('Mood to be set: $mood');
  await prefs.setString(key, mood);
}

Future<String?> getMood({String? userId, String? date}) async {
  final prefs = await getPrefs();
  final key = _getUserMoodKey(userId: userId, date: date);
  print('Retrieving mood with key: $key');
  print('Retreived Mood: ${prefs.getString(key)}');
  return prefs.getString(key);
}

Future<String?> getTodaysMood() async {
  return getMood();
}

Future<void> removeMood({String? userId, String? date}) async {
  final prefs = await getPrefs();
  final key = _getUserMoodKey(userId: userId, date: date);
  await prefs.remove(key);
}

// Future<void> checkAndResetDailyPrefs() async {
//   final prefs = await getPrefs();

//   final today = DateTime.now().toIso8601String().split("T")[0];
//   final lastReset = prefs.getString('lastResetDate');

//   if (lastReset != today) {
//     await prefs.setBool('hasWorkedOut', false);
//     await prefs.remove('mood');
//     await prefs.setString('lastResetDate', today);

//     print("Daily prefs reset");
//   } else {
//     print("Already reset today");
//   }
// }

// Future<void> removePref(String key)async{
//   final prefs = await getPrefs();
//   if (prefs.containsKey(key)) {
//     await prefs.remove(key);
//     print("Preference '$key' removed successfully.");
//   } else {
//     print("Preference '$key' does not exist.");
//   }
// }

String cleanErrorMessage(String error) {
  return error.replaceFirst('Exception:', '').trim();
}

Future<void> clearAllPrefs() async {
  final prefs = await getPrefs();
  await prefs.clear();
  print("All preferences cleared");
}


String _getUserDailyKey(String baseKey, {String? userId, String? date}) {
  final uid = userId ?? AuthService.currentUser?.uid ?? 'anonymous';
  final today = date ?? DateTime.now().toIso8601String().split('T')[0];
  return '${baseKey}_${uid}_$today';
}

String _getUserKey(String baseKey, {String? userId}) {
  final uid = userId ?? AuthService.currentUser?.uid ?? 'anonymous';
  return '${baseKey}_$uid';
}

// Updated workout tracking methods
// Future<bool> hasWorkedOut({String? userId, String? date}) async {
//   final prefs = await getPrefs();
//   final key = _getUserDailyKey('hasWorkedOut', userId: userId, date: date);
//   return prefs.getBool(key) ?? false;
// }

// Future<void> setHasWorkedOut(bool value, {String? userId, String? date}) async {
//   final prefs = await getPrefs();
//   final key = _getUserDailyKey('hasWorkedOut', userId: userId, date: date);
//   await prefs.setBool(key, value);
// }

// Convenience methods for today's workout
Future<bool> hasWorkedOutToday() async {
  return hasWorkedOut();
}

Future<void> setHasWorkedOutToday(bool value) async {
  await setHasWorkedOut(value);
}

Future<void> checkAndResetDailyPrefs() async {
  final prefs = await getPrefs();
  final today = DateTime.now().toIso8601String().split("T")[0];
  print('Initiating daily prefs reset for all users');
  
  final lastReset = prefs.getString('globalLastResetDate');

  if (lastReset != today) {
    final allKeys = prefs.getKeys();
    
    for (final key in allKeys) {
      if (key.contains('hasWorkedOut_') && key.endsWith('_${DateTime.now().subtract(Duration(days: 1)).toIso8601String().split("T")[0]}')) {
        await prefs.remove(key);
        print('Removed workout status for key: $key');
      }
      if (key.contains('mood_') && key.endsWith('_${DateTime.now().subtract(Duration(days: 1)).toIso8601String().split("T")[0]}')) {
        await prefs.remove(key);
        print('Removed mood for key: $key');
      }
    }
    
    await prefs.setString('globalLastResetDate', today);
    print("Daily prefs reset for all users");
  } else {
    print("Already reset today");
  }
}

Future<void> checkAndResetCurrentUserDailyPrefs() async {
  final prefs = await getPrefs();
  final uid = AuthService.currentUser?.uid;
  
  if (uid == null) return;
  
  final today = DateTime.now().toIso8601String().split("T")[0];
  final userResetKey = 'lastResetDate_$uid';
  final lastReset = prefs.getString(userResetKey);

  if (lastReset != today) {
    final yesterday = DateTime.now().subtract(Duration(days: 1)).toIso8601String().split("T")[0];
    
    await prefs.remove('hasWorkedOut_${uid}_$yesterday');
    await prefs.remove('mood_${uid}_$yesterday');
    
    await prefs.setString(userResetKey, today);
    print("Daily prefs reset for user: $uid");
  } else {
    print("Already reset today for current user");
  }
}

Future<void> removePref(String key, {String? userId, bool isDaily = false, String? date}) async {
  final prefs = await getPrefs();
  
  String actualKey;
  if (isDaily) {
    actualKey = _getUserDailyKey(key, userId: userId, date: date);
  } else {
    actualKey = _getUserKey(key, userId: userId);
  }
  
  if (prefs.containsKey(actualKey)) {
    await prefs.remove(actualKey);
    print("Preference '$actualKey' removed successfully.");
  } else {
    print("Preference '$actualKey' does not exist.");
  }
}

Future<void> removeCurrentUserPref(String key, {bool isDaily = false, String? date}) async {
  await removePref(key, isDaily: isDaily, date: date);
}

Future<void> clearCurrentUserPrefs() async {
  final prefs = await getPrefs();
  final uid = AuthService.currentUser?.uid;
  
  if (uid == null) return;
  
  final allKeys = prefs.getKeys();
  final keysToRemove = allKeys.where((key) => key.contains('_$uid')).toList();
  
  for (final key in keysToRemove) {
    print('Removing preference: $key');
    await prefs.remove(key);
  }
  
  print("All preferences cleared for current user");
}

void showCustomSnackBar({
  required BuildContext context,
  required String message,
  String type = 'success', // default to success
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    CustomSnackBar(
      message: message,
      type: type,
    ).buildSnackBar(context),
  );
}