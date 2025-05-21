import 'package:flutter/material.dart';

class Filters extends StatelessWidget {
  const Filters({super.key,required this.filters,required this.toggleFilters,required this.onApply});
  final List<Map<String,dynamic>> filters;
  final void Function(String muscleGroup,bool value) toggleFilters;
  final VoidCallback onApply;


  List<Widget> _buildFilterChips() {
    return filters.map((filter) {
      return FilterChip(
        label: Text(filter['muscleGroup'],style: TextStyle(color: filter['selected'] ?Colors.white:Colors.black),),
        selected: filter['selected'] ?? false,
        selectedColor: Colors.redAccent,
        checkmarkColor: filter['selected'] ?Colors.white:Colors.black,
        onSelected: (value) {
          toggleFilters(filter['muscleGroup'], value);
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final int itemCount=filters.length;
    final int crossAxisCount=3;
    final int rowCount=(itemCount/crossAxisCount).ceil();
    final double height= 50.0*(rowCount+1);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text('Select Muscle Groups',style: TextStyle(fontWeight: FontWeight.w900,fontSize: 20),),
            const SizedBox(height: 20,),
            SizedBox(
              height: height,
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 5,
                childAspectRatio: 3,
                shrinkWrap: true,
                children: _buildFilterChips()
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Apply Filters',style: TextStyle(fontSize: 15,color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}

