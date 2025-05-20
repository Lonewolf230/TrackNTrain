import 'package:flutter/material.dart';

class Filters extends StatefulWidget {
  const Filters({super.key});

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  bool isNoEquipmentSelected = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            SwitchListTile.adaptive(
              value: isNoEquipmentSelected,
              onChanged: (value) {
                setState(() {
                  isNoEquipmentSelected = value;
                });
              },
              activeColor: Theme.of(context).primaryColor,
              splashRadius: 10,
              title: Text('No Equipment',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20),),
            ),
            const SizedBox(height: 20),
            const Text('Select Muscle Groups',style: TextStyle(fontWeight: FontWeight.w600),),
            const SizedBox(height: 20,),
            Wrap(
              spacing: 8,
              runSpacing: 8,
                children: [
                  FilterChip(
                    label: Text('Chest'),
                    selected: true,
                    onSelected: (value) {},
                  ),
                  FilterChip(
                    label: Text('Back'),
                    selected: true,
                    selectedColor: Color.fromARGB(150, 251, 60, 60),
                    selectedShadowColor: Colors.white,
                    onSelected: (value) {},
                  ),
                  FilterChip(
                    label: Text('Quadriceps'),
                    selected: false,
                    onSelected: (value) {},
                  ),
                  FilterChip(
                    label: Text('Shoulders'),
                    selected: false,
                    onSelected: (value) {},
                  ),
                  FilterChip(
                    label: Text('Biceps'),
                    selected: false,
                    onSelected: (value) {},
                  ),
                  FilterChip(
                    label: Text('Triceps'),
                    selected: false,
                    onSelected: (value) {},
                  ),
                  FilterChip(
                    label: Text('Abs'),
                    selected: false,
                    onSelected: (value) {},
                  ),
                  FilterChip(
                    label: Text('Traps'),
                    selected: false,
                    onSelected: (value) {},
                  ),
                  FilterChip(
                    label: Text('Calves'),
                    selected: false,
                    onSelected: (value) {},
                  ),
                  FilterChip(
                    label: Text('Hamstrings'),
                    selected: false,
                    onSelected: (value) {},
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
