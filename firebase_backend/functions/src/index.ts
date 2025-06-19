/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
// import { defineString } from "firebase-functions/params";
// import OpenAI from "openai";

admin.initializeApp();

// const openAIKey = defineString("OPENAI_API_KEY");

export const helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", { structuredData: true });
  response.send("Hello from Firebase!");
});

export const metaLogCreation = onSchedule(
  {
    schedule: "0 0 * * *",
    timeZone: "Asia/Kolkata",
    timeoutSeconds: 300,
    memory: "128MiB",
  },
  async (event) => {
    logger.info("Scheduled function triggered", { event });
    try {
      const allUsersList = await admin.auth().listUsers();
      const users = allUsersList.users;
      logger.info(`Total users: ${users.length}`, { structuredData: true });
      if (users.length === 0) {
        logger.info("No users found to create meta logs", {
          structuredData: true,
        });
        return;
      }
      let batch = admin.firestore().batch();
      let counter = 0;
      // const today = new Date().toISOString().split("T")[0]; in UTC but need in asia/kolkata timezone
      const today = new Intl.DateTimeFormat("en-CA", {
        timeZone: "Asia/Kolkata",
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
      }).format(new Date());

      const ninetyDayInFutureTimeStamp = admin.firestore.Timestamp.fromDate(
        new Date(new Date().setDate(new Date().getDate() + 90))
      );
      for (const user of users) {
        try {
          const uid: string = user.uid;
          const docRef: admin.firestore.DocumentReference = admin
            .firestore()
            .collection("userMetaLogs")
            .doc(`${uid}_${today}`);
          const docSnap: admin.firestore.DocumentSnapshot = await docRef.get();
          if (docSnap.exists) {
            logger.debug(`Meta log exists for ${uid}`);
            continue;
          }

          const prevDayMetaDoc: admin.firestore.Query = admin
            .firestore()
            .collection("userMetaLogs")
            .where("userId", "==", uid)
            .where(
              "createdAt",
              "==",
              admin.firestore.Timestamp.fromDate(
                new Date(new Date().setDate(new Date().getDate() - 1))
              )
            );
          const prevDayMetaDocsSnap: admin.firestore.QuerySnapshot =
            await prevDayMetaDoc.get();
          let weight: number;
          if (!prevDayMetaDocsSnap.empty) {
            weight = 0;
          } else {
            weight = prevDayMetaDocsSnap.docs[0].get("weight");
          }
          batch.set(docRef, {
            userId: uid,
            date: today,
            createdAt: admin.firestore.Timestamp.now(),
            updatedAt: admin.firestore.Timestamp.now(),
            hasWorkedOut: false,
            mood: null,
            weight,
            expireAt: ninetyDayInFutureTimeStamp,
          });
          counter++;
          if (counter >= 500) {
            await batch.commit();
            logger.info("Batch of 500 meta logs created");
            counter = 0;
            batch = admin.firestore().batch();
          }
        } catch (error) {
          logger.error(
            `Error creating meta log for user: 
            ${user.uid}`,
            { error }
          );
        }
      }
      if (counter > 0) {
        await batch.commit();
        logger.info(`Final batch of ${counter} meta logs created`);
      }
      logger.info("All meta logs created successfully", {
        structuredData: true,
      });
    } catch (error) {
      logger.error("Error listing users:", { error });
    }
  }
);

export const metaLogSpotCreation = onRequest(async (request, response) => {
  const { userId } = request.body;

  if (!userId) {
    response.status(400).send("Missing userId");
    return;
  }

  const date = new Date().toISOString().split("T")[0];
  const todayTimeStamp = admin.firestore.Timestamp.fromDate(new Date());

  try {
    const docRef: admin.firestore.DocumentReference = admin
      .firestore()
      .collection("userMetaLogs")
      .doc(`${userId}_${date}`);
    await docRef.set({
      userId,
      date,
      createdAt: admin.firestore.Timestamp.now(),
      hasWorkedOut: false,
      weight: 63,
      mood: null,
      sleep: 0,
      expireAt: todayTimeStamp,
    });
    response.status(201).send("Meta log created");
  } catch (error) {
    logger.error(`Error creating meta log for user: ${userId}`, { error });
    response.status(500).send("Error creating meta log");
  }
});

