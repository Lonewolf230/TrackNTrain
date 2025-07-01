import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FullBodyTab extends StatelessWidget {
  const FullBodyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Full Body',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 247, 2, 2),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[50]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.grey[50]!],
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
                    color: const Color.fromARGB(
                      255,
                      247,
                      2,
                      2,
                    ).withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          247,
                          2,
                          2,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: const Color.fromARGB(255, 247, 2, 2),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hit all your muscles with this workout',
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
                            color: const Color.fromARGB(
                              255,
                              247,
                              2,
                              2,
                            ).withOpacity(0.1),
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
                          'Workouts Logs',
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
                      'View your previous workouts here. You can track your progress and see how you\'ve improved over time. You can also directly start a new workout based on your previous logs.',
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
                          context.goNamed('view-workout-logs',extra: 'userFullBodyWorkouts');
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
                            color: const Color.fromARGB(
                              255,
                              247,
                              2,
                              2,
                            ).withOpacity(0.1),
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
                          'Start Training',
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
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: OutlinedButton(
                        onPressed: () {
                          context.goNamed('create-full-body');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 247, 2, 2),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
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
                              'Create your Workout',
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
