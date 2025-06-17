import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackntrain/components/workout_data.dart';
import 'package:intl/intl.dart';
import 'package:trackntrain/providers/workout_providers.dart';
import 'package:trackntrain/utils/db_util_funcs.dart';

class PrevWorkoutCard extends ConsumerWidget {
  const PrevWorkoutCard({
    super.key,
    required this.icon,
    required this.workoutLog,
    required this.workoutType,
    this.onDelete,
    this.onUndo
  });
  final IconData icon;
  final Map<String, dynamic> workoutLog;
  final String workoutType;
  final VoidCallback? onDelete;
  final VoidCallback? onUndo;

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  void formWorkoutState(WidgetRef ref, BuildContext context) {
    List<Map<String, dynamic>> selectedExercises =
        (workoutLog['exercises'] as List).map((exercise) {
          return exercise as Map<String, dynamic>;
        }).toList();
    print('Selected Exercises: $selectedExercises');
    print('');
    print('');
    ref.read(workoutProvider.notifier).insertWorkoutData(selectedExercises);
    List<Map<String, dynamic>> workout = ref.read(
      selectedExercisesListProvider,
    );
    print('Selected Exercises: $workout');
    context.goNamed(
      'start-full-body',
      queryParameters: {'mode': 'reuse', 'workoutId': workoutLog['id'] ?? ''},
      extra: {'workoutData': workout},
    );
    print('Finished nav');
  }

  void _handleDelete(BuildContext context){
    final workoutData=Map<String,dynamic>.from(workoutLog);
    final workoutId=workoutLog['id'];

    onDelete?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: Text('${workoutLog['name'] ?? 'Workout'} deleted',style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo', 
          backgroundColor: Colors.white,
          textColor: Theme.of(context).primaryColor,
          onPressed: (){
            onUndo?.call();
          }),
      )
    ).closed.then((reason){
      if(reason!=SnackBarClosedReason.action){
        _permanentlyDelete(workoutId, context);
      }
    });
  }

  void _permanentlyDelete(String workoutId,BuildContext context){
    try{
      String collection='';
      if(workoutType=='userFullBodyWorkouts'){
        collection='userFullBodyWorkouts';
      }
      else if(workoutType=='userHiitWorkouts'){
        collection='userHiitWorkouts';
      }
      else if(workoutType=='userWalkRecords'){
        collection='userWalkRecords';
      }
      if(collection.isNotEmpty){
        deleteDoc(workoutId, collection, context);
      }
    }
    catch(e){
      print('Error deleting workout: $e');

    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(
        workoutLog['id'] ?? 'workout-${DateTime.now().millisecondsSinceEpoch}',
      ),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      onDismissed: (direction)=>_handleDelete(context),
      child: InkWell(
        onTap: () {
          print('Workout Log tapped');
          print('Workout Log Details: : ${workoutLog.toString()}');
          print('Workout Type: $workoutType');
          if (workoutType == 'userFullBodyWorkouts') {
            formWorkoutState(ref, context);
          } else if (workoutType == 'userHiitWorkouts') {
            print('Hiit workout log tapped');
            print('Workout Log Details: : ${workoutLog}');
            print('Workout Id: ${workoutLog['id']}');
            context.goNamed(
              'hiit-started',
              queryParameters: {
                'mode': 'reuse',
                'rounds': workoutLog['rounds'].toString(),
                'rest': workoutLog['restDuration'].toString(),
                'work': workoutLog['workDuration'].toString(),
                'workoutId': workoutLog['id'] ?? '',
                'name':workoutLog['name'] ?? '',
              },
              extra:workoutLog['exercises'].map((e)=>e.toString()).toList(),
            );
          } else {
            return;
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey[50]!],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Workout Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      247,
                      2,
                      2,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color.fromARGB(255, 247, 2, 2),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workoutLog['name'] ?? 'Workout Name',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formatTimestamp(
                              workoutLog['createdAt'] as Timestamp,
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      247,
                      2,
                      2,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.info_outline,
                      size: 24,
                      color: Color.fromARGB(255, 247, 2, 2),
                    ),
                    onPressed: () {
                      print('Workout Log Details: : $workoutLog');
                      showWorkoutDialog(context, workoutLog);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
