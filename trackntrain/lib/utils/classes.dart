

import 'package:cloud_firestore/cloud_firestore.dart';

class UserData{
  final String userId;
  int? age;
  int? weight;
  int? height;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastAIResponseAt;
  final String? lastAIResponse;

  UserData({required this.userId,this.age,this.weight,this.height,this.createdAt,this.updatedAt,
    this.lastAIResponseAt,this.lastAIResponse});

  Map<String,dynamic> toMap({bool isUpdate=false}){
    Map<String,dynamic> data={
      'userId': userId,
      'age': age,
      'weight': weight,
      'height': height,
      'updatedAt':FieldValue.serverTimestamp(),
      'lastAIResponseAt': null,
      'lastAIResponse': ''
    };

    if(!isUpdate){
      data['createdAt']=createdAt!=null?Timestamp.fromDate(createdAt!)
        :FieldValue.serverTimestamp(); 
    }
    return data;
  }
}

class FullBodyExercise{
  final String exerciseName;
  final int sets;
  final List<int> reps;
  final List<double> weightsList;
  final String? howToPerform;
  final String? specialConsiderations;  
  final String avoidWhenUserHasFollowingIssues;

  FullBodyExercise({
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.weightsList,
    this.howToPerform,
    this.specialConsiderations, 
    required this.avoidWhenUserHasFollowingIssues,
  });
  Map<String, dynamic> toMap() {
    return {
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'weightsList': weightsList,
      'howToPerform': howToPerform,
      'specialConsiderations': specialConsiderations,
      'avoidWhenUserHasFollowingIssues': avoidWhenUserHasFollowingIssues,
    };
  }
}


class FullBodyWorkout{
  final String userId;
  final List<FullBodyExercise> exercises;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? name;
  final Timestamp? expireAt;

  FullBodyWorkout({required this.exercises,required this.userId,this.createdAt, this.updatedAt,this.name,this.expireAt});
  Map<String, dynamic> toFirestoreMap({bool isUpdate = false}) {
    Map<String,dynamic> data= {
      'userId':userId,
      'name': name,
      'exercises':exercises.map((e)=>e.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!isUpdate) {
      data['createdAt'] = createdAt!=null? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp();
      data['expireAt'] = expireAt ?? Timestamp.fromDate(DateTime.now().add(const Duration(days: 90)));
    }
    return data;
  }
}



class HIITWorkout{
  final List<String> exercises;
  final int rounds;
  final int restDuration;
  final int workDuration;
  final String? name;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String userId;
  final Timestamp? expireAt;

  HIITWorkout({
    required this.exercises,
    required this.rounds,
    required this.restDuration,
    required this.workDuration,
    this.name,
    this.createdAt,
    this.updatedAt,
    required this.userId,
    this.expireAt,
  });

  Map<String,dynamic> toFireStoreMap({isUpdate=false}){
    Map<String,dynamic> data={
      'exercises': exercises,
      'rounds': rounds,
      'restDuration': restDuration,
      'workDuration': workDuration,
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
      'userId': userId,
    };
    if(!isUpdate){
      data['createdAt']=createdAt!=null?Timestamp.fromDate(createdAt!)
        :FieldValue.serverTimestamp();
      data['expireAt'] = expireAt ?? Timestamp.fromDate(DateTime.now().add(const Duration(days: 90)));
    }
    return data;
  }

}


class UserMetaLogs{
  final String userId;
  final bool? hasWorkedOut;
  final int? weight;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Timestamp? expireAt;
  UserMetaLogs({
    required this.userId,
    this.hasWorkedOut=false,
    this.weight,
    this.createdAt,
    this.updatedAt,
    this.expireAt
  });

  Map<String, dynamic> toFireStoreMap() {
    return {
      'userId': userId,
      'hasWorkedOut': hasWorkedOut,
      'weight': weight,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'expireAt': expireAt ?? Timestamp.fromDate(DateTime.now().add(const Duration(days: 90))),
    };
  }
}

class WalkData{
  final String userId;
  final double distance;
  final int elapsedTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double averageSpeed; 
  final Timestamp? expireAt;
  WalkData({
    required this.userId,
    required this.distance,
    required this.averageSpeed,
    required this.elapsedTime,
    this.createdAt,
    this.updatedAt,
    this.expireAt,
  });

  Map<String,dynamic> toFireStoreMap(){
    return {
      'userId': userId,
      'distance': distance,
      'averageSpeed': averageSpeed,
      'elapsedTime': elapsedTime,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'expireAt': expireAt ?? Timestamp.fromDate(DateTime.now().add(const Duration(days: 90))),
    };
  }
}

class Meal{
  final String mealType;
  final String mealName;
  final String? description;

  Meal({
    required this.mealType,
    required this.mealName,
    this.description,
  });

  Map<String, dynamic> toFireStoreMap() {
    return {
      'mealType': mealType,
      'mealName': mealName,
      'description': description,
    };
  }
}

class MealLogger {
  final String userId;
  final List<Meal> meals;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MealLogger({
    required this.userId,
    required this.meals,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestoreMap({bool isUpdate = false}) {
    Map<String, dynamic> data = {
      'userId': userId,
      'meals': meals.map((meal) => {
        'mealType': meal.mealType,
        'mealName': meal.mealName,
        'description': meal.description,
      }).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!isUpdate) {
      data['createdAt'] = createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp();
    }
    return data;
  }
}