import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:trackntrain/components/workout_category.dart';
import 'package:trackntrain/tabs/hiit_tab.dart';
import 'package:trackntrain/tabs/running_tab.dart';
import 'package:trackntrain/tabs/split_tab.dart';
import 'package:trackntrain/tabs/full_body_tab.dart';
import 'package:trackntrain/tabs/walking_tab.dart';
import 'package:trackntrain/utils/quotes.dart';

class TrainTab extends StatelessWidget {
  const TrainTab({super.key});

  // Map workout type to its corresponding screen
  static final Map<String, Widget Function()> workoutPages = {
    'full-body': () => const FullBodyTab(),
    'walking': () => const WalkingTab(),
    'running': () => const RunningTab(),
    'splits': () => const SplitTab(),
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
        title: 'Walking',
        subtitle: 'Go for a nice walk in a pleasant environment',
        onTap: () => onTap(context, 'walking'),
      ),
      WorkoutCategory(
        icon: const Icon(FontAwesomeIcons.personRunning),
        title: 'Running',
        subtitle: 'Go for a nice run to get your heart rate pumped up',
        onTap: () => onTap(context, 'running'),
      ),
      WorkoutCategory(
        icon: const Icon(FontAwesomeIcons.weightHanging),
        title: 'Splits',
        subtitle: 'Hit specific muscle group every day',
        onTap: () => onTap(context, 'splits'),
      ),
      WorkoutCategory(
        icon: const Icon(FontAwesomeIcons.heartCircleBolt),
        title: 'HIIT',
        subtitle: 'Alternate between bursts of effort and rest',
        onTap: () => onTap(context, 'hiit'),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: Text(
              '"${getRandomQuote()}"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 30),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: options,
          ),
        ],
      ),
    );
  }
}
