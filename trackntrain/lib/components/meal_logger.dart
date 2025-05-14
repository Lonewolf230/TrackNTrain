import 'package:flutter/material.dart';

class MealLoggerSheet extends StatefulWidget {
  const MealLoggerSheet({super.key});

  @override
  State<MealLoggerSheet> createState() => _MealLoggerSheetState();
}

class _MealLoggerSheetState extends State<MealLoggerSheet> {
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  String _selectedMealType = 'Breakfast';
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  
  @override
  void dispose() {
    _mealNameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Log Your Meal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Meal Type Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Meal Type',
                border: OutlineInputBorder(),
              ),
              value: _selectedMealType,
              items: _mealTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedMealType = newValue;
                  });
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Meal Name
            TextField(
              controller: _mealNameController,
              decoration: const InputDecoration(
                labelText: 'Food Item',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Calories
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calories',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // Save meal logic
                  if (_mealNameController.text.isNotEmpty && 
                      _caloriesController.text.isNotEmpty) {
                    
                    // Save meal
                    final String mealName = _mealNameController.text;
                    final int? calories = int.tryParse(_caloriesController.text);
                    
                    if (calories != null) {
                      print('Meal saved: $_selectedMealType - $mealName ($calories calories)');
                      // TODO: Add logic to save meal to database
                      
                      // Show confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$_selectedMealType logged: $mealName')),
                      );
                      
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text('Save Meal', style: TextStyle(fontSize: 16,color: Theme.of(context).primaryColor)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
