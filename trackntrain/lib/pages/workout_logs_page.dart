import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:trackntrain/components/prev_workout_card.dart';
import 'package:trackntrain/utils/auth_service.dart';
import 'package:trackntrain/utils/connectivity.dart';
import 'package:trackntrain/utils/misc.dart';

class WorkoutLogsPage extends StatefulWidget{
  const WorkoutLogsPage({super.key,required this.type});
  final String type;
  @override
  State<WorkoutLogsPage> createState() => _WorkoutLogsPageState();
}

class _WorkoutLogsPageState extends State<WorkoutLogsPage> {
  final ScrollController _scrollController=ScrollController();
  List<Map<String,dynamic>> workoutLogs=[];
  List<Map<String,dynamic>> deletedWorkouts=[];
  bool hasMoreData = true;
  bool isLoading = false;
  bool isInitialLoading = true;
  DocumentSnapshot? lastDoc;
  IconData icon = Icons.fitness_center;
  String workoutType='workout'; 
  final ConnectivityService _connectivityService = ConnectivityService();

  static const int pageSize = 10; 

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll(){
    if(_scrollController.position.pixels>=_scrollController.position.maxScrollExtent*0.8){
      _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async{
    await _connectivityService.checkAndShowError(context, 'No internet connection. Logs shown might not be correct.');
    if(isLoading) return;
    setState(() {
      isLoading = true;
      isInitialLoading = true;
    });

    try {
      Query query=FirebaseFirestore.instance
          .collection('${widget.type}')
          .where('userId',isEqualTo: AuthService.currentUser?.uid)
          .orderBy('createdAt',descending: true)
          .limit(pageSize);

      QuerySnapshot snapshot=await query.get();

      if(snapshot.docs.isNotEmpty){
        lastDoc=snapshot.docs.last;
        workoutLogs=snapshot.docs
            .map((doc)=>{
              'id':doc.id,
              ...doc.data() as Map<String,dynamic>
            }).toList();
        hasMoreData = snapshot.docs.length == pageSize;
      }
      else{ hasMoreData = false;}
    } catch (e) {
      if(!context.mounted) return;
      showCustomSnackBar(
        context: context,
        message:  'Error loading initial data: $e',
        type: 'error'
      );
    }
    finally{
      setState(() {
        isLoading = false;
        isInitialLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async{
    if(isLoading || !hasMoreData || lastDoc == null) return;
    setState(() {
      isLoading = true;
    });
    try {
      Query query = FirebaseFirestore.instance
          .collection('${widget.type}')
          .where('userId', isEqualTo: AuthService.currentUser?.uid)
          .orderBy('updatedAt', descending: true)
          .startAfterDocument(lastDoc!)
          .limit(pageSize);

      QuerySnapshot snapshot = await query.get();
      
      if (snapshot.docs.isNotEmpty) {
        lastDoc = snapshot.docs.last;
        List<Map<String, dynamic>> newData = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>
                })
            .toList();
        
        workoutLogs.addAll(newData);
        hasMoreData = snapshot.docs.length == pageSize;
      } else {
        hasMoreData = false;
      }
    } catch (e) {
      showCustomSnackBar(
        context: context, 
        message: 'Error loading more data: $e',
        type: 'error'
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      workoutLogs.clear();
      lastDoc = null;
      hasMoreData = true;
    });
    await _loadInitialData();
  }

  void _deleteWorkout(String workoutId){
    setState((){
      final index=workoutLogs.indexWhere((workout)=>workout['id']==workoutId);
      if(index!=-1){
        final deletedWorkout=workoutLogs.removeAt(index);
        deletedWorkouts.add(deletedWorkout);
      }
    });
  }

  void _undoDelete(String workoutId){
    setState((){
      final index=deletedWorkouts.indexWhere((workout)=>workout['id']==workoutId);
      if(index!=-1){
        final restoredWorkout=deletedWorkouts.removeAt(index);
        workoutLogs.insert(0,restoredWorkout);

        workoutLogs.sort((a, b) {
          return (b['createdAt'] as Timestamp).compareTo(a['createdAt'] as Timestamp);
        });
      }
    });
  }

  Widget _buildSkeletonCard(){
    return Skeletonizer(
      enabled: isInitialLoading,
      child: PrevWorkoutCard(icon: Icons.fitness_center,
        workoutLog: {
          'id': '',
          'createdAt': Timestamp.now(),
          'workoutName': '',
          'duration': 0,
          'caloriesBurned': 0,
          'exercises': [],
        },
        workoutType: workoutType,
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> log) {
    return PrevWorkoutCard(
      icon: Icons.fitness_center,
      workoutLog:log,
      workoutType: widget.type,
      onDelete:()=>_deleteWorkout(log['id']),
      onUndo:()=>_undoDelete(log['id'])
    );
  }

  @override
  Widget build(BuildContext context) {

    if(widget.type=='userHiitWorkouts'){
      icon=FontAwesomeIcons.heartCircleBolt;
      workoutType='HIIT';
    }
    else if(widget.type=='userWalkRecords'){
      icon=FontAwesomeIcons.personWalking;
      workoutType='Walk/Jog';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$workoutType Logs'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
          border: Border.all(
            color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: RefreshIndicator(onRefresh: _refreshData,
                child: _buildBody(),
        ),
      )
    );
  }


  Widget _buildBody(){
    if(isInitialLoading){
      return ListView.builder(itemBuilder: (context,index)=>_buildSkeletonCard(),itemCount: 10,);
    }
    if (workoutLogs.isEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No $workoutType logs found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start tracking your $workoutType!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.builder(controller: _scrollController,itemBuilder:(builder,index){
      if(index<workoutLogs.length){
        return _buildWorkoutCard(workoutLogs[index]);
      }
      else if(hasMoreData && isLoading){
        return _buildSkeletonCard();
      }
      else{
        return const SizedBox.shrink();
      }
    } ,itemCount: workoutLogs.length+(hasMoreData?1:0),);

  }
}