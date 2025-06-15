

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> saveFcmToken(String userId) async{
  try {
    final fcmToken=await FirebaseMessaging.instance.getToken();
    if(fcmToken!=null){
      await FirebaseFirestore.instance.collection('users').doc(userId)
                    .set({
                      'fcmToken': fcmToken,
                    },SetOptions(merge: true));
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken){
      FirebaseFirestore.instance.collection('users').doc(userId)
                    .update({
                      'fcmToken':newToken
                    });
    });

  } catch (e) {
    print('Error saving FCM token: $e');
  }
}