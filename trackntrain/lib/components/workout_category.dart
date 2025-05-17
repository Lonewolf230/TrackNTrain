


import 'package:flutter/material.dart';

class WorkoutCategory extends StatelessWidget {
  const WorkoutCategory({super.key,required this.icon,required this.title,required this.subtitle,required this.onTap});
  final Icon icon;
  final String title;
  final String subtitle;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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