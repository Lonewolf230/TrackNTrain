import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trackntrain/components/custom_snack_bar.dart';
import 'package:trackntrain/main.dart';
import 'package:trackntrain/providers/full_body_progress_provider.dart';
import 'package:trackntrain/utils/auth_service.dart';
import 'package:trackntrain/utils/classes.dart';
import 'package:trackntrain/utils/misc.dart';

Future<void> saveFullBody(
  List<ExerciseProgress> workoutData,
  {
  String? existingWorkoutId,
  String? name,
}) async {
  try {
    // print('Starting save');
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
    // print('Full body workout saved successfully with ID: ${fullBodyDoc.id}');
  } catch (e) {
    // print('Error saving full body workout: $e');
    showGlobalSnackBar(message: 'Error saving full body workout: $e', type: 'error');
  }
}

Future<void> changeUpdatedAt(String workoutId, String collectionName) async {
  try {
    final docRef = FirebaseFirestore.instance
        .collection(collectionName)
        .doc(workoutId);
    await docRef.update({'updatedAt': FieldValue.serverTimestamp()});
    // print(
    //   'Updated at timestamp changed successfully for workout ID: $workoutId',
    // );
  } catch (e) {
    // print('Error changing updated at timestamp: $e');
  }
}

Future<void> saveHiit(
  HIITWorkout workout,
  BuildContext context, {
  String? existingWorkoutId,
}) async {
  try {
    DocumentReference hiitDoc;
    if (existingWorkoutId != null) {
      hiitDoc = FirebaseFirestore.instance
          .collection('userHiitWorkouts')
          .doc(existingWorkoutId);
    } else {
      hiitDoc = FirebaseFirestore.instance.collection('userHiitWorkouts').doc();
    }
    DocumentSnapshot docSnapshot = await hiitDoc.get();
    await hiitDoc.set(
      workout.toFireStoreMap(isUpdate: docSnapshot.exists),
      SetOptions(merge: true),
    );
    // print('HIIT workout saved successfully with ID: ${hiitDoc.id}');
  } catch (e) {
    print('Error saving HIIT workout: $e');
    // showGlobalSnackBar(message: 'Error saving HIIT workout: $e', type: 'error');
  }
}

Future<void> deleteDoc(
  String docId,
  String collectionName,
  BuildContext context,
) async {
  try {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(docId)
        .delete();
    // print('Document deleted successfully from $collectionName with ID: $docId');
  } catch (e) {
    // print('Error deleting document: $e');
    if (context.mounted) {
      CustomSnackBar(message: 'Error deleting document: $e', type:'error').buildSnackBar(context);
    }
  }
}

Future<void> createWalk(BuildContext context, WalkData walkData) async {
  try {
    DocumentReference doc =
        FirebaseFirestore.instance.collection('userWalkRecords').doc();
    await doc.set(walkData.toFireStoreMap(), SetOptions(merge: true));
    // print('Walk data saved successfully with ID: ${doc.id}');
  } catch (e) {
    // print('Error saving walk data: $e');
    showGlobalSnackBar(message: 'Error saving walk data: $e', type: 'error');
  }
}

Future<void> createOrSaveMeal(Meal meal, BuildContext context) async {
  try {
    final userId = AuthService.currentUser?.uid;
    final today = DateTime.now().toIso8601String().split('T')[0];
    DocumentReference mealDoc = FirebaseFirestore.instance
        .collection('userMeals')
        .doc('$userId-$today');

    DocumentSnapshot docSnapshot = await mealDoc.get();


    final createdAtTimeStamp = Timestamp.fromDate(DateTime.now());

    final expireAt=Timestamp.fromDate(
      DateTime.now().add(const Duration(days: 90)),
    );

    final Map<String,dynamic> dataToSet={
      'userId':userId,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if(!docSnapshot.exists){
      dataToSet['expireAt']=expireAt;
      dataToSet['createdAt']=createdAtTimeStamp;
    }
    
    if (meal.mealType != 'Snack') {

      dataToSet[meal.mealType.toLowerCase()]=meal.toFireStoreMap();

      await mealDoc.set(
        dataToSet
      , SetOptions(merge: true));
    } else {
      final mealMap= meal.toFireStoreMap();
      await mealDoc.update({
        'snacks': FieldValue.arrayUnion([mealMap]),
        'userId':AuthService.currentUser?.uid ?? '',
        ...dataToSet
      });
    }
    
    if (!context.mounted) return;
  
  } catch (e) {
    // print('Error saving meal data: $e');
    rethrow;
  }
}


Future<void> updateWeightMeta(double weight)async{
  try {
    final userId=AuthService.currentUser?.uid;
    if(userId == null) {
      throw Exception('User not authenticated');
    }
    final String today = DateTime.now().toIso8601String().split('T')[0];

    DocumentReference docRef = FirebaseFirestore.instance
      .collection('userMetaLogs')
      .doc('${userId}_$today');


    
    DocumentSnapshot docSnapshot=await docRef.get();
    if(!docSnapshot.exists) {
      await docRef.set({
        'userId': userId,
        'date': today,
        'weight': weight,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'mood':null,
        'sleep': 0,
        'hasWorkedOut': false,
      }, SetOptions(merge: true));
      return;
    }

    if(docSnapshot.exists) {
      await docRef.update({
        'userId':userId,
        'weight': weight,
      });
    } 
  }on FirebaseException catch(e){
    if (e.code == 'unavailable') {
      throw Exception('Please connect to the internet');
    } else {
      throw Exception('Error updating weight meta: $e');
    }
  }
   catch (e) {
    throw Exception('Error updating weight meta: $e');
  }
}

Future<void> updateWorkoutStatus() async {
  try {
    final userId = AuthService.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    if (await hasWorkedOutToday()) {
      return;
    }

    final String today = DateTime.now().toIso8601String().split('T')[0];
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('userMetaLogs')
        .doc('${userId}_$today'); 

    await docRef.set({
      'hasWorkedOut': true,
      'updatedAt': FieldValue.serverTimestamp(),
      'userId': userId, 
      'date': today, 
    }, SetOptions(merge: true));

    await setHasWorkedOutToday(true);
    
  } catch (e) {
    throw Exception('Error updating workout status: $e');
  }
}

Future<void> updateMoodMeta(String mood) async {
  try {
    final userId = AuthService.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final String today = DateTime.now().toIso8601String().split('T')[0];

    DocumentReference docRef = FirebaseFirestore.instance
        .collection('userMetaLogs')
        .doc('${userId}_$today'); 

    await docRef.set({
      'mood': mood,
      'updatedAt': FieldValue.serverTimestamp(),
      'userId': userId, 
      'date': today, 
    }, SetOptions(merge: true));

  } catch (e) {
    throw Exception('Error updating mood meta: $e');
  }
}

Future<void> updateUserGoal(String goal) async{
  try {
    final userId = AuthService.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId);

    await docRef.set({
      'goal': goal,
      'updatedAt': FieldValue.serverTimestamp(),
      'userId': userId, 
    }, SetOptions(merge: true));
    await setGoal(goal);
  } catch (e) {
    throw Exception('Error updating user goal: $e');
  }
}

