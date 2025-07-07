import 'package:flutter/material.dart';
import 'package:trackntrain/utils/db_util_funcs.dart';
import 'package:trackntrain/utils/misc.dart';

class MealCard extends StatelessWidget {
  final DateTime date;
  final Map<String, dynamic> breakfast;
  final Map<String, dynamic> lunch;
  final Map<String, dynamic> dinner;
  final List<Map<String, dynamic>> snacks;
  final VoidCallback? onUndo;
  final VoidCallback? onDelete;
  final String id;

  const MealCard({
    super.key,
    required this.id,
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
    required this.onUndo,
    required this.onDelete,
  });


  void _handleDelete(BuildContext context){
    final mealLogId=id;
    onDelete?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(20,0,20,80),
        content: Text('Meal Log deleted',style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo', 
          backgroundColor: Colors.white,
          textColor: Colors.blue,
          onPressed: (){
            onUndo?.call();
          }),
      )
    ).closed.then((reason){
      if(reason!=SnackBarClosedReason.action){
        _permanentlyDelete(mealLogId, context);
      }
    });
  }

  void _permanentlyDelete(String mealLogId,BuildContext context){
    try{
        deleteDoc(mealLogId, 'userMeals', context);
    }
    catch(e){
      showCustomSnackBar(
        context: context, 
        message: '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(date.toIso8601String()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      onDismissed: (direction) {
        _handleDelete(context);
      },
      child: Container(
        width: double.infinity, 
        child: Card(
          // surfaceTintColor: Colors.red.withOpacity(0.4),
          margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 5),
          elevation: 4,
          child: InkWell(
            onTap: () {
              _showMealDetails(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(date),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to view meal details',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showMealDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Meals for ${_formatDate(date)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMealSection('Breakfast', breakfast, Icons.free_breakfast,context),
                          const SizedBox(height: 16),
                          _buildMealSection('Lunch', lunch, Icons.lunch_dining,context),
                          const SizedBox(height: 16),
                          _buildMealSection('Dinner', dinner, Icons.dinner_dining,context),
                          const SizedBox(height: 16),
                          _buildSnacksSection(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMealSection(String mealName, Map<String, dynamic> mealData, IconData icon,BuildContext context){
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                mealName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...mealData.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key}: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildSnacksSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cookie, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Snacks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (snacks.isEmpty)
            const Text(
              'No snacks recorded',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...snacks.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> snack = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Snack ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...snack.entries.map((snackEntry) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${snackEntry.key}: ',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Expanded(
                            child: Text(
                              snackEntry.value.toString(),
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}

