import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderConfig extends StatefulWidget {
  const OrderConfig({super.key,required this.selectedExercisesList});
  final List<Map<String,dynamic>> selectedExercisesList;

  @override
  State<OrderConfig> createState() => _OrderConfigState();
}

class _OrderConfigState extends State<OrderConfig> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 400, 
        width: double.maxFinite,
        child: Column(
          children: [
            const Text('Arrange your exercises',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700),),
            const SizedBox(height: 15),
            Expanded(
            child: ReorderableListView.builder(
              itemBuilder:(context, index){
                final exercise=widget.selectedExercisesList[index]['exerciseName'];
                return Card(
                    key: ValueKey(index),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(exercise),
                    ),
                );
              },
              itemCount: widget.selectedExercisesList.length,
              
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) {
                  newIndex--;
                }
                final item = widget.selectedExercisesList.removeAt(oldIndex);
                widget.selectedExercisesList.insert(newIndex, item);
              },
            ),
          ),
        ]),
      ),
      actions: [
        IconButton(
          icon: const Icon(FontAwesomeIcons.wandMagicSparkles),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Start Workout'),
        ),
      ],
    );
  }
}
