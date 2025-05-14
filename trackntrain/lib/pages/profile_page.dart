import 'package:flutter/material.dart';
import 'package:trackntrain/utils/quotes.dart';
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset(
                'assets/images/user.jpg',
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manish',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600,color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 5),
                  const Text('manish2306j@gmail.com'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Your Info',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 80,
                      child: Text(
                        'Height:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Text('5.8 ft'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 80,
                      child: Text(
                        'Weight:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Text('70 kg'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 80,
                      child: Text(
                        'Age:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Text('23 years'),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () {},
                label: Text(
                  'Logout',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                icon: Icon(Icons.logout, color: Theme.of(context).primaryColor),
              ),
          
              TextButton.icon(
                style: TextButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () {},
                label: Text(
                  'Delete Account',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                icon: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
