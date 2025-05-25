

// import 'package:flutter/material.dart';
// import 'package:trackntrain/components/filters.dart';
// import 'package:trackntrain/components/muscle_group_expansion.dart';
// import 'package:trackntrain/components/order_config.dart';
// import 'package:trackntrain/utils/split_exercises.dart';


// class CreateFullBody extends StatefulWidget{
//   const CreateFullBody({super.key});

//   @override
//   State<CreateFullBody> createState() => _CreateFullBodyState();
// }

// class _CreateFullBodyState extends State<CreateFullBody> {
//   final Map<String,bool> selectedExercises={};
//   final List<Map<String,dynamic>> selectedExercisesList=[];
//   final Map<String,List<Map<String,dynamic>>> localMuscleSpecifcExercises=muscleSpecificExercises;
//   Map<String,List<Map<String,dynamic>>> filteredExercises={};
//   final List<Map<String,dynamic>> filters=[];
//   bool filtersApplied=false;

//     @override
//   void initState() {
//     super.initState();
//     for (var muscleGroup in localMuscleSpecifcExercises.values) {
//       for (var exercise in muscleGroup) {
//         selectedExercises[exercise['exerciseName']] = false;
//       }
//     }
//     for(var muscleGroup in localMuscleSpecifcExercises.entries) {
//        filters.add({
//         'muscleGroup':muscleGroup.key,
//         'selected':false,
//         'type':'muscle'
//        });
//     }
//     filters.add({
//       'muscleGroup':'No Equipment',
//       'selected':false,
//       'type':'equipment'
//     });
//   }

//    void _applyFilters() {
//     setState(() {
//       final selectedMuscles = filters
//           .where((f) => f['type'] == 'muscle' && f['selected'] == true)
//           .map((f) => f['muscleGroup'])
//           .toList();
      
//       final noEquipmentSelected = filters
//           .firstWhere((f) => f['muscleGroup'] == 'No Equipment')['selected'];
      
//       filteredExercises = {};
      
//       for (var entry in localMuscleSpecifcExercises.entries) {
//         if (selectedMuscles.isNotEmpty && !selectedMuscles.contains(entry.key)) {
//           continue;
//         }
        
//         final filteredExercisesInGroup = entry.value.where((exercise) {
//           if (noEquipmentSelected) {
//             final equipment = exercise['equipmentRequired'] ?? '';
//             if (equipment.isNotEmpty) return false;
//           }
//           return true;
//         }).toList();
        
//         if (filteredExercisesInGroup.isNotEmpty) {
//           filteredExercises[entry.key] = filteredExercisesInGroup;
//         }
//       }
      
//       filtersApplied = selectedMuscles.isNotEmpty || noEquipmentSelected;
//     });
//   }


//   void _toggleExercise(Map<String,dynamic> exercise, bool isSelected) {
//       final Map<String,dynamic> finExercise = {
//         'exerciseName': exercise['exerciseName'],
//         'primaryMuscleGroup': exercise['primaryMuscleTargeted'],
//         'secondaryMuscleGroup': exercise['secondaryMusclesTargeted'],
//       };
//     if(isSelected) {
//       selectedExercisesList.add(finExercise);
//     } else {
//       selectedExercisesList.remove(finExercise);
//     }
//     setState(() {
//       selectedExercises[exercise['exerciseName']] = isSelected;
//     });
//   }

//   void _toggleFilter(String muscleGroup, bool value) {
//     setState(() {
//       final index=filters.indexWhere((filter)=>filter['muscleGroup'] == muscleGroup);
//       if(index!=-1){
//         filters[index]['selected']=value;
//     }});
//   }

//   void _showFilterSheet(BuildContext context){
//   showModalBottomSheet(
//     context: context, 
//     // isScrollControlled: true,
//     builder: (context) => StatefulBuilder(
//       builder: (BuildContext context, StateSetter setModalState) {
//         return Filters(
//           filters: filters,
//           toggleFilters: (muscleGroup, value) {
//             _toggleFilter(muscleGroup, value);
//             setModalState(() {});
//           },
//           onApply:(){
//             Navigator.pop(context);
//             _applyFilters();
//           }
//         );
//       }
//     )
//   );
//   }

