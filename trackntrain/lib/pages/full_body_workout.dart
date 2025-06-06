import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackntrain/components/end_workout.dart';
import 'package:trackntrain/components/modern_text_field.dart';
import 'package:trackntrain/components/stop_without_finishing.dart';
import 'package:trackntrain/providers/full_body_progress_provider.dart';
import 'package:trackntrain/providers/workout_providers.dart';

class FullBodyWorkout extends ConsumerStatefulWidget {
  const FullBodyWorkout({super.key});

  @override
  ConsumerState<FullBodyWorkout> createState() => _FullBodyWorkoutState();
}

class _FullBodyWorkoutState extends ConsumerState<FullBodyWorkout> {
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController maxWeightController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedExercises = ref.read(selectedExercisesListProvider);
      if (selectedExercises.isNotEmpty) {
        ref
            .read(workoutProgressProvider.notifier)
            .initializeWorkout(selectedExercises);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    setsController.dispose();
    repsController.dispose();
    maxWeightController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    final sets = int.tryParse(setsController.text) ?? 0;
    final reps = repsController.text
                          .split(',')
                          .map((e) => int.tryParse(e.trim()) ?? 0)
                          .toList();
    final weightList = maxWeightController.text
                         .split(',')
                         .map((e)=>double.tryParse(e.trim())?? 0.0)
                         .toList();

    ref
        .read(workoutProgressProvider.notifier)
        .updateCurrentExercise(sets: sets, reps: reps, weightsList: weightList);
  }

  void _completeExercise(int currentIndex) {
    final sets = int.tryParse(setsController.text) ?? 0;
    final reps = repsController.text
                          .split(',')
                          .map((e) => int.tryParse(e.trim()) ?? 0)
                          .toList();
    final weightsList=maxWeightController.text
                         .split(',')
                         .map((e)=>double.tryParse(e.trim())?? 0.0)
                         .toList();
      if(reps.length != sets) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Number of reps must match number of sets'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if(weightsList.length != sets) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Number of weights must match number of sets'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

    if (currentIndex >= ref.read(totalExercisesProvider) - 1) {
      WorkoutCompletionDialog.show(
        context,
        summaryItems: [
          WorkoutSummaryItem(
            value: '${ref.read(totalExercisesProvider)}',
            label: 'Exercises',
          ),
        ],
        onRestart: () {
          Navigator.of(context).pop();
          setsController.clear();
          repsController.clear();
          maxWeightController.clear();
          ref
              .read(workoutProgressProvider.notifier)
              .initializeWorkout(ref.read(selectedExercisesListProvider));
        },
      );
      print('Workout completed');
      print(ref.read(workoutProgressProvider));
      return;
    }

    if (sets > 0 && reps.isNotEmpty) {

      ref
          .read(workoutProgressProvider.notifier)
          .completeCurrentExercise(
            sets: sets,
            reps: reps,
            weightsList: weightsList,
          );
      setsController.clear();
      repsController.clear();
      maxWeightController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid sets and reps'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = ref.watch(currentExerciseProvider);
    final currentIndex = ref.watch(currentExerciseIndexProvider);
    final totalExercises = ref.watch(totalExercisesProvider);
    final isWorkoutCompleted = ref.watch(isWorkoutCompletedProvider);

    
    if (currentExercise == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Full Body Workout',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading workout...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Full Body Workout',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1), // changes position of shadow
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        // color: Theme.of(context).primaryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color.fromARGB(255, 247, 2, 2).withOpacity(0.2),
                            const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: Theme.of(context).primaryColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        currentExercise!.exerciseName,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(30, 247, 2, 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${currentIndex + 1}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const Text(
                            ' / ',
                            style: TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                          Text(
                            '$totalExercises',
                            style: TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.black.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How to Perform',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentExercise.howToPerform.isNotEmpty
                              ? currentExercise.howToPerform
                              : 'No instructions available',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Special Considerations',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentExercise.specialConsiderations.isNotEmpty
                              ? currentExercise.specialConsiderations
                              : 'No special considerations available',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Avoid if you have',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentExercise.avoidWhenUserHasFollowingIssues.isNotEmpty
                              ? currentExercise.avoidWhenUserHasFollowingIssues
                              : 'No specific conditions to avoid',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Text(
                                'WORKOUT LOG',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: Color.fromARGB(255, 247, 2, 2),
                                ),
                              ),
                            ),
                  
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: double.infinity),
                              child: ModernTextField(
                                label: 'Sets',
                                icon: Icons.format_list_numbered_rounded,
                                keyboardType: TextInputType.number,
                                controller: setsController,
                                onChanged: (_) => _updateProgress(),
                              ),
                            ),
                            const SizedBox(height: 16),
                  
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: double.infinity),
                              child: ModernTextField(
                                label: 'Reps',
                                icon: Icons.repeat_rounded,
                                keyboardType: TextInputType.number,
                                controller: repsController,
                                onChanged: (_) => _updateProgress(),
                              ),
                            ),
                            const SizedBox(height: 16),
                  
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: double.infinity),
                              child: ModernTextField(
                                label: 'Weights per set (comma separated)',
                                icon: Icons.fitness_center_rounded,
                                keyboardType: TextInputType.number,
                                suffixText: 'kg',
                                controller: maxWeightController,
                                onChanged: (_) => _updateProgress(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => StopWithoutFinishing(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromARGB(255, 247, 2, 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cancel, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'End Workout',
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
        
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _completeExercise(currentIndex),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 247, 2, 2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              currentIndex < totalExercises - 1
                                  ? Icons.next_plan
                                  : Icons.check,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              currentIndex < totalExercises - 1
                                  ? 'Next'
                                  : 'Finish',
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
