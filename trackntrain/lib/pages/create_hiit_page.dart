import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:trackntrain/components/exercise_brief.dart';
import 'package:trackntrain/utils/hiit_exercises.dart';

class CreateHiitPage extends StatefulWidget {
  const CreateHiitPage({super.key});

  @override
  State<CreateHiitPage> createState() => _CreateHiitPageState();
}

class _CreateHiitPageState extends State<CreateHiitPage> {
  final List<bool> checkedStates = [];
  final List<Map<String, String>> finalExercises = [];
  late TextEditingController exerciseDurationController;
  late TextEditingController restDurationController;
  late TextEditingController roundsController;

  void displayConfigSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            'Workout Configuration',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: exerciseDurationController,
                  decoration: InputDecoration(
                    labelText: 'Exercise Duration (seconds)',
                    labelStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[400]!,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey[400]!,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: restDurationController,
                  decoration: InputDecoration(
                    labelText: 'Rest Duration (seconds)',
                    labelStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: roundsController,
                  decoration: InputDecoration(
                    labelText: 'Number of Rounds',
                    labelStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                // Save configuration
                Navigator.pop(context);
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
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceBetween,
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    checkedStates.addAll(List.filled(hiitExercises.length, false));
    exerciseDurationController = TextEditingController(text: '30');
    restDurationController = TextEditingController(text: '15');
    roundsController = TextEditingController(text: '5');
  }

  @override
  void dispose() {
    exerciseDurationController.dispose();
    restDurationController.dispose();
    roundsController.dispose();
    super.dispose();
  }

  void startWorkout() {
    print(finalExercises);
    final exerciseNames =
        finalExercises.map((e) => e['name'] as String).toList();
    context.goNamed(
      'hiit-started',
      queryParameters: {
        'rounds': roundsController.text,
        'rest': restDurationController.text,
        'work': exerciseDurationController.text,
      },
      extra: exerciseNames,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create HIIT Workout',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[50]!, Colors.white],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      247,
                      2,
                      2,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    size: 24,
                    FontAwesomeIcons.heartPulse,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Choose your preferred exercises',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                if (finalExercises.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${finalExercises.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                final exercise = hiitExercises[index];
                return ExerciseBrief(
                  title: exercise['name']!,
                  description: exercise['description']!,
                  specialConsiderations: exercise['special_considerations']!,
                  isChecked: checkedStates[index],
                  onChanged: (value) {
                    setState(() {
                      if (value!) {
                        finalExercises.add(exercise);
                      } else {
                        finalExercises.remove(exercise);
                      }
                      checkedStates[index] = value;
                    });
                  },
                );
              },
              itemCount: hiitExercises.length,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: finalExercises.isEmpty ? null : startWorkout,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[600],
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Start Workout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: displayConfigSettings,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1.5,
                      ),
                      elevation: 0,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Configure',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
