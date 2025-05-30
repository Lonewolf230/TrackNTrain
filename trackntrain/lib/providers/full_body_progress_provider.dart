

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseProgress {
  final String exerciseName;
  final String howToPerform;
  final String specialConsiderations;
  final String avoidWhenUserHasFollowingIssues;
  final int sets;
  final int reps;
  final double maxWeight;
  final int currentExerciseIndex;
  final bool isCompleted;

  ExerciseProgress({
    required this.exerciseName,
    required this.howToPerform,
    required this.specialConsiderations,
    required this.avoidWhenUserHasFollowingIssues,
    this.sets=0,
    this.reps=0,
    this.maxWeight=0.0,
    this.currentExerciseIndex=0,
    this.isCompleted=false,
  });

  ExerciseProgress copyWith({
    String? exerciseName,
    String? howToPerform,
    String? specialConsiderations,
    String? avoidWhenUserHasFollowingIssues,
    int? sets,
    int? reps,
    double? maxWeight,
    int? currentExerciseIndex,
    bool? isCompleted,
  }) {
    return ExerciseProgress(
      exerciseName: exerciseName ?? this.exerciseName,
      howToPerform: howToPerform ?? this.howToPerform,
      specialConsiderations: specialConsiderations ?? this.specialConsiderations,
      avoidWhenUserHasFollowingIssues: avoidWhenUserHasFollowingIssues ?? this.avoidWhenUserHasFollowingIssues,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      maxWeight: maxWeight ?? this.maxWeight,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory ExerciseProgress.fromWorkoutSelection(Map<String, dynamic> exercise,int index) {
    return ExerciseProgress(
      exerciseName: exercise['exerciseName'] ?? '',
      howToPerform: exercise['howToPerform'] ?? '',
      specialConsiderations: exercise['specialConsiderations'] ?? '',
      avoidWhenUserHasFollowingIssues: exercise['avoidWhenUserHasFollowingIssues'] ?? '',
      currentExerciseIndex: index
    );
  }
}

class WorkoutProgressState{
  final List<ExerciseProgress> exercises;
  final int currentExerciseIndex;
  final bool isWorkoutCompleted;

  WorkoutProgressState({
    required this.exercises,
    this.currentExerciseIndex = 0,
    this.isWorkoutCompleted = false,
  });

  WorkoutProgressState copyWith({
    List<ExerciseProgress>? exercises,
    int? currentExerciseIndex,
    bool? isWorkoutCompleted,
  }) {
    return WorkoutProgressState(
      exercises: exercises ?? this.exercises,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      isWorkoutCompleted: isWorkoutCompleted ?? this.isWorkoutCompleted,
    );
  }

  ExerciseProgress? get currentExercise{
    if(currentExerciseIndex>=0 && currentExerciseIndex<exercises.length){
      return exercises[currentExerciseIndex];
    } 
    return null;
  }

  int get totalExercises=>exercises.length;
  bool get hasNextExercise=> currentExerciseIndex < exercises.length-1;
}

class WorkoutProgressNotifier extends StateNotifier<WorkoutProgressState>{
  WorkoutProgressNotifier():super(WorkoutProgressState(exercises: []));

  void initializeWorkout(List<Map<String,dynamic>> selectedExercises){
    final exercises=selectedExercises.asMap().entries
        .map((entry)=>ExerciseProgress.fromWorkoutSelection(entry.value,entry.key))
        .toList();

    state=WorkoutProgressState(
      exercises: exercises,
      currentExerciseIndex: 0,
      isWorkoutCompleted: false,
    );
  }

  void updateCurrentExercise({
    int? sets,
    int? reps,
    double? maxWeight,
  }){
    if(state.currentExercise == null) return;
    final updatedExercises=List<ExerciseProgress>.from(state.exercises);
    final currentIndex=state.currentExerciseIndex;

    updatedExercises[currentIndex]=updatedExercises[currentIndex].copyWith(
      sets:sets,
      reps: reps,
      maxWeight: maxWeight,
    );

    state=state.copyWith(exercises: updatedExercises);
  }

  void completeCurrentExercise({
    required int sets,
    required int reps,
    required double maxWeight,
  }){
    if(state.currentExercise == null) return;
    final updatedExercises=List<ExerciseProgress>.from(state.exercises);
    
    final currentIndex=state.currentExerciseIndex;

    updatedExercises[currentIndex]=updatedExercises[currentIndex].copyWith(
      sets: sets,
      reps: reps,
      maxWeight: maxWeight,
      isCompleted: true,
    );

    final allCompleted = updatedExercises.every((exercise) => exercise.isCompleted);
    final nextIndex = state.hasNextExercise ? currentIndex + 1 : currentIndex;
    state=state.copyWith(
      exercises: updatedExercises,
      currentExerciseIndex: nextIndex,
      isWorkoutCompleted: allCompleted,
    );
  }

  void nextExercise(){
    if(state.hasNextExercise){
      state=state.copyWith(
        currentExerciseIndex: state.currentExerciseIndex + 1,
      );
    }
  }

  void endWorkout() {
    state = state.copyWith(
      isWorkoutCompleted: true,
    );
  }

  void resetWorkout(){
    state=WorkoutProgressState(exercises: []);
  }

}

final workoutProgressProvider = StateNotifierProvider<WorkoutProgressNotifier, WorkoutProgressState>((ref) {
  return WorkoutProgressNotifier();
});

final currentExerciseProvider = Provider<ExerciseProgress?>((ref) {
  return ref.watch(workoutProgressProvider).currentExercise;
});

final currentExerciseIndexProvider = Provider<int>((ref) {
  return ref.watch(workoutProgressProvider).currentExerciseIndex;
});

final totalExercisesProvider = Provider<int>((ref) {
  return ref.watch(workoutProgressProvider).totalExercises;
});

final isWorkoutCompletedProvider = Provider<bool>((ref) {
  return ref.watch(workoutProgressProvider).isWorkoutCompleted;
});

// final workoutProgressPercentageProvider = Provider<double>((ref) {
//   final state = ref.watch(workoutProgressProvider);
//   if (state.totalExercises == 0) return 0.0;
//   return (state.compl) / state.totalExercises ;
// });


