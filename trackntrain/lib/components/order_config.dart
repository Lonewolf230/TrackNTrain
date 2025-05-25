import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class OrderConfig extends StatefulWidget {
//   const OrderConfig({super.key,required this.selectedExercisesList});
//   final List<Map<String,dynamic>> selectedExercisesList;

//   @override
//   State<OrderConfig> createState() => _OrderConfigState();
// }

// class _OrderConfigState extends State<OrderConfig> {
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       content: SizedBox(
//         height: 400, 
//         width: double.maxFinite,
//         child: Column(
//           children: [
//             const Text('Arrange your exercises',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700),),
//             const SizedBox(height: 15),
//             Expanded(
//             child: ReorderableListView.builder(
//               itemBuilder:(context, index){
//                 final exercise=widget.selectedExercisesList[index]['exerciseName'];
//                 return Card(
//                     key: ValueKey(index),
//                     margin: const EdgeInsets.symmetric(vertical: 4),
//                     child: ListTile(
//                       title: Text(exercise),
//                     ),
//                 );
//               },
//               itemCount: widget.selectedExercisesList.length,
              
//               onReorder: (oldIndex, newIndex) {
//                 if (newIndex > oldIndex) {
//                   newIndex--;
//                 }
//                 final item = widget.selectedExercisesList.removeAt(oldIndex);
//                 widget.selectedExercisesList.insert(newIndex, item);
//               },
//             ),
//           ),
//         ]),
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(FontAwesomeIcons.wandMagicSparkles),
//           onPressed: () => Navigator.pop(context),
//         ),
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: const Text('Start Workout'),
//         ),
//       ],
//     );
//   }
// }

class OrderConfig extends StatefulWidget {
  const OrderConfig({
    super.key,
    required this.selectedExercisesList,
  });
  
  final List<Map<String, dynamic>> selectedExercisesList;

  @override
  State<OrderConfig> createState() => _OrderConfigState();
}

class _OrderConfigState extends State<OrderConfig> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.reorder,
                      color: Color.fromARGB(255, 247, 2, 2),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Arrange Your Exercises',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Drag to reorder ${widget.selectedExercisesList.length} exercises',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Exercise list
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final exercise = widget.selectedExercisesList[index]['exerciseName'];
                    return Container(
                      key: ValueKey(index),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 247, 2, 2),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        title: Text(
                          exercise,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.drag_handle,
                            color: Color.fromARGB(255, 247, 2, 2),
                            size: 20,
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: widget.selectedExercisesList.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex--;
                      }
                      final item = widget.selectedExercisesList.removeAt(oldIndex);
                      widget.selectedExercisesList.insert(newIndex, item);
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Magic wand button
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.wandMagicSparkles,
                    color: Color.fromARGB(255, 247, 2, 2),
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Auto-arrange',
                ),
              ),
              const Spacer(),
              
              // Cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Start Workout button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 247, 2, 2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow, size: 18),
                    const SizedBox(width: 4),
                    const Text(
                      'Start Workout',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      actionsPadding: EdgeInsets.zero,
    );
  }
}