import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:trackntrain/components/meal_logger.dart';
import 'package:trackntrain/components/stat.dart';
import 'package:trackntrain/utils/auth_service.dart';

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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[50]!,
            Colors.white,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 247, 2, 2),
                    const Color.fromARGB(255, 220, 20, 20),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.3),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AuthService.currentUser?.displayName ?? 'User',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'How are you feeling today?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton(
                    hint: Row(
                      children: [
                        Icon(
                          Icons.psychology_outlined,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Select your mood',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey[600],
                    ),
                    iconSize: 28.0,
                    dropdownColor: Colors.white,
                    value: _mood,
                    menuMaxHeight: 200,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'energetic',
                        child: Row(
                          children: [
                            Icon(Icons.flash_on, color: Colors.orange, size: 20),
                            SizedBox(width: 12),
                            Text('Energetic'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'sore',
                        child: Row(
                          children: [
                            Icon(Icons.healing, color: Colors.blue, size: 20),
                            SizedBox(width: 12),
                            Text('Sore'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'cannot',
                        child: Row(
                          children: [
                            Icon(Icons.pause_circle_outline, color: Colors.grey, size: 20),
                            SizedBox(width: 12),
                            Text("Won't be able to train"),
                          ],
                        ),
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
            const SizedBox(height: 32),
            
            // Stats Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      fontFamily: 'Poppins',
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
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.grey[50]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _showWeightInputDialog(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  FontAwesomeIcons.weightScale,
                                  color: const Color.fromARGB(255, 247, 2, 2),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Log Weight',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 247, 2, 2),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.grey[50]!,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _showMealLoggerSheet(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  FontAwesomeIcons.utensils,
                                  color: const Color.fromARGB(255, 247, 2, 2),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Log Meal',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 247, 2, 2),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWeightInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                FontAwesomeIcons.weightScale,
                color: const Color.fromARGB(255, 247, 2, 2),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Log Weight',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: _weightController,
          decoration: InputDecoration(
            labelText: 'Enter your weight (Kg)',
            labelStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color.fromARGB(255, 247, 2, 2),
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
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
                    SnackBar(
                      content: Text(
                        'Weight logged: $weight kg',
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                      backgroundColor: const Color.fromARGB(255, 247, 2, 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 247, 2, 2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
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