/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { getMessaging } from "firebase-admin/messaging";

admin.initializeApp();

export const helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

export const metaLogCreation = onSchedule({
  schedule:"0 0 * * *",
  timeZone: "Asia/Kolkata",
  timeoutSeconds:300,
  memory:'128MiB'
}, async (event)=>{
  logger.info("Scheduled function triggered", {event});
  try {
    const allUsersList=await admin.auth().listUsers();
    const users=allUsersList.users;
    logger.info(`Total users: ${users.length}`, {structuredData: true});
    if (users.length === 0) {
      logger.info("No users found to create meta logs", {structuredData: true});
      return;
    }
    let batch = admin.firestore().batch();
    let counter = 0;
    // const today = new Date().toISOString().split("T")[0]; in UTC but need in asia/kolkata timezone
    const today = new Intl.DateTimeFormat('en-CA', {
      timeZone: 'Asia/Kolkata',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    }).format(new Date());

    const ninetyDayInFutureTimeStamp=admin.firestore.Timestamp.fromDate(
      new Date(new Date().setDate(new Date().getDate() + 90))
    );
    for (const user of users) {
      try {
        const uid:string=user.uid;
        const docRef : admin.firestore.DocumentReference  =admin.firestore()
          .collection("userMetaLogs")
          .doc(`${uid}_${today}`);
        const docSnap : admin.firestore.DocumentSnapshot =await docRef.get();
        if (docSnap.exists) {
          logger.debug(`Meta log exists for ${uid}`);
          continue; 
        }

        const personalDoc : admin.firestore.DocumentReference =admin.firestore().collection("users").doc(uid);
        const personalDocSnap : admin.firestore.DocumentSnapshot =await personalDoc.get();
        let weight : number;
        if(!personalDocSnap.exists) {
          weight=0;
        }
        else{
          weight=personalDocSnap.get("weight");
        }
        batch.set(docRef, {
          userId: uid,
          date: today,
          createdAt: admin.firestore.Timestamp.now(),
          updatedAt: admin.firestore.Timestamp.now(),
          hasWorkedOut: false,
          mood:null,
          sleep:0,
          weight,
          expireAt: ninetyDayInFutureTimeStamp
        });
        counter++;
        if(counter>=500) {
          await batch.commit();
          logger.info("Batch of 500 meta logs created");
          counter = 0;
          batch = admin.firestore().batch(); 
        }

      } catch (error) {
        logger.error(`Error creating meta log for user: 
            ${user.uid}`, {error});
      }
    }
    if(counter > 0) {
      await batch.commit();
      logger.info(`Final batch of ${counter} meta logs created`);
    }
    logger.info("All meta logs created successfully", {structuredData: true});
  } catch (error) {
    logger.error("Error listing users:", {error});
  }
});


export const metaLogSpotCreation=onRequest(async (request, response) => {
  const {userId} = request.body;

  if (!userId ) {
    response.status(400).send("Missing userId");
    return;
  }

  const date = new Date().toISOString().split("T")[0];
  const todayTimeStamp= admin.firestore.Timestamp.fromDate(new Date());

  try {
    const docRef : admin.firestore.DocumentReference = admin.firestore().collection("userMetaLogs")
      .doc(`${userId}_${date}`);
    await docRef.set({
      userId,
      date,
      createdAt: admin.firestore.Timestamp.now(),
      hasWorkedOut: false,
      weight: 0,
      mood: null,
      sleep:0,
      expireAt:todayTimeStamp
    });
    response.status(201).send("Meta log created");
  } catch (error) {
    logger.error(`Error creating meta log for user: ${userId}`, {error});
    response.status(500).send("Error creating meta log");
  }
});


export const sendDailyReminder=onSchedule({
  schedule:"58 21 * * *",
  timeZone: "Asia/Kolkata",
  timeoutSeconds:120
},async(event)=>{

  // if(["Saturday", "Sunday"].includes(new Date().toLocaleDateString("en-US", { weekday: 'long' }))) {
  //   logger.info("Skipping reminder on weekends");
  //   return;
  // }
  

  const userMetaLogsSnapShot:admin.firestore.QuerySnapshot=await admin.firestore()
                                                      .collection("userMetaLogs")
                                                      .where("date", "==", new Date().toISOString().split("T")[0])
                                                      .where("hasWorkedOut", "==", false)
                                                      .get();
  const inactiveUsers=userMetaLogsSnapShot.docs.map((doc:admin.firestore.QueryDocumentSnapshot) => doc.data().userId);

  if(inactiveUsers.length===0){
    logger.info("No inactive users found for reminders");
    return;
  }

  const allUsers: admin.firestore.QuerySnapshot=await admin.firestore().collection("users").get();
  const inactiveUsersSet = new Set(inactiveUsers);                      
  
  const tokens:string[]=[];
  allUsers.forEach((doc:admin.firestore.QueryDocumentSnapshot) => {
    const userData = doc.data();
    if (inactiveUsersSet.has(doc.id)) {
      if(userData.fcmToken) tokens.push(userData.fcmToken);
      else logger.debug(`No FCM token for user: ${doc.id}`);
    }
  });


  if(tokens.length===0){
    logger.info("No users to send reminders to");
    return;
  }

  const message={
    notification:{
        title: "💪 Time to get moving!",
        body: "Don't forget to get some exercise before the day ends!",      
    },
    tokens
  }

  const response=await getMessaging().sendEachForMulticast(message);
  logger.info(`Success : ${response.successCount}, Fail: ${response.failureCount}`)
})


export const handleDeletetion=onRequest(async(request,response)=>{
  const {userId}=request.body;
  if (!userId) {
    response.status(400).send("Missing userId");
    return;
  }
  try {



  } catch (error) {
    
  }
})

// const handleMetaLogDeletion=async(userId:string)=>{}

// const handleFullBodyLogDeletion=async(userId:string)=>{}

// const handleHiitLogDeletion=async(userId:string)=>{}

// const handleWalkLogDeletion=async(userId:string)=>{}

// const handleMealLogDeletion=async(userId:string)=>{}


