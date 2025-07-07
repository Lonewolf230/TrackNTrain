import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:trackntrain/components/workout_category.dart';
import 'package:trackntrain/tabs/hiit_tab.dart';
import 'package:trackntrain/tabs/full_body_tab.dart';
import 'package:trackntrain/tabs/walking_tab.dart';
import 'package:trackntrain/utils/quotes.dart';

class TrainTab extends StatelessWidget {
  const TrainTab({super.key});

  static final Map<String, Widget Function()> workoutPages = {
    'full-body': () => const FullBodyTab(),
    'walking': () => const WalkingTab(),
    'hiit': () => const HiitTab(),
  };

  void onTap(BuildContext context, String type) {
    context.goNamed(type);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> options = <Widget>[
      WorkoutCategory(
        icon: const Icon(FontAwesomeIcons.dumbbell),
        title: 'Full body',
        subtitle: 'Hit your entire body with this workout',
        onTap: () => onTap(context, 'full-body'),
      ),
      WorkoutCategory(
        icon: const Icon(FontAwesomeIcons.personWalking),
        title: 'Walking/Running',
        subtitle: 'Get your steps in with this workout',
        onTap: () => onTap(context, 'walking'),
      ),
      WorkoutCategory(
        icon: const Icon(FontAwesomeIcons.heartCircleBolt),
        title: 'HIIT',
        subtitle: 'Alternate between bursts of effort and rest',
        onTap: () => onTap(context, 'hiit'),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[50]!,
            Colors.white,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.format_quote,
                    color: const Color.fromARGB(255, 247, 2, 2),
                    size: 32,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    getRandomQuote(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          color: const Color.fromARGB(255, 247, 2, 2),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Choose Your Workout',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: options,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}