import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trackntrain/components/custom_snack_bar.dart';
import 'package:trackntrain/main.dart';
import 'package:trackntrain/utils/auth_service.dart';
import 'package:trackntrain/utils/connectivity.dart';
import 'package:trackntrain/utils/db_util_funcs.dart';
import 'package:trackntrain/utils/misc.dart';

class MoodDropdown extends StatefulWidget {
  const MoodDropdown({super.key});

  @override
  State<MoodDropdown> createState() => _MoodDropdownState();
}

class _MoodDropdownState extends State<MoodDropdown> {
  String? _mood;
  bool _isLoading = false;
  Timer? _dayCheckTimer;
  String? _currentDay;
  final ConnectivityService _connectivityService = ConnectivityService();
  @override
  void initState() {
    super.initState();
    _currentDay = DateTime.now().toIso8601String().split('T')[0];
    _loadSavedMood();
    _startDayCheckTimer();
  }

  @override
  void dispose() {
    _dayCheckTimer?.cancel();
    super.dispose();
  }

  void _startDayCheckTimer() {
    _dayCheckTimer = Timer.periodic(const Duration(seconds: 120), (timer) {
      _checkForDayChange();
    });
  }

  Future<void> _checkForDayChange() async {
    final newDay = DateTime.now().toIso8601String().split('T')[0];
    if (newDay != _currentDay) {
      _currentDay = newDay;
      await checkAndResetDailyPrefs();
      if (mounted) {
        setState(() {
          _mood = null;
        });
        showGlobalSnackBar(message: 'Daily preferences reset. Mood cleared.', type: 'success');
      }
    }
  }


  Future<void> _loadSavedMood() async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _mood = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      String? mood = await getMood();

      if (mood == null || mood.isEmpty) {
        final docRef = FirebaseFirestore.instance
            .collection('userMetaLogs')
            .doc('${uid}_$today');
        
        final docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
          final docMap = docSnapshot.data() as Map<String, dynamic>?;
          mood = docMap?['mood'];
          
          if (mood != null && mood.isNotEmpty) {
            await setMood(mood);
          }
        }
      }

      if (mounted) {
        setState(() {
          _mood = mood;
          _isLoading = false;
        });
      }
    } catch (e) {
      // print("Error loading mood: $e");
      if (mounted) {
        setState(() {
          _mood = null;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveMood(String? value) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) return;

    if (value == null || value.isEmpty) {
      await removeMood();
      return;
    }
    

    final isConnected=await _connectivityService.checkAndShowError(context,'No internet connection : Cannot log to database');
    if(!isConnected){
      return;
    }

    try {
      // print('Saving to firestore: $value');
      await updateMoodMeta(value);
      // print('Saving to SharedPreferences: $value');
      await setMood(value);
      
      setState(() {
        _mood = value;
      });

      showGlobalSnackBar(message: 'Mood logged Successfully', type: 'success');
      
    } catch (e) {
      // print('Error saving mood: $e');
      showGlobalSnackBar(message: 'Error saving mood: $e', type: 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isLoading
          ? Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading mood...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontFamily: 'Poppins',
                    fontSize: 16,
                  ),
                ),
              ],
            )
          : DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<String>(
                  hint: Row(
                    children: [
                      Icon(
                        Icons.psychology_outlined,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Select your mood',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey[600],
                  ),
                  iconSize: 28.0,
                  dropdownColor: Colors.white,
                  value: _mood,
                  menuMaxHeight: 200,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'energetic',
                      child: Row(
                        children: [
                          Icon(Icons.flash_on, color: Colors.orange, size: 20),
                          SizedBox(width: 12),
                          Text('Energetic'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'sore',
                      child: Row(
                        children: [
                          Icon(Icons.healing, color: Colors.blue, size: 20),
                          SizedBox(width: 12),
                          Text('Sore'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'cannot',
                      child: Row(
                        children: [
                          Icon(
                            Icons.pause_circle_outline,
                            color: Colors.grey,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text("Won't be able to train"),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (String? value) {
                    _saveMood(value);
                  },
                ),
              ),
            ),
    );
  }
}