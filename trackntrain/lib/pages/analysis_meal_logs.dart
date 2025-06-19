import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:trackntrain/components/analysis_page_card.dart';
import 'package:trackntrain/components/suggestion_card.dart';
import 'package:trackntrain/tabs/mood_chart.dart';
import 'package:trackntrain/tabs/weight_chart.dart';

class AnalysisMealLogs extends StatefulWidget {
  const AnalysisMealLogs({super.key});

  @override
  State<AnalysisMealLogs> createState() => _AnalysisMealLogsState();
}

class _AnalysisMealLogsState extends State<AnalysisMealLogs> {
  String suggestion = '';
  bool isLoadingSuggestion = false;

  Future<void> fetchSuggestion() async {
    setState(() {
      isLoadingSuggestion = true;
    });
    // Simulate a network call to fetch suggestion
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      suggestion = "Analyzing your meal logs can provide valuable insights into your eating habits and nutritional intake. By reviewing the types of foods you consume, portion sizes, and meal timing, you can identify patterns that may be affecting your health and fitness goals. For example, you might discover that you tend to skip breakfast or that you often snack late at night.\n\nThis information can help you make more informed decisions about your diet, such as adjusting portion sizes, incorporating more whole foods, or planning meals ahead of time to avoid unhealthy choices. Regularly analyzing your meal logs can lead to better nutrition and overall well-being.";
      isLoadingSuggestion = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    final List<HealthTrackingCard> analysisCards = [
      HealthTrackingCard(
        title: 'Meal Logs',
        subtitle: 'View your meal logs per day',
        icon: Icons.access_time,
        onTap: () {
          context.goNamed(
            'energy-level-logs',
            queryParameters: {'type': 'meal'},
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: [
            ...analysisCards.map(
              (card) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: card,
              ),
            ),
            const SizedBox(height: 16),
            WeightTrackingScreen(),
            const SizedBox(height: 16),
            MoodTrackingScreen(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoadingSuggestion? null : fetchSuggestion,
                style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                label: Text( isLoadingSuggestion?'Analysing':'Get AI Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                ),
                icon:isLoadingSuggestion? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ) : Icon(FontAwesomeIcons.brain,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SuggestionCard(
              suggestion:suggestion,
              isLoading: isLoadingSuggestion,
              // showTypingIndicator: true,
            ),
          ]
        ),
      ),
    );
  }
}