export const handleDeletion = onRequest(
  { timeoutSeconds: 180 },
  async (request, response) => {
    const { userId } = request.body;
    if (!userId) {
      response.status(400).send("Missing userId");
      return;
    }
    try {
      const userMetaLogsRef: admin.firestore.CollectionReference = admin
        .firestore()
        .collection("userMetaLogs");
      const userDocRef: admin.firestore.DocumentReference = admin
        .firestore()
        .collection("users")
        .doc(userId);
      const userMealLogsRef: admin.firestore.Query<admin.firestore.DocumentData> =
        admin
          .firestore()
          .collection("userMealLogs")
          .where("userId", "==", userId);
      const userFullBodyLogsRef: admin.firestore.Query<admin.firestore.DocumentData> =
        admin
          .firestore()
          .collection("userFullBodyLogs")
          .where("userId", "==", userId);
      const userHiitLogsRef: admin.firestore.Query<admin.firestore.DocumentData> =
        admin
          .firestore()
          .collection("userHiitLogs")
          .where("userId", "==", userId);
      const userWalkLogsRef: admin.firestore.Query<admin.firestore.DocumentData> =
        admin
          .firestore()
          .collection("userWalkLogs")
          .where("userId", "==", userId);

      const batch = admin.firestore().batch();

      batch.delete(userDocRef);

      (await userMealLogsRef.get()).docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      (await userFullBodyLogsRef.get()).docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      (await userHiitLogsRef.get()).docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      (await userWalkLogsRef.get()).docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      (await userMetaLogsRef.get()).docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();

      logger.info(
        `Successfully deleted logs and user document for user: ${userId}`
      );
      response.status(200).send("Logs and user document deleted successfully");
    } catch (error) {
      logger.error(`Error deleting logs for user: ${userId}`, { error });
      response.status(500).send("Error deleting logs");
    }
  }
);

export const getAIInsights = onRequest(
  {
    timeoutSeconds: 300,
    memory: "128MiB",
    // secrets: [openAIKey],
  },
  async (request, response) => {
    const { userId } = request.body;

    if (userId === undefined || userId === null) {
      response.status(400).send("Missing userId");
      return;
    }

    // console.log("Timestamp:", admin.firestore.Timestamp);
    // console.log("fromDate function:", admin.firestore.Timestamp.fromDate);

    const metaData=await getWeeklyMetaData(userId);
    const mealData=await getWeeklyMealData(userId);
    if (!metaData || !mealData) {
      response.status(404).send("Please log your meals, weight and mood consistently to get a proper feedback");
      return;
    }

    const weightsData : number[]=metaData.map((log) => log.weight);
    const moodData: (string | null)[] = metaData.map((log) => log.mood);
    const mealsData: any[] = mealData.map((log) => log.meals);

    const weightsSummary = preprocessWeights(weightsData);
    const moodSummary = preprocessMood(moodData);
    const mealsSummary = preprocessMeals(mealsData);

    const userDoc:admin.firestore.DocumentReference=admin.firestore().collection("users").doc(userId);
    const userDocSnap:admin.firestore.DocumentSnapshot=await userDoc.get();
    
    const userGoal:string = userDocSnap.exists? userDocSnap.get("goal") : "No goal set";

    const prompt=generatePrompt({
      weightSummary:{message: weightsSummary.message || 'No weight data available'},
      moodSummary:{message: moodSummary.message || 'No mood data available'},
      mealSummary: {message: mealsSummary.message || 'No meal data available'},
      userGoal: userGoal, 
    })

    // const client = new OpenAI({
    //   apiKey: openAIKey.value(),
    // });

    try {
      // const res=await client.chat.completions.create({
      //   model:'gpt-3.5-turbo',
      //   messages:[{role: 'user', content: prompt}],
      //   temperature: 0.7,
      // })

      // const aiResponse = res.choices[0].message.content;
      logger.info("AI response generated successfully", { structuredData: true });
      // await userDoc.set({
      //   lastAIResponse: aiResponse,
      //   lastAIResponseAt: admin.firestore.Timestamp.now(),
      // }, { merge: true });
      response.status(200).send({
        prompt,
        weightSummary: weightsSummary,
        moodSummary: moodSummary,
        mealSummary: mealsSummary,
        userGoal: userGoal,
      });
    } catch (error) {
      logger.error("Error generating AI response", { error });
      response.status(500).send("Error generating AI response");
    }
  }
);

