

import 'package:flutter/material.dart';
import 'package:trackntrain/components/filters.dart';
import 'package:trackntrain/components/muscle_group_expansion.dart';
import 'package:trackntrain/utils/split_exercises.dart';


class CreateFullBody extends StatefulWidget{
  const CreateFullBody({super.key});

  @override
  State<CreateFullBody> createState() => _CreateFullBodyState();
}

class _CreateFullBodyState extends State<CreateFullBody> {
  final Map<String,bool> selectedExercises={};
  final List<Map<String,dynamic>> selectedExercisesList=[];
  final Map<String,List<Map<String,dynamic>>> muscleSpecifcExercises=muscleSpecificExercises;

    @override
  void initState() {
    super.initState();
    for (var muscleGroup in muscleSpecificExercises.values) {
      for (var exercise in muscleGroup) {
        selectedExercises[exercise['exerciseName']] = false;
      }
    }
  }

  void _toggleExercise(Map<String,dynamic> exercise, bool isSelected) {
      final Map<String,dynamic> finExercise = {
        'exerciseName': exercise['exerciseName'],
        'primaryMuscleGroup': exercise['primaryMuscleTargeted'],
        'secondaryMuscleGroup': exercise['secondaryMusclesTargeted'],
      };
    if(isSelected) {
      selectedExercisesList.add(finExercise);
    } else {
      selectedExercisesList.remove(finExercise);
    }
    setState(() {
      selectedExercises[exercise['exerciseName']] = isSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create your Workout',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Muscle Categories',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: muscleSpecificExercises.entries.map((entry) {
                    return MuscleGroupExpansion(
                      muscleGroup: entry.key,
                      exercises: entry.value,
                      selectedExercises: selectedExercises,
                      onExerciseSelected: _toggleExercise,
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 210,
                      minWidth: 180,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        print('Start Workout');
                        print('Selected Exercises: $selectedExercisesList');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Start Workout',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 200,
                      minWidth: 180,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        _showFilterSheet(context);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text(
                        'Filters',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } 
}

void _showFilterSheet(BuildContext context){
  showModalBottomSheet(
    context: context, 
    builder: (context)=>const Filters()
  );
}