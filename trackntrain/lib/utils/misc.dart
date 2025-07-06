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
      await _audioPlayer.play(AssetSource('audio/beep.mp3'));
    } catch (e) {
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
  return hasWorked;
}

Future<void> setHasWorkedOut(bool value) async {
  final prefs = await getPrefs();
  final userId=AuthService.currentUser?.uid;
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
  await prefs.setString(key, mood);
}

Future<String?> getMood({String? userId, String? date}) async {
  final prefs = await getPrefs();
  final key = _getUserMoodKey(userId: userId, date: date);
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
  await prefs.setString(key, goal);
  print('Goal set successfully for user: $userId');
}

Future<String?> getGoal() async {
  final userId = AuthService.currentUser?.uid;
  if (userId == null) return null;
  final prefs = await getPrefs();
  final key = 'goal_$userId';
  final goal = prefs.getString(key);
  print('Goal retrieved: $goal');
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
  }
  else {
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
}

Future<List<String>> getActiveDates() async{
  final userId=AuthService.currentUser?.uid;
  if (userId == null) return [];
  final prefs=await getPrefs();
  final key = 'activeDates_$userId';
  final activeDates = prefs.getStringList(key) ?? [];
  return activeDates;
}

Future<void> setHeight(double height)async{
  final userId=AuthService.currentUser?.uid;
  if (userId == null) return;
  final prefs=await getPrefs();
  final key = 'height_$userId';
  await prefs.setDouble(key,height);
  print('Height set successfully for user: $userId');
}

Future<void> setWeight(double weight) async{
  final userId = AuthService.currentUser?.uid;
  if (userId == null) return;
  final prefs = await getPrefs();
  final key = 'weight_$userId';
  await prefs.setDouble(key, weight);
  print('Weight set successfully for user: $userId');
}

Future<void> setAge(String dob) async {
  final userId = AuthService.currentUser?.uid;
  if (userId == null) return;
  final prefs = await getPrefs();
  final key = 'dob_$userId';
  print('Setting DOB: $dob for user: $userId');
  await prefs.setString(key, dob);
  print('DOB set successfully for user: $userId');
}

Future<double?> getHeight() async {
  final userId = AuthService.currentUser?.uid;
  if (userId == null) return null;
  final prefs = await getPrefs();
  final key = 'height_$userId';
  final height = prefs.getDouble(key);
  print('Height retrieved: $height');
  return height;
}

Future<double?> getWeight() async {
  final userId = AuthService.currentUser?.uid;
  if (userId == null) return null;
  final prefs = await getPrefs();
  final key = 'weight_$userId';
  final weight = prefs.getDouble(key);
  print('Weight retrieved: $weight');
  return weight;
}

Future<DateTime?> getAge() async {
  final userId = AuthService.currentUser?.uid;
  if (userId == null) return null;
  
  final prefs = await getPrefs();
  final key = 'dob_$userId';
  final dob = prefs.getString(key);
  
  // Return null if no DOB is stored
  if (dob == null || dob.isEmpty) return null;
  
  final DateTime? dOB = parseDOBFromStorage(dob);
  print('DOB retrieved: $dOB');
  return dOB;
}

DateTime? parseDOBFromStorage(String dobString) {
  try {
    return DateTime.parse(dobString);
  } catch (e) {
    // Handle invalid date format gracefully
    print('Invalid date format: $dobString');
    return null;
  }
}

Future<void> clearWeeklyGoal() async{
  final userId = AuthService.currentUser?.uid;
  if (userId == null) return;
  final prefs = await getPrefs();
  final key = 'goal_$userId';
  if (prefs.containsKey(key)) {
    await prefs.remove(key);
  } else {
  }
}

Future<void> checkAndResetDailyPrefs() async {
  final prefs = await getPrefs();
  final today = DateTime.now().toIso8601String().split("T")[0];
  
  final lastReset = prefs.getString('globalLastResetDate');

  if (lastReset != today) {
    final allKeys = prefs.getKeys();
    
    for (final key in allKeys) {
      if (key.contains('hasWorkedOut_') && key.endsWith('_${DateTime.now().subtract(Duration(days: 1)).toIso8601String().split("T")[0]}')) {
        await prefs.remove(key);
      }
      if (key.contains('mood_') && key.endsWith('_${DateTime.now().subtract(Duration(days: 1)).toIso8601String().split("T")[0]}')) {
        await prefs.remove(key);
      }
      if(key.startsWith('activeDates_')) {
        await prefs.remove(key);
      }
      if(key.startsWith('height_') || key.startsWith('weight_') || key.startsWith('age_') || key.startsWith('goal_') || key.startsWith('goalDate_')) {
        continue;
      }
    }
    
    await prefs.setString('globalLastResetDate', today);
  } else {
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
  } else {
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
    await prefs.remove(key);
  }
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