const getWeeklyMetaData = async (userId: string) => {
  const today = new Date();

  // const startofPrevWeek = new Date(today);
  // startofPrevWeek.setDate(today.getDate() - today.getDay() - 7);
  // startofPrevWeek.setHours(0, 0, 0, 0);
  // const endofPrevWeek = new Date(today);
  // endofPrevWeek.setDate(today.getDate() - today.getDay() - 1);
  // endofPrevWeek.setHours(23, 59, 59, 999);
    const dayOfWeek = today.getDay();
  // Calculate how many days since last Monday
  const daysSinceMonday = (dayOfWeek + 6) % 7;
  // Start of previous week: last Monday - 7 days
  const startOfPrevWeek = new Date(today);
  startOfPrevWeek.setDate(today.getDate() - daysSinceMonday - 7);
  startOfPrevWeek.setHours(0, 0, 0, 0);
  // End of previous week: last Sunday (yesterday if today is Monday)
  const endOfPrevWeek = new Date(today);
  endOfPrevWeek.setDate(today.getDate() - daysSinceMonday - 1);
  endOfPrevWeek.setHours(23, 59, 59, 999);

  const metaLogsRef = admin
    .firestore()
    .collection("userMetaLogs")
    .where("userId", "==", userId)
    .where(
      "createdAt",
      ">=",
      admin.firestore.Timestamp.fromDate(startOfPrevWeek)
    )
    .where(
      "createdAt",
      "<=",
      admin.firestore.Timestamp.fromDate(endOfPrevWeek)
    );

  const metaLogsSnapshot = await metaLogsRef.get();
  if (metaLogsSnapshot.empty) {
    logger.info(`No meta logs found for user: ${userId} in the previous week`);
    return null;
  }

  const metaLogsData = metaLogsSnapshot.docs.map((doc) => {
    const data = doc.data();
    return {
      date: data.date,
      hasWorkedOut: data.hasWorkedOut,
      mood: data.mood,
      weight: data.weight,
    };
  });
  if (metaLogsData.length === 0) {
    logger.info(`No meta logs found for user: ${userId} in the previous week`);
    return null;
  }
  logger.info(
    `Retrieved ${metaLogsData.length} meta logs for user: ${userId} in the previous week`,
    { structuredData: true }
  );
  return metaLogsData;
};

const getWeeklyMealData = async (userId: string) => {
  const today = new Date();

  // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  const dayOfWeek = today.getDay();
  // Calculate how many days since last Monday
  const daysSinceMonday = (dayOfWeek + 6) % 7;
  // Start of previous week: last Monday - 7 days
  const startOfPrevWeek = new Date(today);
  startOfPrevWeek.setDate(today.getDate() - daysSinceMonday - 7);
  startOfPrevWeek.setHours(0, 0, 0, 0);
  // End of previous week: last Sunday (yesterday if today is Monday)
  const endOfPrevWeek = new Date(today);
  endOfPrevWeek.setDate(today.getDate() - daysSinceMonday - 1);
  endOfPrevWeek.setHours(23, 59, 59, 999);

  logger.debug(
    `Fetching meal logs for user: ${userId} from ${startOfPrevWeek.toISOString()} to ${endOfPrevWeek.toISOString()}`,
    { structuredData: true }
  );

  const mealLogsRef = admin
    .firestore()
    .collection("userMeals")
    .where("userId", "==", userId)
    .where(
      "createdAt",
      ">=",
      admin.firestore.Timestamp.fromDate(startOfPrevWeek)
    )
    .where(
      "createdAt",
      "<=",
      admin.firestore.Timestamp.fromDate(endOfPrevWeek)
    );

  const mealLogsSnapshot = await mealLogsRef.get();
  if (mealLogsSnapshot.empty) {
    logger.info(`No meal logs found for user: ${userId} in the previous week`);
    return null;
  }

  const mealLogsData = mealLogsSnapshot.docs.map((doc) => {
    const data = doc.data();
    return {
      date: data.date,
      meals: data.meals,
    };
  });
  if (mealLogsData.length === 0) {
    logger.info(`No meal logs found for user: ${userId} in the previous week`);
    return null;
  }
  logger.info(
    `Retrieved ${mealLogsData.length} meal logs for user: ${userId} in the previous week`,
    { structuredData: true }
  );
  return mealLogsData;
};

const preprocessWeights = (weights: number[]) => {
  if (weights.length === 0) {
    return {
      min: 0,
      max: 0,
      average: 0,
    };
  }

  const min = Math.min(...weights);
  const max = Math.max(...weights);
  const average =
    weights.reduce((sum, weight) => sum + weight, 0) / weights.length;
  let message: string = "";
  if (weights[weights.length - 1] - weights[0] < 0) {
    message = `You have lost ${Math.abs(
      weights[weights.length - 1] - weights[0]
    )} kg since last week.`;
  } else {
    message = `You have gained ${Math.abs(
      weights[weights.length - 1] - weights[0]
    )} kg since last week.`;
  }

  if (weights.length > 1) {
    message += ` Your weight has fluctuated between ${min} kg and ${max} kg.`;
  } else {
    message += ` Your current weight is ${weights[0]} kg.`;
  }
  return {
    min,
    max,
    average,
    message,
  };
};