//   void _showOrderSheet(BuildContext context){
//     showDialog(context: context, builder: (context){
//       return OrderConfig(selectedExercisesList: selectedExercisesList,);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (filteredExercises.isEmpty) {
//       filteredExercises = localMuscleSpecifcExercises;
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Create your Workout',
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Theme.of(context).primaryColor,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             const Text(
//               'Muscle Categories',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: filteredExercises.entries.map((entry) {
//                     return MuscleGroupExpansion(
//                       muscleGroup: entry.key,
//                       exercises: entry.value,
//                       selectedExercises: selectedExercises,
//                       onExerciseSelected: _toggleExercise,
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(0, 10, 0, 40),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ConstrainedBox(
//                     constraints: const BoxConstraints(
//                       maxWidth: 210,
//                       minWidth: 180,
//                     ),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         print('Start Workout');
//                         print('Selected Exercises: $selectedExercisesList');
//                         _showOrderSheet(context);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Theme.of(context).primaryColor,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 12,
//                         ),
//                       ),
//                       child: const Text(
//                         'Start Workout',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   ConstrainedBox(
//                     constraints: const BoxConstraints(
//                       maxWidth: 200,
//                       minWidth: 180,
//                     ),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         print(filters);
//                         _showFilterSheet(context);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 12,
//                         ),
//                         backgroundColor: Theme.of(context).primaryColor,
//                       ),
//                       child: const Text(
//                         'Filters',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   } 
// }

import 'package:flutter/material.dart';
import 'package:trackntrain/components/filters.dart';
import 'package:trackntrain/components/muscle_group_expansion.dart';
import 'package:trackntrain/components/order_config.dart';
import 'package:trackntrain/utils/split_exercises.dart';

class CreateFullBody extends StatefulWidget {
  const CreateFullBody({super.key});

  @override
  State<CreateFullBody> createState() => _CreateFullBodyState();
}

class _CreateFullBodyState extends State<CreateFullBody> {
  final Map<String, bool> selectedExercises = {};
  final List<Map<String, dynamic>> selectedExercisesList = [];
  final Map<String, List<Map<String, dynamic>>> localMuscleSpecifcExercises = muscleSpecificExercises;
  Map<String, List<Map<String, dynamic>>> filteredExercises = {};
  final List<Map<String, dynamic>> filters = [];
  bool filtersApplied = false;

  @override
  void initState() {
    super.initState();
    for (var muscleGroup in localMuscleSpecifcExercises.values) {
      for (var exercise in muscleGroup) {
        selectedExercises[exercise['exerciseName']] = false;
      }
    }
    for (var muscleGroup in localMuscleSpecifcExercises.entries) {
      filters.add({
        'muscleGroup': muscleGroup.key,
        'selected': false,
        'type': 'muscle'
      });
    }
    filters.add({
      'muscleGroup': 'No Equipment',
      'selected': false,
      'type': 'equipment'
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

  // void _toggleExercise(Map<String, dynamic> exercise, bool isSelected) {
  //   final Map<String, dynamic> finExercise = {
  //     'exerciseName': exercise['exerciseName'],
  //     'primaryMuscleGroup': exercise['primaryMuscleTargeted'],
  //     'secondaryMuscleGroup': exercise['secondaryMusclesTargeted'],
  //   };
  //   if (isSelected) {
  //     selectedExercisesList.add(finExercise);
  //   } else {
  //     selectedExercisesList.remove(finExercise);
  //   }
  //   setState(() {
  //     selectedExercises[exercise['exerciseName']] = isSelected;
  //   });
  // }

  void _toggleExercise(Map<String,dynamic> exercise,bool isSelected){
    final exerciseName= exercise['exerciseName'];
    setState(() {
      selectedExercises[exerciseName]=isSelected;
      if(isSelected){
        if(!selectedExercisesList.any((e)=>e['exerciseName']==exerciseName)){
          selectedExercisesList.add({
            'exerciseName': exerciseName,
            'primaryMuscleGroup': exercise['primaryMuscleTargeted'],
            'secondaryMuscleGroup': exercise['secondaryMusclesTargeted'],
          });
        }
      }
      else{
        selectedExercisesList.removeWhere((e) => e['exerciseName'] == exerciseName);
      }
    });
  }

  void _toggleFilter(String muscleGroup, bool value) {
    setState(() {
      final index = filters.indexWhere((filter) => filter['muscleGroup'] == muscleGroup);
      if (index != -1) {
        filters[index]['selected'] = value;
      }
    });
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Filters(
            filters: filters,
            toggleFilters: (muscleGroup, value) {
              _toggleFilter(muscleGroup, value);
              setModalState(() {});
            },
            onApply: () {
              Navigator.pop(context);
              _applyFilters();
            }
          );
        }));
  }

  void _showOrderSheet(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return OrderConfig(
            selectedExercisesList: selectedExercisesList,
          );
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
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 247, 2, 2),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: const Color.fromARGB(255, 247, 2, 2),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Muscle Categories',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select exercises for your workout',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedExercisesList.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 247, 2, 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${selectedExercisesList.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Exercises List
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
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
              ),
            ),

            // Action Buttons
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedExercisesList.isEmpty
                          ? null
                          : () {
                              print('Start Workout');
                              print('Selected Exercises: $selectedExercisesList');
                              _showOrderSheet(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 247, 2, 2),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.play_arrow, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Start Workout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        print(filters);
                        _showFilterSheet(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 247, 2, 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 247, 2, 2),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.filter_list, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          if (filtersApplied) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 247, 2, 2),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
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