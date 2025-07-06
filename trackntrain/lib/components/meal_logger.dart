import 'package:flutter/material.dart';
import 'package:trackntrain/utils/classes.dart';
import 'package:trackntrain/utils/connectivity.dart';
import 'package:trackntrain/utils/db_util_funcs.dart';
import 'package:trackntrain/utils/misc.dart';

class MealLoggerSheet extends StatefulWidget {
  const MealLoggerSheet({super.key});

  @override
  State<MealLoggerSheet> createState() => _MealLoggerSheetState();
}

class _MealLoggerSheetState extends State<MealLoggerSheet> {
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedMealType = 'Breakfast';
  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  final _formKey = GlobalKey<FormState>();
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void dispose() {
    _mealNameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveMealLog() async {
    final String mealName = _mealNameController.text.trim();
    final String description = _descController.text.trim();

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }
    Meal meal = Meal(
      mealType: _selectedMealType,
      mealName: mealName,
      description: description,
    );

    final isConnected = await _connectivityService.checkAndShowError(context,'No internet connection : Cannot log to database');
    if (!isConnected) {
      _mealNameController.clear();
      _descController.clear();
      if (mounted) Navigator.pop(context);
      return;
    }

    try {
      await createOrSaveMeal(meal, context);
      _mealNameController.clear();
      _descController.clear();
      setState(() {
        _selectedMealType = 'Breakfast';
      });
      if (mounted) Navigator.pop(context);
      showCustomSnackBar(
        context: context,
        message: 'Meal logged successfully',
        type: 'success',
      );
    } catch (e) {
      showCustomSnackBar(
        context: context,
        message: 'Error logging meal: $e',
        type: 'error',
      );
    }
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
        child: Form(
          key: _formKey,
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

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Meal Type',
                  labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                value: _selectedMealType,
                items:
                    _mealTypes.map((String type) {
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
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a food item';
                  }
                  return null;
                },
                controller: _mealNameController,
                decoration: InputDecoration(
                  labelText: 'Food Item',
                  labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    _saveMealLog();
                  },
                  child: Text(
                    'Save Meal',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
