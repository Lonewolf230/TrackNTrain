

import 'package:flutter/material.dart';
import 'package:trackntrain/components/workout_calendar.dart';

class WorkoutCalendarTab extends StatelessWidget{

  const WorkoutCalendarTab({super.key});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workout Calendar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          const MonthlyScreen(),
        ],
      ),
    );
    
  }
}