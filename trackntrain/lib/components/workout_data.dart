import 'package:flutter/material.dart';
void showWorkoutDialog(BuildContext context, Map<String, dynamic> workoutLog) {
  final sensitiveKeys = [
    'id',
    'createdAt',
    'updatedAt',
    'expireAt', 
    'userId',
    'user_id',
    'timestamp',
    'lastModified',
    'sessionId',
    'deviceId',
    'name',
    'routePoints'
  ];

  Map<String, dynamic> filteredData = Map.from(workoutLog);
  sensitiveKeys.forEach((key) => filteredData.remove(key));

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: Colors.red.withOpacity(0.8),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Workout Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.red.withOpacity(0.7),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildWorkoutContent(filteredData),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildWorkoutContent(Map<String, dynamic> data) {
  // Check if this is exercise data with sets, reps, weights
  if (_hasExerciseStructure(data)) {
    return _buildExerciseView(data);
  } else {
    return _buildGeneralDataView(data);
  }
}

bool _hasExerciseStructure(Map<String, dynamic> data) {
  // Check if data contains exercise-related keys
  final exerciseKeys = ['sets', 'reps', 'weights', 'exercises'];
  return exerciseKeys.any((key) => data.containsKey(key));
}

Widget _buildExerciseView(Map<String, dynamic> data) {
  List<Widget> widgets = [];

  // Handle exercises list
  if (data.containsKey('exercises') && data['exercises'] is List) {
    // widgets.add(_buildExercisesHeader());
    
    List exercises = data['exercises'];
    for (int i = 0; i < exercises.length; i++) {
      widgets.add(_buildExerciseCard(exercises[i], i + 1));
      widgets.add(const SizedBox(height: 12));
    }
  }

  // Handle individual exercise data
  else if (data.containsKey('sets') || data.containsKey('reps') || data.containsKey('weights')) {
    // widgets.add(_buildExercisesHeader());
    widgets.add(_buildExerciseCard(data, 1));
  }

  // Add other non-exercise data
  Map<String, dynamic> otherData = Map.from(data);
  otherData.remove('exercises');
  otherData.remove('sets');
  otherData.remove('reps');
  otherData.remove('weights');

  if (otherData.isNotEmpty) {
    widgets.add(const SizedBox(height: 20));
    widgets.add(_buildOtherDataSection(otherData));
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: widgets,
  );
}


Widget _buildExerciseCard(dynamic exerciseData, int index) {
  if (exerciseData is! Map<String, dynamic>) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              exerciseData.toString(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String exerciseName = exerciseData['exerciseName']?.toString() ?? 
                       exerciseData['name']?.toString() ?? 
                       'Exercise $index';
  
  List<dynamic>? reps = exerciseData['reps'] is List ? exerciseData['reps'] : null;
  List<dynamic>? weights = exerciseData['weightsList'] is List ? exerciseData['weightsList'] : null;
  int setCount = exerciseData['set']?.toInt() ?? 
                 (reps?.length ?? weights?.length ?? 0);

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.red.withOpacity(0.2),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                exerciseName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        
        if (setCount > 0 && (reps != null || weights != null)) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.red.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_list_numbered,
                      color: Colors.red.withOpacity(0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Set Details:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...List.generate(setCount, (setIndex) {
                  String repText = '';
                  String weightText = '';
                  
                  if (reps != null && setIndex < reps.length) {
                    repText = '${reps[setIndex]} reps';
                  }
                  
                  if (weights != null && setIndex < weights.length) {
                    weightText = '${weights[setIndex]} kg';
                  }
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${setIndex + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (repText.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            repText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                        if (repText.isNotEmpty && weightText.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            width: 1,
                            height: 16,
                            color: Colors.red.withOpacity(0.3),
                          ),
                        if (weightText.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            weightText,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

Widget _buildDetailChip(IconData icon, String label, String value) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.red.withOpacity(0.3),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.red.withOpacity(0.7),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}

Widget _buildGeneralDataView(Map<String, dynamic> data) {
  List<Widget> widgets = [];

  if (data.containsKey('exercises') && data['exercises'] is List) {
    widgets.add(_buildSimpleExercisesSection(data['exercises']));
    data = Map.from(data)..remove('exercises');
  }

  if (data.isNotEmpty) {
    widgets.add(_buildOtherDataSection(data));
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: widgets,
  );
}

Widget _buildSimpleExercisesSection(List exercises) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(
            Icons.fitness_center,
            color: Colors.red.withOpacity(0.8),
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            'Exercises:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ...exercises.asMap().entries.map((entry) {
        int index = entry.key;
        dynamic exercise = entry.value;
        String exerciseName = exercise.toString();
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.red.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.withOpacity(0.8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  exerciseName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      const SizedBox(height: 20),
    ],
  );
}

String secondsToHoursMinutesSeconds(int seconds, {bool showSeconds = true}) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int secs = seconds % 60;

  String result = '';
  if (hours > 0) {
    result += '$hours hr${hours > 1 ? 's' : ''} ';
  }
  if (minutes > 0) {
    result += '$minutes min${minutes > 1 ? 's' : ''} ';
  }
  if (showSeconds && secs > 0) {
    result += '$secs sec${secs > 1 ? 's' : ''}';
  }

  return result.trim();
}

Widget _buildOtherDataSection(Map<String, dynamic> data) {
  if (data.isEmpty) return const SizedBox.shrink();

  for (String key in data.keys) {
    if (key.toLowerCase().toString()=='restduration' || key.toLowerCase().toString()=='workduration') {
      data[key] = _formatValue('${data[key]} seconds');
    }

    if(key.toLowerCase().toString()=='averagespeed'){
        double? rawValue = double.tryParse(data[key].toString());
        if (rawValue != null) {
          String rounded = rawValue.toStringAsFixed(2); 
          data[key] = _formatValue('$rounded km/h');
        }
    }

    if(key.toLowerCase().toString()=='distance' || key.toLowerCase().toString()=='totaldistance'){
        double? rawValue = double.tryParse(data[key].toString());
        if (rawValue != null) {
          String rounded = rawValue.toStringAsFixed(2); 
          data[key] = _formatValue('$rounded km');
        }
    }

    if(key.toLowerCase().toString()=='elapsedtime' || key.toLowerCase().toString()=='totalduration'){
      data[key] = _formatValue(secondsToHoursMinutesSeconds(data[key], showSeconds: true));
    }


  }



  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 20),
      Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.red.withOpacity(0.8),
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            'Workout Information:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: data.entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatKey(entry.key),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.withOpacity(0.8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _formatValue(entry.value),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

String _formatKey(String key) {
  return key
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match.group(1)} ${match.group(2)}')
      .replaceAll('_', ' ')
      .split(' ')
      .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '')
      .join(' ');
}

String _formatValue(dynamic value) {
  if (value is List) {
    return value.join(', ');
  } else if (value is Map) {
    return value.toString();
  } else {
    return value.toString();
  }
}