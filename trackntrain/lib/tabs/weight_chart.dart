import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trackntrain/utils/auth_service.dart';
import 'package:trackntrain/utils/misc.dart';

class WeightData {
  final DateTime date;
  final double weight;

  WeightData({required this.date, required this.weight});
}

class WeightChart extends StatelessWidget {
  final List<WeightData> weightData;
  final DateTime currentWeekStart;
  final VoidCallback? onPreviousWeek;
  final VoidCallback? onNextWeek;
  final VoidCallback? onSelectDate;
  final bool isLoading;

  const WeightChart({
    super.key, 
    required this.weightData,
    required this.currentWeekStart,
    this.onPreviousWeek,
    this.onNextWeek,
    this.onSelectDate,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final weekEnd = currentWeekStart.add(const Duration(days: 6));
    
    if (weightData.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildWeekNavigation(context, weekEnd),
              const SizedBox(height: 32),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const Center(
                      child: Text(
                        'No weight data available for this week',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    }

    final minWeight = weightData
        .map((e) => e.weight)
        .reduce((a, b) => a < b ? a : b);
    final maxWeight = weightData
        .map((e) => e.weight)
        .reduce((a, b) => a > b ? a : b);
    final weightRange = maxWeight - minWeight;
    final padding = weightRange > 0 ? weightRange * 0.1 : 2.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weight Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildWeightSummary(),
              ],
            ),
            const SizedBox(height: 16),
            _buildWeekNavigation(context, weekEnd),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getHorizontalInterval(
                      minWeight,
                      maxWeight,
                    ),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final dayIndex = value.toInt();
                          if (dayIndex >= 0 && dayIndex < 7) {
                            final date = currentWeekStart.add(Duration(days: dayIndex));
                            final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
                        reservedSize: 50,
                        interval: _getHorizontalInterval(minWeight, maxWeight),
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(1)}kg',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          );
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
                  minY: minWeight - padding,
                  maxY: maxWeight + padding,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateWeekSpots(),
                      isCurved: true,
                      color: Colors.red.shade600,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: Colors.red.shade600,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.red.shade600.withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final dayIndex = barSpot.x.toInt();
                          final date = currentWeekStart.add(Duration(days: dayIndex));
                          final weight = barSpot.y;
                          return LineTooltipItem(
                            '${date.day}/${date.month}/${date.year}\n${weight.toStringAsFixed(1)}kg',
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekNavigation(BuildContext context, DateTime weekEnd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
        GestureDetector(
          onTap: onSelectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${currentWeekStart.day}/${currentWeekStart.month}/${currentWeekStart.year} - ${weekEnd.day}/${weekEnd.month}/${weekEnd.year}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
  }

  List<FlSpot> _generateWeekSpots() {
    List<FlSpot> spots = [];
    
    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      final currentDay = currentWeekStart.add(Duration(days: dayIndex));
      
      final weightForDay = weightData.firstWhere(
        (data) => _isSameDay(data.date, currentDay),
        orElse: () => WeightData(date: currentDay, weight: double.nan),
      );
      
      if (!weightForDay.weight.isNaN) {
        spots.add(FlSpot(dayIndex.toDouble(), weightForDay.weight));
      }
    }
    
    return spots;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Widget _buildWeightSummary() {
    if (weightData.isEmpty) return const SizedBox(width: 20,height: 20,);
    final List<double> weights = weightData.map((e) => e.weight).toList();
    print('Weight Data : ${weights}');
    final currentWeight = weightData.last.weight;
    final startWeight = weightData.first.weight;
    final weightChange = currentWeight - startWeight;
    final isPositive = weightChange > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${currentWeight.toStringAsFixed(1)}kg',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (weightData.length > 1)
          Text(
            '${isPositive ? '+' : ''}${weightChange.toStringAsFixed(1)}kg',
            style: TextStyle(
              fontSize: 14,
              color: isPositive ? Colors.red : Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  double _getHorizontalInterval(double min, double max) {
    final range = max - min;
    if (range <= 5) return 1.0;
    if (range <= 10) return 2.0;
    if (range <= 20) return 5.0;
    return 10.0;
  }
}

class WeightTrackingScreen extends StatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> {
  DateTime currentWeekStart = DateTime.now();
  List<WeightData> currentWeekData = [];
  String suggestion='';
  bool isLoading=false;

  @override
  void initState() {
    super.initState();
    currentWeekStart = _getWeekStart(DateTime.now());
    _loadWeekData();
  }

  DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysFromMonday));
  }

  void _loadWeekData() async{

    final weekEnd=currentWeekStart.add(const Duration(days: 6));
    print('Loaded data for week: ${currentWeekStart.toLocal()} - ${weekEnd.toLocal()}');
    
    try {
      setState(() {
        isLoading=true;
      });
      final querySnapshot=await FirebaseFirestore.instance
        .collection('userMetaLogs')
        .where('userId',isEqualTo: AuthService.currentUser?.uid)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(currentWeekStart))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(weekEnd))
        .orderBy('createdAt')
        .get();

      setState(() {
        currentWeekData = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return WeightData(
            date: (data['createdAt'] as Timestamp).toDate(),
            weight: data['weight']?.toDouble() ?? 0.0,
          );
        }).toList();
      });
    } catch (e) {
      if(context.mounted){
        showCustomSnackBar(
          context: context,
          message: 'Error loading weight data: $e',
          type: 'error',
        );
      }
    }
    finally{
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }

  }

  void _goToPreviousWeek() {
    setState(() {
      currentWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    });
    _loadWeekData();
  }

  void _goToNextWeek() {
    setState(() {
      currentWeekStart = currentWeekStart.add(const Duration(days: 7));
    });
    _loadWeekData();
  }

  void _selectDate() async {
    final selectedDate = await showDatePicker(
      barrierDismissible: true,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Theme.of(context).primaryColor,
            colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor),
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
      _loadWeekData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weight Tracking')),
      body: LayoutBuilder(
        builder: (context,constraints){
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                WeightChart(
                  weightData: currentWeekData,
                  currentWeekStart: currentWeekStart,
                  onPreviousWeek: _goToPreviousWeek,
                  onNextWeek: _goToNextWeek,
                  onSelectDate: _selectDate,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: (){
                    setState(() {
                      suggestion = 'Based on your weight data for this week, you are making steady progress towards your goals. Maintaining consistency is key to achieving long-term results, so continue tracking your weight regularly and celebrating small milestones along the way. Remember, fluctuations in weight are normal and can be influenced by factors such as hydration, sleep, and stress levels. To maximize your progress, aim for a balanced diet rich in whole foods, lean proteins, healthy fats, and plenty of fruits and vegetables. Incorporate both strength training and cardiovascular exercises into your routine, and ensure you are getting adequate rest and recovery. If you notice any plateaus or unexpected changes, consider reviewing your habits or consulting with a nutritionist or fitness professional for personalized guidance. Stay motivated, set realistic goals, and don\'t hesitate to seek support from friends, family, or online communities. Your commitment to tracking and improving your health is commendable—keep up the great work and continue striving for a healthier, happier you!';
                    });
                  },
                  child: const Text('Get AI insights',style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w500),),
                ),
                const SizedBox(height: 16),
                if (suggestion.isNotEmpty)
                  SizedBox(
                    height: constraints.maxHeight*0.4,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 20),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              suggestion,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ));
  }
}