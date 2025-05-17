import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:trackntrain/components/meal_logger.dart';
import 'package:trackntrain/components/stat.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String? _mood;
  final TextEditingController _weightController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Welcome Manish',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'How are you feeling today?',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DropdownButtonHideUnderline(
              child: ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton(
                  hint: const Text('Select your mood'),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: 40.0,
                  dropdownColor: Colors.white,
                  value: _mood,
                  menuMaxHeight: 200,
                  items: const [
                    DropdownMenuItem(
                      value: 'energetic',
                      child: Text('Energetic'),
                    ),
                    DropdownMenuItem(value: 'sore', child: Text('Sore')),
                    DropdownMenuItem(
                      value: 'cannot',
                      child: Text("Won't be able to train"),
                    ),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _mood = value;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Stat(
            icon: FontAwesomeIcons.fire,
            count: 100,
            subtitle: 'Calories Burnt',
          ),
          Stat(icon: FontAwesomeIcons.bolt, count: 69, subtitle: 'Streak Days'),
          Stat(
            icon: FontAwesomeIcons.personWalking,
            count: 10000,
            subtitle: 'Steps Taken',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                  onPressed: () {
                    _showWeightInputDialog(context);
                  },
                  icon: Icon(
                    FontAwesomeIcons.weightScale,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'Log weight',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                  onPressed: () {
                    _showMealLoggerSheet(context);
                  },
                  icon: Icon(
                    FontAwesomeIcons.utensils,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'Log meal',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showWeightInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Log Weight'),
            content: TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Log your weight (Kg)',
                labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Save weight logic here
                  if (_weightController.text.isNotEmpty) {
                    final double? weight = double.tryParse(
                      _weightController.text,
                    );
                    if (weight != null) {
                      print('Weight saved: $weight kg');
                      // TODO: Add logic to save weight to database
                      _weightController.clear();
                      Navigator.pop(context);

                      // Show confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Weight logged: $weight kg')),
                      );
                    }
                  }
                },
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // Show bottom sheet for meal logging
  void _showMealLoggerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const MealLoggerSheet(),
    );
  }
}
