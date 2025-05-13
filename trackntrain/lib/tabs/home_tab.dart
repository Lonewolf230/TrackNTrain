

import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget{
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String? _mood;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
                    DropdownMenuItem(
                      value: 'sore',
                      child: Text('Sore'),
                    ),
                    DropdownMenuItem(
                      value: 'cannot',
                      child: Text("Won't be able to train"),
                    ),
                  ],
                  onChanged:(String? value){
                      setState(() {
                        _mood = value;
                      });
                  }
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}