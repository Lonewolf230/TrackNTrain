
import 'package:flutter/material.dart';

class MuscleGroupExpansion extends StatelessWidget {
  final String muscleGroup;
  final List<Map<String, dynamic>> exercises;
  final Map<String, bool> selectedExercises;
  final Function(Map<String,dynamic>, bool) onExerciseSelected;

  const MuscleGroupExpansion({
    super.key,
    required this.muscleGroup,
    required this.exercises,
    required this.selectedExercises,
    required this.onExerciseSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        muscleGroup.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      children:
          exercises.map((exercise) {
            return ExerciseTile(
              exercise: exercise,
              isChecked: selectedExercises[exercise['exerciseName']] ?? false,
              onChanged:
                  (value) => onExerciseSelected(
                    exercise,
                    value ?? false,
                  ),
            );
          }).toList(),
    );
  }
}

class ExerciseTile extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final bool isChecked;
  final Function(bool?) onChanged;

  const ExerciseTile({
    super.key,
    required this.exercise,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox.adaptive(
        activeColor: Theme.of(context).primaryColor,
        value: isChecked,
        onChanged: onChanged,
      ),
      horizontalTitleGap: 50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: Text(exercise['exerciseName']),
      trailing: IconButton(
        icon: const Icon(Icons.info_outline),
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(
                    exercise['exerciseName'],
                    textAlign: TextAlign.center,
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Primary Muscle: ${exercise['primaryMuscleTargeted']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                       const SizedBox(height: 10),
                       const Text(
                          'Secondary Muscles:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ), 
                       Text(
                          (exercise['secondaryMusclesTargeted'] != null && exercise['secondaryMusclesTargeted'] is List &&
                                  exercise['secondaryMusclesTargeted'].isNotEmpty)
                              ? exercise['secondaryMusclesTargeted'].join(', ')
                              : 'None',
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'How to Perform:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(exercise['howToPerform']),
                        const SizedBox(height: 10),
                        const Text(
                          'Special Considerations:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(exercise['specialConsiderations']),
                        const SizedBox(height: 10),
                        const Text(
                          'Avoid if you have:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          exercise['avoidWhenUserHasFollowingIssues'].join(
                            ', ',
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Equipment Needed:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          (exercise['equipmentRequired'] != null && exercise['equipmentRequired'] is List &&
                                  exercise['equipmentRequired'].isNotEmpty)
                              ? exercise['equipmentRequired'].join(', ')
                              : 'None',
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          );
        },
      ),
    );
  }
}
