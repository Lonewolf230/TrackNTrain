

import 'package:flutter/material.dart';

class PrevWorkoutCard extends StatelessWidget{
  const PrevWorkoutCard({super.key});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        // Handle tap event
        // You can navigate to a detailed workout page or perform any other action
        print('Workout card tapped');
      },      
      child: Card(
        surfaceTintColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Workout Name',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
              const SizedBox(height: 10,),
              const Text('Date',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
              const SizedBox(height: 10,),
              const Text('Duration',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400),),
            ],
          ),
        ),
      ),
    );    
  }
}

