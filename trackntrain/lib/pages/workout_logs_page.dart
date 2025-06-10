

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:trackntrain/components/prev_workout_card.dart';
import 'package:trackntrain/utils/auth_service.dart';

class WorkoutLogsPage extends StatefulWidget{
  const WorkoutLogsPage({super.key});

  @override
  State<WorkoutLogsPage> createState() => _WorkoutLogsPageState();
}

class _WorkoutLogsPageState extends State<WorkoutLogsPage> {
  ScrollController _scrollController=ScrollController();
  List<Map<String,dynamic>> workoutLogs=[];
  bool hasMoreData = true;
  bool isLoading = false;
  bool isInitialLoading = true;
  DocumentSnapshot? lastDoc;

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
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll(){
    if(_scrollController.position.pixels>=_scrollController.position.maxScrollExtent*0.8){
      _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async{
    if(isLoading) return;
    setState(() {
      isLoading = true;
      isInitialLoading = true;
    });

    try {
      Query query=FirebaseFirestore.instance
          .collection('userFullBodyWorkouts')
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading initial data: $e')),
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
          .collection('workouts')
          .where('userId', isEqualTo: AuthService.currentUser?.uid)
          .orderBy('createdAt', descending: true)
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
      print('Error loading more data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more data: $e')),
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

  Widget _buildSkeletonCard(){
    return Skeletonizer(
      enabled: isInitialLoading,
      child: PrevWorkoutCard(icon: Icons.fitness_center),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> log) {
    return PrevWorkoutCard(
      icon: Icons.fitness_center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Logs'),
        centerTitle: true,
      ),
      body: RefreshIndicator(onRefresh: _refreshData,
              child: _buildBody(),)
    );
  }


  Widget _buildBody(){
    if(isInitialLoading){
      return ListView.builder(itemBuilder: (context,index)=>_buildSkeletonCard(),itemCount: 10,);
    }
    if (workoutLogs.isEmpty && !isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No workout logs found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start tracking your workouts!',
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