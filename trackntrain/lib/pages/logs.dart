

import 'package:flutter/material.dart';
import 'package:trackntrain/pages/workout_calendar_tab.dart';
import 'package:trackntrain/tabs/meal_logs.dart';
import 'package:trackntrain/tabs/mood_chart.dart';
import 'package:trackntrain/tabs/weight_chart.dart';

class EnergyLevelLogs extends StatefulWidget{
  const EnergyLevelLogs({super.key,required this.type});
  final String type;

  @override
  State<EnergyLevelLogs> createState() => _EnergyLevelLogsState();
}

class _EnergyLevelLogsState extends State<EnergyLevelLogs> {
  @override
  Widget build(BuildContext context) {

    Widget toBeDisplayed=
        widget.type == 'mood' ? const MoodTrackingScreen() :
        widget.type == 'weight' ? const WeightTrackingScreen() :
        widget.type == 'meal' ? const MealLogs():
        widget.type=='workout'? const WorkoutCalendarTab():
        const Center(child: Text('Invalid type'));

    return Scaffold(
      body: toBeDisplayed,
    );
  }
}