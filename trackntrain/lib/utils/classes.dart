

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
