import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trackntrain/utils/auth_service.dart';
import 'package:trackntrain/utils/misc.dart';

class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key});

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  late DateTime currentMonth;
  late List<DateTime> datesGrid;
  List<String> activeDates = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
    datesGrid = _generateDatesGrid(currentMonth);
    _loadData();
  }

  void _loadData() async {
    try {
      setState(() {
        isLoading = true;
      });
      print('Checking sharedPrefs for active dates...');
      activeDates=await getActiveDates();
      if (activeDates.isEmpty) {
        print('No active dates found in sharedPrefs, fetching from Firestore...');
        final querySnapShot =
            await FirebaseFirestore.instance
                .collection('userMetaLogs')
                .where('userId', isEqualTo: AuthService.currentUser?.uid)
                .where(
                  'createdAt',
                  isGreaterThanOrEqualTo: DateTime(
                    currentMonth.year,
                    currentMonth.month,
                    1,
                  ),
                )
                .where(
                  'createdAt',
                  isLessThanOrEqualTo: DateTime(
                    currentMonth.year,
                    currentMonth.month,
                    DateTime.now().day + 1,
                  ),
                )
                .orderBy('createdAt')
                .get();

        print('Query Snapshot: ${querySnapShot.docs.length} documents found');

        activeDates =
            querySnapShot.docs
                .where((doc) => (doc.data()['hasWorkedOut'] ?? false) == true)
                .map(
                  (doc) =>
                      (doc.data()['createdAt'] as Timestamp)
                          .toDate()
                          .day
                          .toString(),
                )
                .toList();
        }

        await setActiveDates(activeDates);


      print('Active Dates : $activeDates');

    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<DateTime> _generateDatesGrid(DateTime month) {
    int numDays = DateTime(month.year, month.month + 1, 0).day;
    int firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    List<DateTime> dates = [];

    DateTime previousMonth = DateTime(month.year, month.month - 1);
    int previousMonthLastDay =
        DateTime(previousMonth.year, previousMonth.month + 1, 0).day;
    for (int i = firstWeekday; i > 0; i--) {
      dates.add(
        DateTime(
          previousMonth.year,
          previousMonth.month,
          previousMonthLastDay - i + 1,
        ),
      );
    }

    for (int day = 1; day <= numDays; day++) {
      dates.add(DateTime(month.year, month.month, day));
    }

    int remainingBoxes = 42 - dates.length;
    for (int day = 1; day <= remainingBoxes; day++) {
      dates.add(DateTime(month.year, month.month + 1, day));
    }

    return dates;
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_monthName(currentMonth.month)} ${currentMonth.year}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              7,
              (index) => Text(
                ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][index],
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: Colors.blueGrey,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemCount: datesGrid.length,
            itemBuilder: (context, index) {
              DateTime date = datesGrid[index];
              bool isCurrentMonth = date.month == currentMonth.month;
              bool isToday =
                  date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;
              bool isActive = activeDates.contains(date.day.toString());
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: CircleAvatar(
                  backgroundColor:
                      isActive && isToday
                          ? Colors.orange
                          : isActive
                          ? Theme.of(context).primaryColor
                          : isToday
                          ? Colors.blue
                          : Colors.transparent,
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color:
                          isCurrentMonth
                              ? (isActive || isToday
                                  ? Colors.white
                                  : Colors.black)
                              : Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildLegendCircle(
              context,
              Theme.of(context).primaryColor,
              'Worked Out',
            ),
            const SizedBox(width: 16),
            _buildLegendCircle(context, Colors.blue, 'Today'),
            const SizedBox(width: 16),
            _buildLegendCircle(context, Colors.orange, 'Today & Worked Out'),
          ],
        ),
      ],
    );
  }

  String _monthName(int monthNumber) {
    return [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][monthNumber - 1];
  }

  Widget _buildLegendCircle(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 8, backgroundColor: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
