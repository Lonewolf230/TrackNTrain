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

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

admin.initializeApp();

export const helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

export const metaLogCreation = onSchedule("0 0 * * *", async (event)=>{
  logger.info("Scheduled function triggered", {event});
  try {
    const allUsersList=await admin.auth().listUsers();
    const users=allUsersList.users;
    logger.info(`Total users: ${users.length}`, {structuredData: true});

    const batch=admin.firestore().batch();

    for (const user of users) {
      try {
        const uid:string=user.uid;
        const today=new Date().toISOString().split("T")[0];
        const docRef=admin.firestore()
          .collection("userMetaLogs")
          .doc(`${uid}_${today}`);


        batch.set(docRef, {
          userId: uid,
          date: today,
          createdAt: admin.firestore.Timestamp.now(),
          hasWorkedOut: false,
          weightLog: null,
        });

        await batch.commit();
        logger.info(`Meta log created for user: ${uid}`,
          {structuredData: true});
      } catch (error) {
        logger.error(`Error creating meta log for user: 
            ${user.uid}`, {error});
      }
    }
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

  try {
    const docRef = admin.firestore().collection("userMetaLogs")
      .doc(`${userId}_${date}`);
    await docRef.set({
      userId,
      date,
      createdAt: admin.firestore.Timestamp.now(),
      hasWorkedOut: false,
      mealLogs: [],
      weightLog: null,
    });
    response.status(201).send("Meta log created");
  } catch (error) {
    logger.error(`Error creating meta log for user: ${userId}`, {error});
    response.status(500).send("Error creating meta log");
  }
});

export const cleanUp=onSchedule("0 0 1 * *",async(event)=>{
    logger.info("Scheduled cleanup function triggered", {event});
    try{
        await cleanUpFullBodyLogs();
        await cleanUpHiitLogs();
        await cleanUpWalkLogs();
        await cleanUpMealLogs();
        logger.info("Cleanup completed successfully");
    }
    catch(error){
        logger.error("Error during cleanup", {error});
    }
})

const cleanUpFullBodyLogs=async()=>{
    try {
        const today = new Date();
        const ninetyDaysAgo = new Date(today);
        ninetyDaysAgo.setDate(today.getDate() - 90);
        
        const snapshot = await admin.firestore()
            .collection("userFullBodyWorkouts")
            .where("createdAt", "<=", ninetyDaysAgo)
            .get();
        
        if (snapshot.empty) {
            logger.info("No full body logs to delete");
            return;
        }
        
        const batch = admin.firestore().batch();
        
        snapshot.forEach(doc => {
            batch.delete(doc.ref);
        });
        
        await batch.commit();
        logger.info("Old full body logs deleted successfully");
    } catch (error) {
        logger.error("Error deleting old full body logs", {error});
    }
}

const cleanUpHiitLogs=async()=>{
    try {
        const today = new Date();
        const ninetyDaysAgo = new Date(today);
        ninetyDaysAgo.setDate(today.getDate() - 90);
        
        const snapshot = await admin.firestore()
            .collection("userHiitWorkouts")
            .where("createdAt", "<=", ninetyDaysAgo)
            .get();
        
        if (snapshot.empty) {
            logger.info("No HIIT logs to delete");
            return;
        }
        
        const batch = admin.firestore().batch();
        
        snapshot.forEach(doc => {
            batch.delete(doc.ref);
        });
        
        await batch.commit();
        logger.info("Old HIIT logs deleted successfully");
    } catch (error) {
        logger.error("Error deleting old HIIT logs", {error});
    }
}

const cleanUpWalkLogs=async()=>{
    try {
        const today = new Date();
        const ninetyDaysAgo = new Date(today);
        ninetyDaysAgo.setDate(today.getDate() - 90);
        
        const snapshot = await admin.firestore()
            .collection("userWalkRecords")
            .where("createdAt", "<=", ninetyDaysAgo)
            .get();
        
        if (snapshot.empty) {
            logger.info("No walk logs to delete");
            return;
        }
        
        const batch = admin.firestore().batch();
        
        snapshot.forEach(doc => {
            batch.delete(doc.ref);
        });
        
        await batch.commit();
        logger.info("Old walk logs deleted successfully");
    } catch (error) {
        logger.error("Error deleting old walk logs", {error});
    }
}

const cleanUpMealLogs=async()=>{
    try {
        const today = new Date();
        const ninetyDaysAgo = new Date(today);
        ninetyDaysAgo.setDate(today.getDate() - 31);
        
        const snapshot = await admin.firestore()
            .collection("userMealLogs")
            .where("createdAt", "<=", ninetyDaysAgo)
            .get();
        
        if (snapshot.empty) {
            logger.info("No meal logs to delete");
            return;
        }
        
        const batch = admin.firestore().batch();
        
        snapshot.forEach(doc => {
            batch.delete(doc.ref);
        });
        
        await batch.commit();
        logger.info("Old meal logs deleted successfully");
    } catch (error) {
        logger.error("Error deleting old meal logs", {error});
    }
}


