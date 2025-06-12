

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackntrain/utils/auth_service.dart';

class ExerciseProgress {
  final String exerciseName;
  final String howToPerform;
  final String specialConsiderations;
  final String avoidWhenUserHasFollowingIssues;
  final int sets;
  final List<int> reps;
  final List<double> weightsList;
  final int currentExerciseIndex;
  final bool isCompleted;


  ExerciseProgress({
    required this.exerciseName,
    required this.howToPerform,
    required this.specialConsiderations,
    required this.avoidWhenUserHasFollowingIssues,
    this.sets=0,
    this.reps=const [],
    this.weightsList=const [],
    this.currentExerciseIndex=0,
    this.isCompleted=false,
  });

  ExerciseProgress copyWith({
    String? exerciseName,
    String? howToPerform,
    String? specialConsiderations,
    String? avoidWhenUserHasFollowingIssues,
    int? sets,
    List<int>? reps,
    List<double>? weightsList,
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
      weightsList: weightsList ?? this.weightsList,
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


factory ExerciseProgress.fromWorkoutSelectionReuse(Map<String,dynamic> exercise,int index){
  int sets = exercise['sets'] ?? exercise['set'] ?? 0;
  
  List<int> repsList = [];
  if (exercise['reps'] != null) {
    if (exercise['reps'] is List) {
      repsList = List<int>.from(exercise['reps']);
    } else if (exercise['reps'] is String) {
      repsList = exercise['reps']
          .toString()
          .split(',')
          .map((e) => int.tryParse(e.trim()) ?? 0)
          .toList();
    }
  }
  
  List<double> weightsList = [];
  if (exercise['weights'] != null || exercise['weightsList'] != null) {
    dynamic weights = exercise['weights'] ?? exercise['weightsList'];
    if (weights is List) {
      weightsList = weights.map((w) => (w as num).toDouble()).toList();
    } else if (weights is String) {
      weightsList = weights
          .toString()
          .split(',')
          .map((e) => double.tryParse(e.trim()) ?? 0.0)
          .toList();
    }
  }

  return ExerciseProgress(
    exerciseName: exercise['exerciseName'] ?? '',
    howToPerform: exercise['howToPerform'] ?? '',
    specialConsiderations: exercise['specialConsiderations'] ?? '',
    avoidWhenUserHasFollowingIssues: exercise['avoidWhenUserHasFollowingIssues'] ?? '',
    sets: sets,
    reps: repsList,
    weightsList: weightsList,
    currentExerciseIndex: index,
    isCompleted: exercise['isCompleted'] ?? false,
  );
}

  @override
  String toString() {
    // TODO: implement toString
    return 'ExerciseProgress(exerciseName: $exerciseName, howToPerform: $howToPerform, specialConsiderations: $specialConsiderations, avoidWhenUserHasFollowingIssues: $avoidWhenUserHasFollowingIssues, sets: $sets, reps: $reps, weightsList: $weightsList, currentExerciseIndex: $currentExerciseIndex, isCompleted: $isCompleted)';
  }
}

class WorkoutProgressState{
  final List<ExerciseProgress> exercises;
  final int currentExerciseIndex;
  final bool isWorkoutCompleted;
  final bool isReusedWorkout;


  const WorkoutProgressState({
    required this.exercises,
    this.currentExerciseIndex = 0,
    this.isWorkoutCompleted = false,
    this.isReusedWorkout = false,
  });

  WorkoutProgressState copyWith({
    List<ExerciseProgress>? exercises,
    int? currentExerciseIndex,
    bool? isWorkoutCompleted,
    bool? isReusedWorkout,
  }) {
    return WorkoutProgressState(
      exercises: exercises ?? this.exercises,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      isWorkoutCompleted: isWorkoutCompleted ?? this.isWorkoutCompleted,
      isReusedWorkout: isReusedWorkout ?? this.isReusedWorkout,
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
  List<String> get exerciseNames=>exercises.map((e)=>e.exerciseName).toList();

  @override
  String toString() {
    // TODO: implement toString
    return 'WorkoutProgressState(exercises: $exercises, currentExerciseIndex: $currentExerciseIndex, isWorkoutCompleted: $isWorkoutCompleted)';
  }
}

class WorkoutProgressNotifier extends StateNotifier<WorkoutProgressState>{
  WorkoutProgressNotifier():super(WorkoutProgressState(exercises: []));

  void initializeNewWorkout(List<Map<String,dynamic>> selectedExercises){
    final exercises=selectedExercises.asMap().entries
        .map((entry)=>ExerciseProgress.fromWorkoutSelection(entry.value,entry.key))
        .toList();

    state=WorkoutProgressState(
      exercises: exercises,
      currentExerciseIndex: 0,
      isWorkoutCompleted: false,
      isReusedWorkout: false,
    );
  }

  void initializeReusedWorkout(List<Map<String,dynamic>> selectedExercises){
    final exercises=selectedExercises.asMap().entries
        .map((entry)=>ExerciseProgress.fromWorkoutSelectionReuse(entry.value,entry.key))
        .toList();

    state=WorkoutProgressState(
      exercises: exercises,
      currentExerciseIndex: 0,
      isWorkoutCompleted: false,
      isReusedWorkout: true,
    );
  }

  void updateCurrentExercise({
    int? sets,
    List<int>? reps,
    List<double>? weightsList,
  }){
    if(state.currentExercise == null) return;
    final updatedExercises=List<ExerciseProgress>.from(state.exercises);
    final currentIndex=state.currentExerciseIndex;

    updatedExercises[currentIndex]=updatedExercises[currentIndex].copyWith(
      sets:sets,
      reps: reps,
      weightsList: weightsList,
    );

    state=state.copyWith(exercises: updatedExercises);
  }

  void completeCurrentExercise({
    required int sets,
    required List<int> reps,
    required List<double> weightsList,
  }){
    if(state.currentExercise == null) return;
    final updatedExercises=List<ExerciseProgress>.from(state.exercises);
    
    final currentIndex=state.currentExerciseIndex;

    updatedExercises[currentIndex]=updatedExercises[currentIndex].copyWith(
      sets: sets,
      reps: reps,
      weightsList: weightsList,
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

final exerciseNamesProvider = Provider<List<String>>((ref) {
  return ref.watch(workoutProgressProvider).exerciseNames;
});



