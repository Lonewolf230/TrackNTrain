import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trackntrain/providers/full_body_progress_provider.dart';
import 'package:trackntrain/utils/auth_service.dart';
import 'package:trackntrain/utils/classes.dart';

Future<void> saveFullBody(
  List<ExerciseProgress> workoutData,
  BuildContext context, {
  String? existingWorkoutId,
  String? name,
}) async {
  try {
    print('Starting save');
    final FullBodyWorkout workout = FullBodyWorkout(
      userId: AuthService.currentUser?.uid ?? '',
      exercises:
          workoutData
              .map(
                (e) => FullBodyExercise(
                  exerciseName: e.exerciseName,
                  sets: e.sets,
                  reps: e.reps,
                  weightsList: e.weightsList,
                  howToPerform: e.howToPerform,
                  avoidWhenUserHasFollowingIssues:
                      e.avoidWhenUserHasFollowingIssues,
                  specialConsiderations: e.specialConsiderations,
                ),
              )
              .toList(),
      name: name,
    );

    DocumentReference fullBodyDoc;
    if (existingWorkoutId != null) {
      fullBodyDoc = FirebaseFirestore.instance
          .collection('userFullBodyWorkouts')
          .doc(existingWorkoutId);
    } else {
      fullBodyDoc =
          FirebaseFirestore.instance.collection('userFullBodyWorkouts').doc();
    }
    DocumentSnapshot docSnapshot = await fullBodyDoc.get();
    await fullBodyDoc.set(
      workout.toFirestoreMap(isUpdate: docSnapshot.exists),
      SetOptions(merge: true),
    );
    print('Full body workout saved successfully with ID: ${fullBodyDoc.id}');
  } catch (e) {
    print('Error saving full body workout: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving full body workout: $e')),
      );
    }
  }
}

Future<void> changeUpdatedAt(String workoutId,String collectionName) async {
  try {
    final docRef = FirebaseFirestore.instance
        .collection(collectionName)
        .doc(workoutId);
    await docRef.update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('Updated at timestamp changed successfully for workout ID: $workoutId');
  } catch (e) {
    print('Error changing updated at timestamp: $e');
  }

}

Future<void> saveHiit(HIITWorkout workout,BuildContext context,{String? existingWorkoutId})async{
  try{
    DocumentReference hiitDoc;
    if(existingWorkoutId!=null){
      hiitDoc=FirebaseFirestore.instance.collection('userHiitWorkouts').doc(existingWorkoutId);
    }
    else{
      hiitDoc=FirebaseFirestore.instance.collection('userHiitWorkouts').doc();
    }
    DocumentSnapshot docSnapshot = await hiitDoc.get();
    await hiitDoc.set(
      workout.toFireStoreMap(isUpdate: docSnapshot.exists),
      SetOptions(merge: true),
    );
    print('HIIT workout saved successfully with ID: ${hiitDoc.id}');
  }
  catch(e){
    print('Error saving HIIT workout: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving HIIT workout: $e')),
      );
    }
  }
}

Future<void> deleteDoc(String docId,String collectionName,BuildContext context)async{
  try{
    
    await FirebaseFirestore.instance.collection(collectionName).doc(docId).delete();
    print('Document deleted successfully from $collectionName with ID: $docId');
  }
  catch(e){
    print('Error deleting document: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting document: $e')),
      );
    }
  }
}

Future<void> createWalk(BuildContext context,WalkData walkData)async {
  try {
    DocumentReference doc=FirebaseFirestore.instance
        .collection('userWalkRecords')
        .doc();
    await doc.set(
      walkData.toFireStoreMap(),
      SetOptions(merge: true),
    );
    print('Walk data saved successfully with ID: ${doc.id}');
  } catch (e) {
    print('Error saving walk data: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving walk data: $e')),
      );
    }
  }
}