import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trackntrain/providers/full_body_progress_provider.dart';
import 'package:trackntrain/utils/auth_service.dart';
import 'package:trackntrain/utils/classes.dart';

Future<void> saveFullBody(List<ExerciseProgress> workoutData,BuildContext context,{String? existingWorkoutId,String? name})async{
  try {
    print('Starting save');
    final FullBodyWorkout workout=FullBodyWorkout(
      userId: AuthService.currentUser?.uid ?? '',
      exercises: workoutData.map((e)=> FullBodyExercise(
        exerciseName: e.exerciseName, set: e.sets, reps: e.reps, weights: e.weightsList)).toList(),
      name: name,
    );

    DocumentReference fullBodyDoc;
    if(existingWorkoutId!=null){
      fullBodyDoc=FirebaseFirestore.instance.collection('userFullBodyWorkouts').doc(existingWorkoutId);
    } else {
      fullBodyDoc=FirebaseFirestore.instance.collection('userFullBodyWorkouts').doc();
    }
    DocumentSnapshot docSnapshot=await fullBodyDoc.get();
    await fullBodyDoc.set(workout.toFirestoreMap(isUpdate: docSnapshot.exists), SetOptions(merge: true));
    print('Full body workout saved successfully with ID: ${fullBodyDoc.id}');
  } catch (e) {
    print('Error saving full body workout: $e');
    if(context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving full body workout: $e')),
      );
    }
  }
}

