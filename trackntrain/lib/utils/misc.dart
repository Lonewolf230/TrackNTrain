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
  final userId=AuthService.currentUser?.uid;
  final hasWorked=prefs.getBool('hasWorkedOut_$userId')?? false;
  print('Has worked out: $hasWorked');
  return hasWorked;
}

Future<void> setHasWorkedOut(bool value) async {
  final prefs = await getPrefs();
  final userId=AuthService.currentUser?.uid;
  print('Setting hasWorkedOut to: $value');
  await prefs.setBool('hasWorkedOut_$userId', value);
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

Future<void> setGoal(String goal)async{
  final userId=AuthService.currentUser?.uid;
  if (userId == null) return;
  final prefs=await getPrefs();
  final key = 'goal_$userId';
  final date = DateTime.now();
  final goalWeekNumber='${getWeekNumber(date)}';
  prefs.setString('goalWeek',goalWeekNumber);
  print('Setting goal to shared prefs');
  await prefs.setString(key, goal);
  print('Goal set for user $userId: $goal');
}

Future<String?> getGoal() async {
  final userId = AuthService.currentUser?.uid;
  if (userId == null) return null;
  final prefs = await getPrefs();
  final key = 'goal_$userId';
  print('Retrieving goal from shared prefs');
  final goal = prefs.getString(key);
  print('Retrieved goal for user $userId: $goal');
  return goal;
}

Future<void> clearGoal()async{
  final prefs=await getPrefs();
  final goalDate=prefs.getString('goalWeek');
  final userId=AuthService.currentUser?.uid;
  final DateTime today = DateTime.now();
  final currentWeekNumber = getWeekNumber(today);
  final goalWeekNumber = int.tryParse(goalDate ?? '0');
  if(goalWeekNumber!=currentWeekNumber){
    await prefs.remove('goalWeek');
    await prefs.remove('goal_$userId');
    print('Goal cleared for user $userId');
  }
  else {
    print('Goal is still valid for user $userId');
  }
}

int getWeekNumber(DateTime date) {
  final firstDayOfYear = DateTime(date.year, 1, 1);
  final daysOffset = firstDayOfYear.weekday - DateTime.monday;
  final firstMonday = firstDayOfYear.subtract(Duration(days: daysOffset));
  final diff = date.difference(firstMonday).inDays;
  return ((diff) / 7).ceil();
}

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

Future<bool> hasWorkedOutToday() async {
  return hasWorkedOut();
}

Future<void> setHasWorkedOutToday(bool value) async {
  await setHasWorkedOut(value);
}

Future<void> setActiveDates(List<String> activeDates)async{
  final userId=AuthService.currentUser?.uid;
  if (userId == null) return;
  final prefs=await getPrefs();
  final key = 'activeDates_$userId';
  await prefs.setStringList(key, activeDates);
  print('Active dates set for user $userId: $activeDates');
}

Future<List<String>> getActiveDates() async{
  final userId=AuthService.currentUser?.uid;
  if (userId == null) return [];
  final prefs=await getPrefs();
  final key = 'activeDates_$userId';
  final activeDates = prefs.getStringList(key) ?? [];
  print('Retrieved active dates for user $userId: $activeDates');
  return activeDates;
}

Future<void> setHeight(double height)async{
  final userId=AuthService.currentUser?.uid;
  if (userId == null) return;
  final prefs=await getPrefs();
  final key = 'height_$userId';
  print('Setting height for user $userId');
  await prefs.setDouble(key,height);
}

Future<void> setWeight(double weight) async{
  final userId = AuthService.currentUser?.uid;
  if (userId == null) return;
  final prefs = await getPrefs();
  final key = 'weight_$userId';
  print('Setting weight for user $userId');
  await prefs.setDouble(key, weight);
}

Future<void> setAge(double age) async {
  final userId = AuthService.currentUser?.uid;
  if (userId == null) return;
  final prefs = await getPrefs();
  final key = 'age_$userId';
  print('Setting age for user $userId');
  await prefs.setDouble(key, age);
}

Future<double?> getHeight() async {
  final userId = AuthService.currentUser?.uid;
  if (userId == null) return null;
  final prefs = await getPrefs();
  final key = 'height_$userId';
  final height = prefs.getDouble(key);
  print('Retrieved height for user $userId: $height');
  return height;
}

Future<double?> getWeight() async {
  final userId = AuthService.currentUser?.uid;
  if (userId == null) return null;
  final prefs = await getPrefs();
  final key = 'weight_$userId';
  final weight = prefs.getDouble(key);
  print('Retrieved weight for user $userId: $weight');
  return weight;
}

Future<double?> getAge() async {
  final userId = AuthService.currentUser?.uid;
  if (userId == null) return null;
  final prefs = await getPrefs();
  final key = 'age_$userId';
  final age = prefs.getDouble(key);
  print('Retrieved age for user $userId: $age');
  return age;
}

Future<void> clearWeeklyGoal() async{
  final userId = AuthService.currentUser?.uid;
  if (userId == null) return;
  final prefs = await getPrefs();
  final key = 'goal_$userId';
  if (prefs.containsKey(key)) {
    await prefs.remove(key);
    print('Weekly goal cleared for user $userId');
  } else {
    print('No weekly goal found for user $userId');
  }
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
      if(key.startsWith('activeDates_')) {
        await prefs.remove(key);
        print('Removed active dates for key: $key');
      }
      if(key.startsWith('height_') || key.startsWith('weight_') || key.startsWith('age_') || key.startsWith('goal_') || key.startsWith('goalDate_')) {
        continue;
      }
    }
    
    await prefs.setString('globalLastResetDate', today);
    print("Daily prefs reset for all users");
  } else {
    print("Already reset today");
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
  String type = 'success',
  bool disableCloseButton = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    CustomSnackBar(
      message: message,
      type: type,
      disableCloseButton: disableCloseButton,
    ).buildSnackBar(context),
  );
}