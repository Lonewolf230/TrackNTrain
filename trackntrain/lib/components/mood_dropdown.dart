import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trackntrain/utils/db_util_funcs.dart';
import 'package:trackntrain/utils/misc.dart';

class MoodDropdown extends StatefulWidget {
  const MoodDropdown({super.key});

  @override
  State<MoodDropdown> createState() => _MoodDropdownState();
}

class _MoodDropdownState extends State<MoodDropdown> {
  String? _mood;
  bool _isLoading = true;
  Timer? _dayCheckTimer;
  String? _currentDay;

  @override
  void initState() {
    super.initState();
    _loadSavedMood();
    _startDayCheckTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _dayCheckTimer?.cancel();
    super.dispose();
  }

  void _startDayCheckTimer(){
    _dayCheckTimer=Timer.periodic(const Duration(seconds: 120), (timer){
      _checkForDayChange();
    });
  }

  Future<void> _checkForDayChange()async{
    final newDay=DateTime.now().toIso8601String().split('T')[0];
    if(newDay!=_currentDay){
      _currentDay=newDay;
      await checkAndResetDailyPrefs();
      if(mounted){
        setState(() {
          _mood=null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: const Text('Daily preferences reset. Mood cleared.',style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    }
  }

  Future<void> _loadSavedMood() async {
    final prefs = await getPrefs();
    setState(() {
      _mood = prefs.getString('mood'); 
      _isLoading = false;
    });
  }

  Future<void> _saveMood(String? value) async {
    if (value == null || value.isEmpty){ 
      await removePref('mood');
      return;
    }
    
    try {
      updateMoodMeta(value);
      setMood(value);      
      setState(() {
        _mood = value;
      });
    } catch (e) {
      print('Error saving mood: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            
            content: Text('Error saving mood: $e',style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            )),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator(); 
    }

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
      child: DropdownButtonHideUnderline(
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
                    Icon(Icons.pause_circle_outline, color: Colors.grey, size: 20),
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