


import 'package:flutter/material.dart';

class WorkoutCategory extends StatelessWidget {
  const WorkoutCategory({super.key,required this.icon,required this.title,required this.subtitle});
  final Icon icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('Tapped on $title');
      },
      splashColor: const Color.fromARGB(50, 247, 2, 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          leading: icon,
          horizontalTitleGap: 50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(title),
          subtitle: Text(subtitle),      
        ),
      ),
    );
  }
}