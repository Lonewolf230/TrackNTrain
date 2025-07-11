import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trackntrain/main.dart';
import 'package:trackntrain/utils/auth_service.dart';
import 'package:trackntrain/utils/connectivity.dart';
import 'package:trackntrain/utils/misc.dart';

class MoodData {
  final DateTime date;
  final String mood;

  MoodData({required this.date, required this.mood});

  double get moodValue {
    switch (mood) {
      case 'energetic':
        return 3.0;
      case 'sore':
        return 2.0;
      case 'cannot':
        return 1.0;
      case '':
        return 0.0;
      default:
        return 0.0;
    }
  }

  Color get moodColor {
    switch (mood) {
      case 'energetic':
        return Colors.green;
      case 'sore':
        return Colors.orange;
      case 'cannot':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class MoodChart extends StatelessWidget {
  final List<MoodData> moodData;
  final DateTime currentWeekStart;
  final VoidCallback? onPreviousWeek;
  final VoidCallback? onNextWeek;
  final VoidCallback? onSelectDate;
  final bool isLoading;

  const MoodChart({
    super.key,
    required this.moodData,
    required this.currentWeekStart,
    this.onPreviousWeek,
    this.onNextWeek,
    this.onSelectDate,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final weekEnd = currentWeekStart.add(const Duration(days: 6));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Energy level Tracking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildWeekNavigation(context, weekEnd),
            const SizedBox(height: 8),
            _buildLegend(),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final weekSpots = _generateWeekSpots();

    if (weekSpots.isEmpty) {
      return const Center(
        child: Text(
          'No energy data available for this week / No Internet',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final dayIndex = value.toInt();
                if (dayIndex >= 0 && dayIndex < 7) {
                  final date = currentWeekStart.add(Duration(days: dayIndex));
                  final dayNames = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dayNames[dayIndex],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${date.day}/${date.month}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value == 1.0) {
                  return const Text(
                    'Cannot',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  );
                } else if (value == 2.0) {
                  return const Text(
                    'Sore',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  );
                } else if (value == 3.0) {
                  return const Text(
                    'Energetic',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        minX: 0,
        maxX: 6,
        minY: 0.5,
        maxY: 3.5,
        lineBarsData: [
          LineChartBarData(
            spots: weekSpots,
            isCurved: true,
            color: Colors.blue.shade600,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final dayIndex = spot.x.toInt();
                final currentDay = currentWeekStart.add(
                  Duration(days: dayIndex),
                );
                final moodForDay = moodData.firstWhere(
                  (data) => _isSameDay(data.date, currentDay),
                  orElse: () => MoodData(date: currentDay, mood: ''),
                );


                if (moodForDay.mood.isEmpty) {
                  return FlDotCirclePainter(radius: 0);
                }

                return FlDotCirclePainter(
                  radius: 6,
                  color: moodForDay.moodColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
            preventCurveOverShooting: true,
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final dayIndex = barSpot.x.toInt();
                final date = currentWeekStart.add(Duration(days: dayIndex));
                final mood = barSpot.y;
                String moodName = '';
                if (mood == 3.0) {
                  moodName = 'Energetic';
                } else if (mood == 2.0) {
                  moodName = 'Sore';
                } else if (mood == 1.0) {
                  moodName = "Cannot train";
                } else {
                  moodName = 'No data';
                }
                return LineTooltipItem(
                  '${date.day}/${date.month}/${date.year}\n$moodName',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateWeekSpots() {
    List<FlSpot> spots = [];

    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      final currentDay = currentWeekStart.add(Duration(days: dayIndex));

      final moodForDay = moodData.firstWhere(
        (data) => _isSameDay(data.date, currentDay),
        orElse: () => MoodData(date: currentDay, mood: ''),
      );

      // Only add spots for days with actual mood data
      if (moodForDay.mood.isNotEmpty) {
        spots.add(FlSpot(dayIndex.toDouble(), moodForDay.moodValue));
      }
    }

    return spots;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('Energetic', Colors.green),
          _buildLegendItem('Sore', Colors.orange),
          _buildLegendItem('Cannot', Colors.red),
        ],
      ),
    );
  }

  Widget _buildWeekNavigation(BuildContext context, DateTime weekEnd) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double availableWidth = constraints.maxWidth - 120; // 120 for buttons and spacing
      
      // Determine date format based on available width
      String dateText;
      if (availableWidth > 200) {
        dateText = '${currentWeekStart.day}/${currentWeekStart.month}/${currentWeekStart.year} - ${weekEnd.day}/${weekEnd.month}/${weekEnd.year}';
      } else if (availableWidth > 150) {
        dateText = '${currentWeekStart.day}/${currentWeekStart.month}/${currentWeekStart.year.toString().substring(2)} - ${weekEnd.day}/${weekEnd.month}/${weekEnd.year.toString().substring(2)}';
      } else {
        if (currentWeekStart.month == weekEnd.month && currentWeekStart.year == weekEnd.year) {
          dateText = '${currentWeekStart.day}-${weekEnd.day}/${currentWeekStart.month}/${currentWeekStart.year.toString().substring(2)}';
        } else if (currentWeekStart.year == weekEnd.year) {
          dateText = '${currentWeekStart.day}/${currentWeekStart.month} - ${weekEnd.day}/${weekEnd.month}/${weekEnd.year.toString().substring(2)}';
        } else {
          dateText = '${currentWeekStart.day}/${currentWeekStart.month}/${currentWeekStart.year.toString().substring(2)} - ${weekEnd.day}/${weekEnd.month}/${weekEnd.year.toString().substring(2)}';
        }
      }

      return Row(
        children: [
          GestureDetector(
            onTap: onPreviousWeek,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: GestureDetector(
              onTap: onSelectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        dateText,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          GestureDetector(
            onTap: onNextWeek,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ),
          ),
        ],
      );
    },
  );
}

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class MoodTrackingScreen extends StatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  State<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  DateTime currentWeekStart = DateTime.now();
  List<MoodData> currentWeekData = [];
  String suggestion = '';
  bool isLoading = false;

  @override
  void initState() {
    currentWeekStart = _getWeekStart(DateTime.now());
    _loadData();
    super.initState();
  }

  void _loadData() async {
    DateTime weekendDate = currentWeekStart.add(const Duration(days: 7));

    try {
      setState(() {
        isLoading = true;
      });
 
      final snapShot =
          await FirebaseFirestore.instance
              .collection('userMetaLogs')
              .where('userId', isEqualTo: AuthService.currentUser?.uid)
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(currentWeekStart),
              )
              .where(
                'createdAt',
                isLessThanOrEqualTo: Timestamp.fromDate(weekendDate),
              )
              .orderBy('createdAt')
              .get();

      setState(() {
        currentWeekData =
            snapShot.docs.map((doc) {
              final data = doc.data();
              final date = (data['createdAt'] as Timestamp).toDate();
              // Handle null mood values
              final mood = data['mood'] ?? '';
              return MoodData(date: date, mood: mood);
            }).toList();
      });
    } catch (e) {
      setState(() {
        currentWeekData = [];
        showGlobalSnackBar(message: 'Error loading mood data: $e', type: 'error');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: daysFromMonday));
  }

  void _selectDate() async {
    final selectedDate = await showDatePicker(
      barrierDismissible: true,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Theme.of(context).primaryColor,
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: currentWeekStart,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        currentWeekStart = _getWeekStart(selectedDate);
      });
      _loadData();
    }
  }

  void _goToPreviousWeek() {
    setState(() {
      currentWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    });
    _loadData();
  }

  void _goToNextWeek() {
    setState(() {
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: const EdgeInsets.all(16.0),
        child: MoodChart(
          moodData: currentWeekData,
          currentWeekStart: currentWeekStart,
          isLoading: isLoading,
          onSelectDate: _selectDate,
          onNextWeek: _goToNextWeek,
          onPreviousWeek: _goToPreviousWeek,
        ),
      );
  }
}
