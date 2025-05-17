final List<Map<String,String>> hiitExercises = [
  {
    "name": "Burpees",
    "description":
        "Start in a standing position, drop into a squat with hands on the ground, kick feet back into a plank, do a push-up, jump feet back to squat position, and explosively jump up.",
    "special_considerations":
        "Modify by stepping back instead of jumping for lower impact. Keep core engaged to protect lower back.",
  },
  {
    "name": "Jump Squats",
    "description":
        "Lower into a squat position, then explosively jump up, landing softly back into the squat.",
    "special_considerations":
        "Land with knees slightly bent to absorb impact. Avoid letting knees cave inward.",
  },
  {
    "name": "Mountain Climbers",
    "description":
        "Start in plank position, alternate driving knees toward chest as quickly as possible while maintaining good form.",
    "special_considerations":
        "Keep hips down and core engaged. Modify speed if form breaks down.",
  },
  {
    "name": "High Knees",
    "description":
        "Run in place while bringing knees up to hip height, pumping arms vigorously.",
    "special_considerations":
        "Maintain upright posture. Land softly on balls of feet.",
  },
  {
    "name": "Jump Lunges",
    "description":
        "From lunge position, explosively jump up and switch legs in mid-air, landing in lunge with opposite leg forward.",
    "special_considerations":
        "Ensure front knee stays above ankle. Modify to alternating lunges without jump if needed.",
  },
  {
    "name": "Plank to Push-Up",
    "description":
        "Alternate between forearm plank and push-up position by pushing up one arm at a time.",
    "special_considerations":
        "Keep body in straight line. Engage core throughout.",
  },
  {
    "name": "Sprint in Place",
    "description":
        "Run in place as fast as possible with high intensity, lifting knees and pumping arms.",
    "special_considerations":
        "Land softly. Maintain good posture with slight forward lean.",
  },
  {
    "name": "Push-Up with Shoulder Tap",
    "description":
        "Perform a push-up, then at the top position, lift one hand to tap opposite shoulder, alternating sides.",
    "special_considerations":
        "Keep hips stable. Modify with knees down if needed.",
  },
  {
    "name": "Box Jumps",
    "description":
        "Explosively jump onto a sturdy box or platform, landing softly with both feet, then step back down.",
    "special_considerations":
        "Start with low height. Ensure full foot contact on landing.",
  },
  {
    "name": "Bicycle Crunches",
    "description":
        "Lie on back, bring opposite elbow to knee while extending other leg, alternating sides in pedaling motion.",
    "special_considerations":
        "Focus on rotation from core rather than pulling with neck.",
  },
  {
    "name": "Tuck Jumps",
    "description":
        "Jump straight up, bringing knees toward chest at peak of jump, landing softly.",
    "special_considerations":
        "Land with bent knees to absorb impact. Modify intensity as needed.",
  },

  {
    "name": "Skater Jumps",
    "description":
        "Leap sideways, landing on one leg while the other sweeps behind, then jump to the opposite side.",
    "special_considerations":
        "Land softly with a slight knee bend. Control momentum.",
  },

  {
    "name": "Squat Thrusts",
    "description":
        "From standing, drop hands to the floor, kick feet back into plank, then quickly return to standing.",
    "special_considerations": "Modify by omitting the jump at the top.",
  },
  {
    "name": "Lateral Jumps",
    "description": "Jump side-to-side over an imaginary line or small object.",
    "special_considerations": "Land softly with knees bent. Keep core engaged.",
  },
  {
    "name": "Plank Jacks",
    "description":
        "In a plank position, jump feet wide and back together (like a horizontal jumping jack).",
    "special_considerations": "Keep hips stable. Modify by stepping feet out.",
  },
  {
    "name": "Jump Rope (Imaginary or Real)",
    "description":
        "Jump continuously with quick, small hops, rotating wrists as if holding a rope.",
    "special_considerations":
        "Stay on the balls of your feet. Keep jumps low-impact if needed.",
  },
  {
    "name": "Spiderman Push-Ups",
    "description":
        "During a push-up, bring one knee toward the elbow on the same side, alternating sides.",
    "special_considerations": "Engage obliques. Modify with knees down.",
  },
  {
    "name": "Star Jumps",
    "description":
        "From a squat, explode into a jump, spreading arms and legs wide (like a star), then land softly.",
    "special_considerations": "Control landing. Reduce impact as needed.",
  },
  {
    "name": "Russian Twists",
    "description":
        "Sit with knees bent, lean back slightly, and rotate torso side-to-side, optionally holding weight.",
    "special_considerations": "Engage core, don’t strain the neck.",
  },
  {
    "name": "Wall Sit",
    "description":
        "Slide down a wall into a seated position with thighs parallel to the ground, holding the position.",
    "special_considerations":
        "Keep knees aligned with ankles. Adjust depth for difficulty.",
  },
  {
    "name": "Bear Crawls",
    "description":
        "On hands and feet, crawl forward/backward while keeping knees slightly off the ground.",
    "special_considerations": "Engage core. Move with control.",
  },
  {
    "name": "Dive Bomber Push-Ups",
    "description":
        "Start in downward dog, lower into a push-up while arching forward, then push back up.",
    "special_considerations":
        "Advanced movement. Modify with knees down if needed.",
  },
  {
    "name": "Single-Leg Deadlifts (Plyo)",
    "description":
        "Balance on one leg, hinge at hips, then explosively return to standing, optionally adding a jump.",
    "special_considerations": "Keep back flat. Engage glutes.",
  },
  {
    "name": "Plyo Push-Ups",
    "description":
        "Perform a push-up with enough power to lift hands off the ground at the top.",
    "special_considerations":
        "Advanced. Modify with knees down or no explosive push.",
  },
  {
    "name": "Seated Leg Raises",
    "description":
        "Sit with legs extended, lean back slightly, and lift legs up and down without touching the floor.",
    "special_considerations": "Engage lower abs. Don’t arch the back.",
  },
];

final hiitExercisesList =
    hiitExercises.map((exercise) {
      return {
        "name": exercise["name"],
        "description": exercise["description"],
        "special_considerations": exercise["special_considerations"],
      };
    }).toList();
