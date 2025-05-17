

import 'package:flutter/material.dart';

class RunningTab extends StatelessWidget{
  const RunningTab({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Running', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20,),
          const Text('Running Tab'),
          const SizedBox(height: 20,),
          ElevatedButton(
            onPressed: () {
              // Add your button action here
            },
            child: const Text('Start Running'),
          ),
        ],
      ),
    );
  }
}