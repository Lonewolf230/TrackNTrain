import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackntrain/components/prev_workout_card.dart';

class FullBodyTab extends StatelessWidget {
  const FullBodyTab({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Full Body', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Hit all your muscles with this workout',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Previous Workouts',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 20),
            ListView(
              addAutomaticKeepAlives: true,
              shrinkWrap: true,
              children: [
                PrevWorkoutCard(),
                PrevWorkoutCard(),
                PrevWorkoutCard(),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 250,
                  minWidth: 200,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    print('Generate Workout');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(247, 250, 2, 2),
                  ),
                  child: const Text(
                    'Generate Workout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 250,
                  minWidth: 200,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    print('Create your Workout');
                    context.goNamed('create-full-body');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(247, 250, 2, 2),
                  ),
                  child: const Text(
                    'Create your Workout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
