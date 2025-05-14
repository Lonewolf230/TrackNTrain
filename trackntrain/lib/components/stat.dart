import 'package:flutter/material.dart';

class Stat extends StatelessWidget {
  const Stat({
    super.key,
    required this.icon,
    required this.count,
    required this.subtitle,
  });

  final IconData icon;
  final int count;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 90),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.deepOrange, size: 40),
              const SizedBox(width: 10),
              Column(
                children: [
                  Text(
                    count.toString(),
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
