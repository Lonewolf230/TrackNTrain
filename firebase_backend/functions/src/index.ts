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
import admin from "firebase-admin";
import { defineSecret } from "firebase-functions/params";
import { GoogleGenAI } from "@google/genai";
admin.initializeApp();

const geminiAPIKey=defineSecret("GEMINI_API_KEY");

export const helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", { structuredData: true });
  response.send("Hello from Firebase!");
});

export const metaLogCreation = onSchedule(
  {
    schedule: "0 0 * * *",
    timeZone: "Asia/Kolkata",
    timeoutSeconds: 300,
    retryCount: 3,
    memory:"256MiB",
    region: "asia-south1",
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

      const prevDate = new Intl.DateTimeFormat("en-CA", {
        timeZone: "Asia/Kolkata",
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
      }).format(new Date(new Date().setDate(new Date().getDate() - 1)));

      const allPrevDayMetaDocsSnap = await admin
        .firestore()
        .collection("userMetaLogs")
        .where("date", "==", prevDate)
        .get();

      const prevDayWeights: Record<string, number> = {};
      allPrevDayMetaDocsSnap.forEach((doc) => {
        const data = doc.data();
        if (data?.userId && typeof data?.weight === "number") {
          prevDayWeights[data.userId] = data.weight;
        }
      });

      const ninetyDayInFutureTimeStamp = admin.firestore.Timestamp.fromDate(
        new Date(new Date().setDate(new Date().getDate() + 90))
      );

      const batchCommits: Promise<any>[] = [];

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

          const weight = prevDayWeights[uid] ?? 0;
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
            // await batch.commit();
            batchCommits.push(batch.commit());
            logger.info("Batch of 500 meta logs pushed to list");
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
        // await batch.commit();
        batchCommits.push(batch.commit());

        logger.info(`Final batch of ${counter} meta logs pushed to list`);
      }
      await Promise.all(batchCommits);
      logger.info(
        `All meta logs length:${batchCommits.length} created successfully`,
        {
          structuredData: true,
        }
      );
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

  // const date = new Date().toISOString().split("T")[0];
  const date = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Kolkata",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(new Date());
  const ninetyDayInFutureTimeStamp = admin.firestore.Timestamp.fromDate(
    new Date(new Date().setDate(new Date().getDate() + 90))
  );

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
      expireAt: ninetyDayInFutureTimeStamp,
    });
    logger.info(`Meta log created for user: ${userId}`, {
      structuredData: true,
    });
    response.status(201).send("Meta log created");
  } catch (error) {
    logger.error(`Error creating meta log for user: ${userId}`, { error });
    response.status(500).send("Error creating meta log");
  }
});

