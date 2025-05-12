import 'dart:math';

List<String> fitnessQuotes = [
  // Motivational & Quirky
  "Sore today, strong tomorrow.",
  "Sweat is just fat crying.",
  "You don’t have to go fast—just go.",
  "Gym hair, don’t care.",
  "Burpees don’t like you either.",
  "You lift me up—literally.",
  "Running late is my cardio.",
  "Rest day? More like best day.",
  "I workout because I really, really like tacos.",
  "Squats? I thought you said shots!",
  "Train insane or remain the same.",
  "Woke up. Worked out. Won the day.",
  "No pain, no pizza.",
  "Punch excuses in the face.",
  "Strong is the new sexy.",
  "Cardio? More like car-dee-no.",

  // Informative & Insightful
  "Muscles grow in recovery—respect your rest days.",
  "Hydrate before you dominate.",
  "You can't out-train a bad diet.",
  "Form first, weight second.",
  "Protein helps repair—don’t skip it.",
  "Sleep is a workout multiplier.",
  "A little progress each day adds up.",
  "Consistency beats intensity every time.",
  "Stretch today, move better tomorrow.",
  "Your body hears everything your mind says—stay positive.",
  "Fitness is 30% gym, 70% kitchen.",
  "Fuel your body, not just fill it.",
  "Momentum is built one rep at a time.",
  "Rest is part of the program, not a break from it.",
  "Discipline weighs ounces, regret weighs tons.",
  "Fitness is a journey, not a destination.",
  "Your only limit is you.",
  // Inspirational & Uplifting
  "Believe in yourself and all that you are.",
  "The only bad workout is the one you didn’t do.",
  "Success is the sum of small efforts, repeated day in and day out.",
  "The pain you feel today will be the strength you feel tomorrow.",
  "You are stronger than you think.",
  "Dream big, work hard, stay focused.",
  "The body achieves what the mind believes.",
  "Every workout is progress.",
  "You are one workout away from a better mood.",
  "Fitness is not about being better than someone else; it’s about being better than you used to be.",

];

String getRandomQuote(){
  final random=Random();
  return fitnessQuotes[random.nextInt(fitnessQuotes.length)];
}
