import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:trackntrain/components/analysis_page_card.dart';
import 'package:trackntrain/components/suggestion_card.dart';
import 'package:trackntrain/config.dart';
import 'package:trackntrain/tabs/mood_chart.dart';
import 'package:trackntrain/tabs/weight_chart.dart';
import 'package:dio/dio.dart';
import 'package:trackntrain/utils/auth_service.dart';
import 'package:trackntrain/utils/misc.dart';

class AnalysisMealLogs extends StatefulWidget {
  const AnalysisMealLogs({super.key});

  @override
  State<AnalysisMealLogs> createState() => _AnalysisMealLogsState();
}

class _AnalysisMealLogsState extends State<AnalysisMealLogs> {
  String suggestion = '';
  bool isLoadingSuggestion = false;
  bool isValid=true;

  Future<void> fetchSuggestion() async {
    final dio = Dio();
    String responseText = '';
    try {
      setState(() {
        isLoadingSuggestion = true;
      });

      final response = await dio.post(
        AppConfig.aiUrl,
        data: {'userId': AuthService.currentUser?.uid},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      responseText = response.data['aiResponse'] as String;
    } on DioException catch (e) {
      showCustomSnackBar(
        context: context,
        message: 'Failed to fetch suggestion. Please try again later.',
        type: 'error',
      );
    } catch (e) {
      print('Unexpected error: $e');
      showCustomSnackBar(
        context: context,
        message:
            'You have reached the limit of AI requests for this week. Please try again the next Monday.',
        type: 'error',
      );
    } finally {
      setState(() {
        suggestion = responseText;
        isLoadingSuggestion = false;
      });
    }
  }

  void checkValidityForAIRequest() async {
    final DocumentReference userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(AuthService.currentUser?.uid);
    final DocumentSnapshot snapshot = await userDoc.get();
    final lastAIResponseTime = snapshot.get('lastAIResponseAt') as Timestamp?;

    if (lastAIResponseTime != null) {
      final now = DateTime.now();
      final lastTime = lastAIResponseTime.toDate();

      int weekNumber(DateTime date) {
        final firstDayOfYear = DateTime(date.year, 1, 1);
        final daysOffset = firstDayOfYear.weekday - 1;
        final firstMonday = firstDayOfYear.subtract(Duration(days: daysOffset));
        return ((date.difference(firstMonday).inDays) / 7).floor() + 1;
      }

      final nowWeek = weekNumber(now);
      final nowYear = now.year;
      final lastWeek = weekNumber(lastTime);
      final lastYear = lastTime.year;

      if (nowYear == lastYear && nowWeek == lastWeek) {
        showCustomSnackBar(
          context: context,
          message:'You have reached the limit of AI requests for this week. Please try again next Monday. You can view your previous week insights down below.',
          type: 'error',
        );
        
        //prev week insights as fallback

        final DocumentReference userDoc=FirebaseFirestore.instance
            .collection('users')
            .doc(AuthService.currentUser?.uid);
        final DocumentSnapshot userSnapshot = await userDoc.get();
        final previousWeekSuggestion = userSnapshot.get('lastAIResponse') as String?;
        setState(() {
          isValid = false;
          suggestion = previousWeekSuggestion ?? 'No insights available for the previous week.';
        });
        return;
      }
    }
    await fetchSuggestion();
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
                onPressed:
                    isLoadingSuggestion ? null : checkValidityForAIRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                label: Text(
                  isLoadingSuggestion ? 'Analysing' : 'Get AI Insights',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                icon:
                    isLoadingSuggestion
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                        : Icon(FontAwesomeIcons.brain, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            SuggestionCard(
              suggestion: suggestion,
              isLoading: isLoadingSuggestion,
              showTypingIndicator:isValid? true:false,
            ),
          ],
        ),
      ),
    );
  }
}