export const handleDeletion = onRequest(
  { timeoutSeconds: 180,memory:"256MiB",region:"asia-south1" },
  async (request, response) => {
    const { userId } = request.body;
    if (!userId) {
      response.status(400).send("Missing userId");
      return;
    }
    try {
      const userMetaLogsRef: admin.firestore.Query<admin.firestore.DocumentData> = admin
        .firestore()
        .collection("userMetaLogs")
        .where("userId", "==", userId);
      const userDocRef: admin.firestore.DocumentReference = admin
        .firestore()
        .collection("users")
        .doc(userId);
      const userMealLogsRef: admin.firestore.Query<admin.firestore.DocumentData> =
        admin
          .firestore()
          .collection("userMeals")
          .where("userId", "==", userId);
      const userFullBodyLogsRef: admin.firestore.Query<admin.firestore.DocumentData> =
        admin
          .firestore()
          .collection("userFullBodyWorkouts")
          .where("userId", "==", userId);
      const userHiitLogsRef: admin.firestore.Query<admin.firestore.DocumentData> =
        admin
          .firestore()
          .collection("userHiitWorkouts")
          .where("userId", "==", userId);
      const userWalkLogsRef: admin.firestore.Query<admin.firestore.DocumentData> =
        admin
          .firestore()
          .collection("userWalkRecords")
          .where("userId", "==", userId);
      
      const batchList : Promise<any>[] =[];

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
      batchList.push(batch.commit());
      await Promise.all(batchList);

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
    memory: "256MiB",
    secrets: [geminiAPIKey],
    region:"asia-south1", 
  },
  async (request, response) => {
    try {
      const { userId } = request.body;

      if (userId === undefined || userId === null) {
        response.status(400).send("Missing userId");
        return;
      }
      logger.debug("Updated version");
      // console.log("Timestamp:", admin.firestore.Timestamp);
      // console.log("fromDate function:", admin.firestore.Timestamp.fromDate);

      let geminiAPIKeyValue: string | undefined;
      try {
        geminiAPIKeyValue = geminiAPIKey.value();
        if (!geminiAPIKeyValue) {
          logger.error("OpenAI key is not set");
          throw new Error("OpenAI key is not set");
        }
        logger.debug("OpenAI key retrieved successfully", {
          structuredData: true,
        });
      } catch (error) {
        logger.error("Error retrieving OpenAI key", { error });
        response.status(500).send("Error retrieving OpenAI key");
        return;
      }

      const metaData = await getWeeklyMetaData(userId);
      const mealData = await getWeeklyMealData(userId);
      if (!metaData || !mealData) {
        response
          .status(404)
          .send(
            "Please log your meals, weight and mood consistently to get a proper feedback"
          );
        return;
      }

      const weightsData: number[] = metaData.map((log) => log.weight);
      const moodData: (string | null)[] = metaData.map((log) => log.mood);
      const mealsData: MealDocument[] = mealData;

      const weightsSummary = preprocessWeights(weightsData);
      const moodSummary = preprocessMood(moodData);
      const mealsSummary = preprocessMeals(mealsData);

      const userDoc: admin.firestore.DocumentReference = admin
        .firestore()
        .collection("users")
        .doc(userId);
      const userDocSnap: admin.firestore.DocumentSnapshot = await userDoc.get();

      const userGoal: string = userDocSnap.exists
        ? userDocSnap.get("goal")
        : "No goal set";

      const prompt = generatePrompt({
        weightSummary: {
          message: weightsSummary.message || "No weight data available",
        },
        moodSummary: {
          message: moodSummary.message || "No mood data available",
        },
        mealSummary: {
          message: mealsSummary.message || "No meal data available",
        },
        userGoal: userGoal,
      });

      const ai=new GoogleGenAI({
        apiKey: geminiAPIKeyValue,
      })
      const res=await ai.models.generateContent({
        model:"gemini-2.0-flash",
        contents:[
          {
            role:"model",
            parts:[{
              text:`
              You are a certified fitness and nutrition coach who just finished reviewing a client's weekly data logs. Your job is to send them a friendly and personalized voice-note-style message — like you would to your own client.
              Keep it under 700 words.

The report should:
- Suggest nutrition/training tips (based on meals/mood/weight)
- Use the user's mood data to suggest recovery or adjustments
- Be casual, positive, and supportive — like you're talking to them directly
- Avoid headers like “Subject” or “Weekly Report”
- Avoid markdown or bullet points
- Avoid generic praise like “keep up the good work” unless justified
- Use **specific insights** from their weight, mood, and meal data to guide your advice
- Provide workout and training advice based on their mood and weight data and goal.(Provide actual tips not generic ones)
- Use the user’s goal to **tailor the feedback**
- If something is lacking, gently call it out constructively


Instructions:
- Imagine you just looked at this data, and now you're **talking casually but intelligently** to your client.
- Include at least one motivational reflection that ties to their **specific progress or goal.**
- Do not use formal structure or generic advice.
- Make it feel like a personal conversation and avoid giving similar advice to every user.
- Also avoid blindly reading the user's data back to them. 
- Avoid suggesting they can ask further questions or that they can reach out for more help. (We only allow one query per week so ignore telling all this)

Now write your message as a trainer who truly cares about this person’s journey.`
                        
            }]
          },
          {
            role:"user",
            parts:[{
              text:prompt
            }]
          }
        ],
        config:{
          responseMimeType: "text/plain",
          temperature: 0.7,
        }
      });

      const aiResponse = res.text || "No response from AI";
      const metaPromptTokenCount=res.usageMetadata?.promptTokenCount || 0;
      const metaCompletionTokenCount=res.usageMetadata?.thoughtsTokenCount || 0;
      const totalTokenCount=res.usageMetadata?.totalTokenCount
      const toolUsePromptTokenCount= res.usageMetadata?.toolUsePromptTokenCount
      const toolUsePromptTokensDetails= res.usageMetadata?.toolUsePromptTokensDetails
      const promptTokenCount= res.usageMetadata?.promptTokenCount
      const promptTokensDetails= res.usageMetadata?.promptTokensDetails
      const data=res.data;

      logger.info("AI response received", {
        metaPromptTokenCount,
        metaCompletionTokenCount,
        totalTokenCount,
        toolUsePromptTokenCount,
        toolUsePromptTokensDetails,
        promptTokenCount,
        promptTokensDetails,
        structuredData: true,
        data: JSON.stringify(data, null, 2),
      });

      await userDoc.set(
        {
          lastAIResponse: aiResponse,
          lastAIResponseAt: admin.firestore.Timestamp.now(),
        },
        { merge: true }
      );
      response.status(200).send({
        prompt,
        aiResponse,
        weightSummary: weightsSummary,
        moodSummary: moodSummary,
        mealSummary: mealsSummary,
        userGoal: userGoal,
      });
    } catch (error:any) {
  const apiError = error ;
          logger.error("Error generating AI response", {
    message: apiError?.message,
    status: apiError?.status,
    name: apiError?.name,
    type: apiError?.type,
    stack: apiError?.stack,
    response: apiError?.response?.data ?? "(No response data)",
  });

  if (apiError?.response?.data) {
    console.error("🧠 OpenAI Error Response:", JSON.stringify(apiError.response.data, null, 2));
  }
  response.status(500).json({
    success: false,
    error: error instanceof Error ? error.message : "Unknown error",
    code: error?.code || "INTERNAL_ERROR",
    status: error?.status || 500,
    response: error?.response?.data || "No response data available",
    
    });
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

  let message: string =
    "The 3 possible mood states are energetic, sore and cannot work out. \n";
  if (
    moodValues.energetic > moodValues.sore &&
    moodValues.energetic > moodValues.cannot
  ) {
    message += `You have been feeling energetic for about ${moodValues.energetic} out of the ${totalMoods}
    logged days of the week.`;
  } else if (
    moodValues.sore > moodValues.energetic &&
    moodValues.sore > moodValues.cannot
  ) {
    message += `You have been feeling sore for about ${moodValues.sore} out of the ${totalMoods}
    logged days of the week.`;
  } else if (
    moodValues.cannot > moodValues.energetic &&
    moodValues.cannot > moodValues.sore
  ) {
    message += `You have been feeling unable to work out for about ${moodValues.cannot} out of the  ${totalMoods}
    logged days of the week.`;
  } else {
    message += "Your moods have been mixed this week.";
  }

  return {
    energetic: energeticPercentage,
    sore: sorePercentage,
    cannot: cannotPercentage,
    message,
  };
};

interface MealItem {
  mealName: string;
  description?: string;
  mealType: string;
}

interface MealDocument {
  breakfast?: MealItem;
  lunch?: MealItem;
  dinner?: MealItem;
  snacks?: MealItem[];
  userId: string;
  createdAt: admin.firestore.Timestamp;
  updatedAt?: admin.firestore.Timestamp;
  expireAt?: admin.firestore.Timestamp;
}

interface MealSummary {
  message: string;
  mostFrequentFoods?: Record<string, number>;
}

const isMealDocument = (data: any): data is MealDocument => {
  return (
    data &&
    typeof data === "object" &&
    typeof data.userId === "string" &&
    data.createdAt &&
    (data.breakfast ||
      data.lunch ||
      data.dinner ||
      (Array.isArray(data.snacks) && data.snacks.length > 0))
  );
};

const getWeeklyMealData = async (
  userId: string
): Promise<MealDocument[] | null> => {
  const today = new Date();
  const dayOfWeek = today.getDay();
  const daysSinceMonday = (dayOfWeek + 6) % 7;

  const startOfPrevWeek = new Date(today);
  startOfPrevWeek.setDate(today.getDate() - daysSinceMonday - 7);
  startOfPrevWeek.setHours(0, 0, 0, 0);

  const endOfPrevWeek = new Date(today);
  endOfPrevWeek.setDate(today.getDate() - daysSinceMonday - 1);
  endOfPrevWeek.setHours(23, 59, 59, 999);

  logger.debug(
    `Fetching meal logs for user: ${userId} from ${startOfPrevWeek.toISOString()} to ${endOfPrevWeek.toISOString()}`,
    {
      structuredData: true,
    }
  );

  const mealLogsSnapshot = await admin
    .firestore()
    .collection("userMeals")
    .where("userId", "==", userId)
    .where(
      "createdAt",
      ">=",
      admin.firestore.Timestamp.fromDate(startOfPrevWeek)
    )
    .where("createdAt", "<=", admin.firestore.Timestamp.fromDate(endOfPrevWeek))
    .get();

  if (mealLogsSnapshot.empty) {
    logger.info(`No meal logs found for user: ${userId}`);
    return null;
  }

  logger.info(`Total documents found: ${mealLogsSnapshot.docs.length}`);

  const mealsOnly: MealDocument[] = [];

  mealLogsSnapshot.docs.forEach((doc, index) => {
    const data = doc.data();
    logger.debug(`Raw Firestore meal doc ${index}:`, {
      docId: doc.id,
      data: JSON.stringify(data, null, 2),
    });

    if (isMealDocument(data)) {
      const hasBreakfast =
        data.breakfast &&
        typeof data.breakfast === "object" &&
        data.breakfast.mealName;
      const hasLunch =
        data.lunch && typeof data.lunch === "object" && data.lunch.mealName;
      const hasDinner =
        data.dinner && typeof data.dinner === "object" && data.dinner.mealName;
      const hasSnacks = Array.isArray(data.snacks) && data.snacks.length > 0;

      const hasMeal = hasBreakfast || hasLunch || hasDinner || hasSnacks;

      logger.debug(`Document ${index} meal check:`, {
        hasBreakfast,
        hasLunch,
        hasDinner,
        hasSnacks,
        hasMeal,
        breakfast: data.breakfast,
        lunch: data.lunch,
        dinner: data.dinner,
        snacks: data.snacks,
      });

      if (hasMeal) {
        mealsOnly.push(data);
      } else {
        logger.warn(`Document ${index}: no valid meal fields found`, {
          availableKeys: Object.keys(data),
          data: JSON.stringify(data, null, 2),
        });
      }
    } else {
      logger.warn(`Document ${index}: does not match MealDocument structure`, {
        data,
        hasUserId: typeof (data as any)?.userId === "string",
        hasCreatedAt: !!(data as any)?.createdAt,
        availableKeys: data ? Object.keys(data) : [],
      });
    }
  });

  logger.info(`Filtered meal logs count: ${mealsOnly.length}`, {
    structuredData: true,
  });

  if (mealsOnly.length === 0) {
    logger.warn("No valid meal documents after filtering");
    return null;
  }

  return mealsOnly;
};

const preprocessMeals = (meals: MealDocument[]): MealSummary => {
  if (!meals || meals.length === 0) {
    return {
      message: "You have not logged any meals this week.",
    };
  }

  const mealCounts: Record<string, number> = {};
  const mealDescriptions: Record<string, string[]> = {
    breakfast: [],
    lunch: [],
    dinner: [],
    snack: [],
  };

  logger.debug("Processing meals data", { mealsCount: meals.length });

  meals.forEach((mealDoc: MealDocument, index: number) => {
    logger.debug(`Processing meal document ${index}:`, { mealDoc });

    if (!mealDoc || typeof mealDoc !== "object") {
      logger.warn("Invalid meal document encountered, skipping", {
        mealDoc,
        index,
      });
      return;
    }

    const mealTypes: (keyof Pick<
      MealDocument,
      "breakfast" | "lunch" | "dinner"
    >)[] = ["breakfast", "lunch", "dinner"];
    mealTypes.forEach((type) => {
      const mealItem = mealDoc[type];
      if (mealItem && typeof mealItem === "object" && mealItem.mealName) {
        const name = mealItem.mealName;
        const desc = mealItem.description || "";

        logger.debug(`Found ${type}:`, { name, desc });

        mealCounts[name] = (mealCounts[name] || 0) + 1;
        mealDescriptions[type].push(`${name} - ${desc}`);
      }
    });

    if (mealDoc.snacks && Array.isArray(mealDoc.snacks)) {
      mealDoc.snacks.forEach((snack: MealItem, snackIndex: number) => {
        if (snack && typeof snack === "object" && snack.mealName) {
          const name = snack.mealName;
          const desc = snack.description || "";

          logger.debug(`Found snack ${snackIndex}:`, { name, desc });

          mealCounts[name] = (mealCounts[name] || 0) + 1;
          mealDescriptions.snack.push(`${name} - ${desc}`);
        }
      });
    }
  });

  const totalMealsProcessed = Object.keys(mealCounts).length;
  if (totalMealsProcessed === 0) {
    logger.warn("No valid meals found in any documents");
    return {
      message: "No valid meal data found for this week.",
    };
  }
  logger.debug(
    `Total unique meals processed: ${totalMealsProcessed}`,
    { mealCounts: JSON.stringify(mealCounts, null, 2) }
  );
  logger.debug('MEal processed')
  let message = `Here's what you ate this week:\n`;

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

  if (mostFrequent) {
    message += `\nMost frequently consumed items: ${mostFrequent}.`;
  }
  logger.debug("Meal summary message generated", { message });
  return {
    message,
    mostFrequentFoods: mealCounts,
  };
};

interface SummaryData {
  weightSummary: { message: string };
  moodSummary: { message: string };
  mealSummary: { message: string };
  userGoal?: string;
}

const generatePrompt = ({
  weightSummary,
  moodSummary,
  mealSummary,
  userGoal,
}: SummaryData): string => {
  const prompt = `
  User Summary This Week:

  Weight: ${weightSummary.message}
  Mood: ${moodSummary.message}
  Meals: ${mealSummary.message}
  ${userGoal ? `\nGoal: ${userGoal}` : ""}
  `.trim();

  return prompt;
};



