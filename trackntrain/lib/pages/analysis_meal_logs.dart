import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trackntrain/components/analysis_page_card.dart';

class AnalysisMealLogs extends StatefulWidget {
  const AnalysisMealLogs({super.key});

  @override
  State<AnalysisMealLogs> createState() => _AnalysisMealLogsState();
}

class _AnalysisMealLogsState extends State<AnalysisMealLogs> {
  @override
  Widget build(BuildContext context) {
    final List<HealthTrackingCard> analysisCards = [
      HealthTrackingCard(
        title: 'Energy level logs',
        subtitle: 'Analyze your energy levels each day',
        icon: Icons.sentiment_satisfied,
        onTap: () {
          context.goNamed(
            'energy-level-logs',
            queryParameters: {'type' : 'mood'},
          );
        },
      ),
      HealthTrackingCard(
        title: 'Weight Progress',
        subtitle: 'Track your weight changes over time',
        icon: Icons.pie_chart,
        onTap: () {
          context.goNamed(
            'energy-level-logs',
            queryParameters: {'type' : 'weight'},
          );
        },
      ),
      HealthTrackingCard(
        title: 'Meal Logs',
        subtitle: 'View your meal logs per day',
        icon: Icons.access_time,
        onTap: () {
          context.goNamed(
            'energy-level-logs',
            queryParameters: {'type' : 'meal'},
          );
        },
      ),
      HealthTrackingCard(
        title: 'Sleep Logs',
        subtitle: 'Analyze your sleep patterns',
        icon: Icons.bedtime,
        onTap: () {
          context.goNamed(
            'energy-level-logs',
            queryParameters: {'type' : 'sleep'},
          );
        },
      ),
      HealthTrackingCard(
        title: 'Steps Tracker',
        subtitle: 'Track your daily steps',
        icon: Icons.directions_walk,
        onTap: () {
          context.goNamed(
            'energy-level-logs',
            queryParameters: {'type' : 'steps'},
          );
        },
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        title: const Text(
          'Analysis Meal Logs',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children:
              analysisCards
                  .map(
                    (card) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: card,
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
