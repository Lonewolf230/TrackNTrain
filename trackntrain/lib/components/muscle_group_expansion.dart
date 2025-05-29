import 'package:flutter/material.dart';

class MuscleGroupExpansion extends StatelessWidget {
  final String muscleGroup;
  final List<Map<String, dynamic>> exercises;
  final Map<String, bool> selectedExercises;
  final Function(Map<String, dynamic>, bool) onExerciseSelected;

  const MuscleGroupExpansion({
    super.key,
    required this.muscleGroup,
    required this.exercises,
    required this.selectedExercises,
    required this.onExerciseSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCount = exercises.where((exercise) => 
        selectedExercises[exercise['exerciseName']] == true).length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.fitness_center,
              color: const Color.fromARGB(255, 247, 2, 2),
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  muscleGroup.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              if (selectedCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 247, 2, 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$selectedCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
            ],
          ),
          children: exercises.map((exercise) {
            return ExerciseTile(
              exercise: exercise,
              isChecked: selectedExercises[exercise['exerciseName']] ?? false,
              onChanged: (value) => onExerciseSelected(
                exercise,
                value ?? false,
              ),
            );
          }).toList(),
        ),
      ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isChecked 
            ? const Color.fromARGB(255, 247, 2, 2).withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChecked 
              ? const Color.fromARGB(255, 247, 2, 2).withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Transform.scale(
          scale: 1.2,
          child: Checkbox.adaptive(
            activeColor: const Color.fromARGB(255, 247, 2, 2),
            checkColor: Colors.white,
            value: isChecked,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        title: Text(
          exercise['exerciseName'],
          style: TextStyle(
            fontWeight: isChecked ? FontWeight.w600 : FontWeight.w500,
            color: isChecked ? Colors.black87 : Colors.black87,
            fontFamily: 'Poppins',
            fontSize: 15,
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(
              Icons.info_outline,
              color: const Color.fromARGB(255, 247, 2, 2),
              size: 20,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    exercise['exerciseName'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(
                          'Primary Muscle',
                          exercise['primaryMuscleTargeted'],
                          Icons.my_location,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoSection(
                          'Secondary Muscles',
                          (exercise['secondaryMusclesTargeted'] != null &&
                                  exercise['secondaryMusclesTargeted'] is List &&
                                  exercise['secondaryMusclesTargeted'].isNotEmpty)
                              ? exercise['secondaryMusclesTargeted'].join(', ')
                              : 'None',
                          Icons.track_changes,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoSection(
                          'How to Perform',
                          exercise['howToPerform'],
                          Icons.play_circle_outline,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoSection(
                          'Special Considerations',
                          exercise['specialConsiderations'],
                          Icons.warning_amber_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoSection(
                          'Avoid if you have',
                          exercise['avoidWhenUserHasFollowingIssues'].join(', '),
                          Icons.health_and_safety,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoSection(
                          'Equipment Needed',
                          (exercise['equipmentRequired'] != null &&
                                  exercise['equipmentRequired'] is List &&
                                  exercise['equipmentRequired'].isNotEmpty)
                              ? exercise['equipmentRequired'].join(', ')
                              : 'None',
                          Icons.fitness_center,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 247, 2, 2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Got it',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: const Color.fromARGB(255, 247, 2, 2),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
