

import 'package:cloud_firestore/cloud_firestore.dart';

class UserData{
  final String userId;
  int? age;
  int? weight;
  int? height;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserData({required this.userId,this.age,this.weight,this.height,this.createdAt,this.updatedAt});

  Map<String,dynamic> toMap({bool isUpdate=false}){
    Map<String,dynamic> data={
      'userId': userId,
      'age': age,
      'weight': weight,
      'height': height,
      'updatedAt':FieldValue.serverTimestamp(),
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
  final int set;
  final List<int> reps;
  final List<double> weights;

  FullBodyExercise({
    required this.exerciseName,
    required this.set,
    required this.reps,
    required this.weights,
  });
  Map<String, dynamic> toMap() {
    return {
      'exerciseName': exerciseName,
      'set': set,
      'reps': reps,
      'weights': weights,
    };
  }
}


class FullBodyWorkout{
  final String userId;
  final List<FullBodyExercise> exercises;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? name;

  FullBodyWorkout({required this.exercises,required this.userId,this.createdAt, this.updatedAt,this.name});
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
    }
    return data;
  }
}
