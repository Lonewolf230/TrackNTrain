import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:trackntrain/components/custom_snack_bar.dart';
import 'package:trackntrain/components/meal_card.dart';
import 'package:trackntrain/main.dart';
import 'package:trackntrain/utils/auth_service.dart';
import 'package:trackntrain/utils/connectivity.dart';

class MealLogs extends StatefulWidget {
  const MealLogs({super.key});

  @override
  State<MealLogs> createState() => _MealLogsState();
}

class _MealLogsState extends State<MealLogs> {



  final ScrollController _scrollController=ScrollController();
  List<Map<String,dynamic>> mealLogs=[];
  List<Map<String,dynamic>> deletedLogs=[];
  bool hasMoreData = true;
  bool isLoading = false;
  bool isInitialLoading = true;
  DocumentSnapshot? lastDoc;
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
    if(_scrollController.position.pixels>=_scrollController.position.maxScrollExtent*0.7){
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
      bool isConnected= await _connectivityService.checkAndShowError(context, 'No internet connection. Logs shown might not be correct.');
      if(isConnected){
      Query query=FirebaseFirestore.instance
          .collection('userMeals')
          .where('userId',isEqualTo: AuthService.currentUser?.uid)
          .orderBy('createdAt',descending: true)
          .limit(pageSize);

      QuerySnapshot snapshot=await query.get();

      if(snapshot.docs.isNotEmpty){
        lastDoc=snapshot.docs.last;
        mealLogs=snapshot.docs
            .map((doc)=>{
              'id':doc.id,
              ...doc.data() as Map<String,dynamic>
            }).toList();
        hasMoreData = snapshot.docs.length == pageSize;
      }
  }
      else{ 
        hasMoreData = false;
        mealLogs=[];
      }
    } catch (e) {
      if(!context.mounted) return;
        CustomSnackBar(message: 'Error loading initial data: $e', type: 'error').buildSnackBar(context);
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
          .collection('userMeals')
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
        
        mealLogs.addAll(newData);
        hasMoreData = snapshot.docs.length == pageSize;
      } else {
        hasMoreData = false;
      }
    } catch (e) {
      showGlobalSnackBar(message: 'Error loading more data: $e', type: 'error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      mealLogs.clear();
      lastDoc = null;
      hasMoreData = true;
    });
    await _loadInitialData();
  }

  void _deleteWorkout(String mealLogId){
    setState((){
      final index=mealLogs.indexWhere((meal)=>meal['id']==mealLogId);
      if(index!=-1){
        final deletedWorkout=mealLogs.removeAt(index);
        deletedLogs.add(deletedWorkout);
      }
    });
  }

  void _undoDelete(String mealLogId){
    setState((){
      final index=deletedLogs.indexWhere((meal)=>meal['id']==mealLogId);
      if(index!=-1){
        final restoredLog=deletedLogs.removeAt(index);
        mealLogs.insert(0,restoredLog);

        mealLogs.sort((a, b) {
          return (b['createdAt'] as Timestamp).compareTo(a['createdAt'] as Timestamp);
        });
      }
    });
  }

  Widget _buildSkeletonCard(){
    return Skeletonizer(
      enabled: isInitialLoading,
      child: MealCard(
        id: '',
        onDelete: (){},
        onUndo: (){},
        date: DateTime.now(),
        breakfast: {
          'dish': '',
          'calories': 0,
          'protein': '',
          'time': '',
        },
        lunch: {

        },
        dinner: {},
        snacks: [],
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> log) {
    return SizedBox(
      width: double.infinity,
      child: MealCard(
        key: ValueKey(log['id']),
        id: log['id'],
        onDelete:()=> _deleteWorkout(log['id']),
        onUndo:()=> _undoDelete(log['id']),
        breakfast: log['breakfast'] ?? {},
        lunch: log['lunch'] ?? {},
        dinner: log['dinner'] ?? {},
        snacks: (log['snacks'] as List<dynamic>?)?.cast<Map<String, dynamic>>().toList() ?? [],
        date: log['createdAt'] is Timestamp
            ? (log['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Logs'),
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
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: _buildBody(),
              ),
            ),
          ],
        )
        
        ),
      );
  }


  Widget _buildBody(){
    if(isInitialLoading){
      return ListView.builder(itemBuilder: (context,index)=>_buildSkeletonCard(),itemCount: 10,);
    }

    if (mealLogs.isEmpty && !isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.food_bank, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No logs found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start tracking your meals!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return ListView.builder(controller: _scrollController,itemBuilder:(builder,index){
      if(index<mealLogs.length){
        return _buildWorkoutCard(mealLogs[index]);
      }
      else if(hasMoreData && isLoading){
        return _buildSkeletonCard();
      }
      else{
        return const SizedBox.shrink();
      }
    } ,itemCount: mealLogs.length+(hasMoreData?1:0),);

  }
}