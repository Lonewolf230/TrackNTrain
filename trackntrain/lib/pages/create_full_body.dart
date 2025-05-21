

import 'package:flutter/material.dart';
import 'package:trackntrain/components/filters.dart';
import 'package:trackntrain/components/muscle_group_expansion.dart';
import 'package:trackntrain/components/order_config.dart';
import 'package:trackntrain/utils/split_exercises.dart';


class CreateFullBody extends StatefulWidget{
  const CreateFullBody({super.key});

  @override
  State<CreateFullBody> createState() => _CreateFullBodyState();
}

class _CreateFullBodyState extends State<CreateFullBody> {
  final Map<String,bool> selectedExercises={};
  final List<Map<String,dynamic>> selectedExercisesList=[];
  final Map<String,List<Map<String,dynamic>>> localMuscleSpecifcExercises=muscleSpecificExercises;
  Map<String,List<Map<String,dynamic>>> filteredExercises={};
  final List<Map<String,dynamic>> filters=[];
  bool filtersApplied=false;

    @override
  void initState() {
    super.initState();
    for (var muscleGroup in localMuscleSpecifcExercises.values) {
      for (var exercise in muscleGroup) {
        selectedExercises[exercise['exerciseName']] = false;
      }
    }
    for(var muscleGroup in localMuscleSpecifcExercises.entries) {
       filters.add({
        'muscleGroup':muscleGroup.key,
        'selected':false,
        'type':'muscle'
       });
    }
    filters.add({
      'muscleGroup':'No Equipment',
      'selected':false,
      'type':'equipment'
    });
  }

   void _applyFilters() {
    setState(() {
      final selectedMuscles = filters
          .where((f) => f['type'] == 'muscle' && f['selected'] == true)
          .map((f) => f['muscleGroup'])
          .toList();
      
      final noEquipmentSelected = filters
          .firstWhere((f) => f['muscleGroup'] == 'No Equipment')['selected'];
      
      filteredExercises = {};
      
      for (var entry in localMuscleSpecifcExercises.entries) {
        if (selectedMuscles.isNotEmpty && !selectedMuscles.contains(entry.key)) {
          continue;
        }
        
        final filteredExercisesInGroup = entry.value.where((exercise) {
          if (noEquipmentSelected) {
            final equipment = exercise['equipmentRequired'] ?? '';
            if (equipment.isNotEmpty) return false;
          }
          return true;
        }).toList();
        
        if (filteredExercisesInGroup.isNotEmpty) {
          filteredExercises[entry.key] = filteredExercisesInGroup;
        }
      }
      
      filtersApplied = selectedMuscles.isNotEmpty || noEquipmentSelected;
    });
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

  void _toggleFilter(String muscleGroup, bool value) {
    setState(() {
      final index=filters.indexWhere((filter)=>filter['muscleGroup'] == muscleGroup);
      if(index!=-1){
        filters[index]['selected']=value;
    }});
  }

  void _showFilterSheet(BuildContext context){
  showModalBottomSheet(
    context: context, 
    // isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Filters(
          filters: filters,
          toggleFilters: (muscleGroup, value) {
            _toggleFilter(muscleGroup, value);
            setModalState(() {});
          },
          onApply:(){
            Navigator.pop(context);
            _applyFilters();
          }
        );
      }
    )
  );
  }

  void _showOrderSheet(BuildContext context){
    showDialog(context: context, builder: (context){
      return OrderConfig(selectedExercisesList: selectedExercisesList,);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (filteredExercises.isEmpty) {
      filteredExercises = localMuscleSpecifcExercises;
    }
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
                  children: filteredExercises.entries.map((entry) {
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
                        _showOrderSheet(context);
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
                        print(filters);
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

