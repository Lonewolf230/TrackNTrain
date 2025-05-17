
import 'package:flutter/material.dart';

class WalkingTab extends StatelessWidget{
  const WalkingTab({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Walking', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20,),
          const Text('Walking Tab'),
          const SizedBox(height: 20,),
          ElevatedButton(
            onPressed: () {
              // Add your button action here
            },
            child: const Text('Start Walking'),
          ),
        ],
      ),
    );
  }
}