interface MoodValues {
  energetic: number;
  sore: number;
  cannot: number;
}

const preprocessMood = (moods: (string | null)[]) => {
  const moodValues: MoodValues = {
    energetic: 0,
    sore: 0,
    cannot: 0,
  };

  moods.forEach((mood) => {
    if (mood === "energetic") {
      moodValues.energetic++;
    } else if (mood === "sore") {
      moodValues.sore++;
    } else if (mood === "cannot") {
      moodValues.cannot++;
    }
  });

  const totalMoods = moods.length;
  const energeticPercentage = (
    (moodValues.energetic / totalMoods) *
    100
  ).toFixed(2);
  const sorePercentage = ((moodValues.sore / totalMoods) * 100).toFixed(1);
  const cannotPercentage = ((moodValues.cannot / totalMoods) * 100).toFixed(1);

  let message: string = "";
  if (
    moodValues.energetic > moodValues.sore &&
    moodValues.energetic > moodValues.cannot
  ) {
    message = `You have been feeling energetic for about ${
      moodValues.energetic / totalMoods
    } days of the week.`;
  } else if (
    moodValues.sore > moodValues.energetic &&
    moodValues.sore > moodValues.cannot
  ) {
    message = `You have been feeling sore for about ${
      moodValues.sore / totalMoods
    } days of the week.`;
  } else if (
    moodValues.cannot > moodValues.energetic &&
    moodValues.cannot > moodValues.sore
  ) {
    message = `You have been feeling unable to work out for about ${
      moodValues.cannot / totalMoods
    } days of the week.`;
  } else {
    message = "Your moods have been mixed this week.";
  }

  return {
    energetic: energeticPercentage,
    sore: sorePercentage,
    cannot: cannotPercentage,
    message,
  };
};

const preprocessMeals = (meals: any[]) => {
  if (meals.length == 0) {
    return {
      message: "You have not logged any meals this week.",
    };
  }

  const mealCounts:Record<string,number>={};
  const mealDescriptions:Record<string,string[]>={
    breakfast: [],
    lunch: [],
    dinner: [],
    snack: [],
  }

  meals.forEach((meal) => {
    const mealTypes = ["breakfast", "lunch", "dinner"];
    mealTypes.forEach((type) => {
      if (meal[type]) {
        const name = meal[type].mealName;
        const desc = meal[type].description;
        mealCounts[name] = (mealCounts[name] || 0) + 1;
        mealDescriptions[type].push(`${name} - ${desc}`);
      }
    });

    if (Array.isArray(meal.snacks)) {
      meal.snacks.forEach((snack: any) => {
        const name = snack.mealName;
        const desc = snack.description;
        mealCounts[name] = (mealCounts[name] || 0) + 1;
        mealDescriptions.snack.push(`${name} - ${desc}`);
      });
    }
  });

  let message = `Here’s what you ate this week:\n`;

  Object.entries(mealDescriptions).forEach(([type, entries]) => {
    if (entries.length > 0) {
      message += `\n${type.charAt(0).toUpperCase() + type.slice(1)}s:\n`;
      entries.forEach((entry) => {
        message += `- ${entry}\n`;
      });
    }
  });

  const mostFrequent = Object.entries(mealCounts)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 3)
    .map(([name, count]) => `${name} (${count} times)`)
    .join(", ");

  message += `\nMost frequently consumed items: ${mostFrequent}.`;

  return {
    message,
    mostFrequentFoods: mealCounts,
  };

};

interface SummaryData{
  weightSummary:{message:string};
  moodSummary:{message:string};
  mealSummary:{message:string};
  userGoal?:string;
}

const generatePrompt=({
  weightSummary,
  moodSummary,
  mealSummary,
  userGoal
}:SummaryData):string=>{
  
  const prompt=`
  User Summary This Week:

  Weight: ${weightSummary.message}
  Mood: ${moodSummary.message}
  Meals: ${mealSummary.message}
  ${userGoal ? `\nGoal: ${userGoal}` : ''}

  Based on the above logs, generate a personalized weekly insight for the user.
  The insight should mention correlations (if any), highlight progress or areas to improve, and give tips on nutrition, mood or training.
  Let the tone be friendly and encouraging.
  `.trim()

  return prompt;
}
