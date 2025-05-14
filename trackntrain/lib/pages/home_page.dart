import 'package:flutter/material.dart';
import 'package:trackntrain/pages/profile_page.dart';
import 'package:trackntrain/tabs/home_tab.dart';
import 'package:trackntrain/tabs/train_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex=0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static final List<Widget> _widgetOptions=<Widget>[
    const HomeTab(),
    const TrainTab()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 5,
        automaticallyImplyLeading: false,
        title: const Text('TrackNTrain', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () async{
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ProfilePage(),)
              );
            },
            icon: Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(     
        backgroundColor: Colors.white,
        selectedItemColor: Colors.red,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), 
            label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Train',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
