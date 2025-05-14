import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trackntrain/components/workout_category.dart';
import 'package:trackntrain/utils/quotes.dart';

class TrainTab extends StatelessWidget {
  const TrainTab({super.key});
  @override
  Widget build(BuildContext context) {

    List<Widget> options=<Widget>[
      WorkoutCategory(icon: Icon(FontAwesomeIcons.dumbbell),title: 'Full body',subtitle: 'Hit your entire body with this workout',),
      WorkoutCategory(icon: Icon(FontAwesomeIcons.personWalking),title: 'Walking',subtitle: 'Go for a nice walk in a pleasant environment',),
      WorkoutCategory(icon: Icon(FontAwesomeIcons.personRunning),title: 'Running',subtitle: 'Go for a nice run to get your heart rate pumped up',),
      WorkoutCategory(icon: Icon(FontAwesomeIcons.weightHanging),title: 'Splits',subtitle: 'Hit specific muscle group every day',),
      WorkoutCategory(icon: Icon(FontAwesomeIcons.heartCircleBolt),title: 'HIIT',subtitle: 'Alternate between bursts of effort and rest',),
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
            children: options,
          )
        ],
      ),
    );
  }
}
