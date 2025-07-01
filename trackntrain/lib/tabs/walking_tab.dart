
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class WalkingTab extends StatelessWidget{
  const WalkingTab({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Walking', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
            body: Container(
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey[50]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        FontAwesomeIcons.personWalking,
                        color: const Color.fromARGB(255, 247, 2, 2),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Go for a nice walk to stay active and healthy!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontFamily: 'Poppins',
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.history,
                            color: const Color.fromARGB(255, 247, 2, 2),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Previous Sessions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'View your previous walk and jog logs here. You can track your progress and see how you\'ve improved over time.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontFamily: 'Poppins',
                      ),
                    
                    ),
                    Text(
                      'Logs will be auto deleted after 90 days.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.withOpacity(0.1),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                        ),
                        onPressed: () {
                          context.goNamed('view-workout-logs',extra: 'userWalkRecords');
                        },
                        label: Text(
                          'View Logs',
                          style: TextStyle(color: Colors.red),
                        ),
                        icon: Icon(Icons.arrow_circle_right_rounded,color: Colors.red,),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: const Color.fromARGB(255, 247, 2, 2),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Start Walking',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    

                    
                    const SizedBox(height: 16),
                    
                    // Create Workout Button
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: OutlinedButton(
                        onPressed: () {
                          context.goNamed('walk-progress');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 247, 2, 2),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 247, 2, 2),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.create, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Let's walk",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}