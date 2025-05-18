import 'package:flutter/material.dart';
import 'dart:async';

import 'package:go_router/go_router.dart';

class HiitWorkout extends StatefulWidget {
  const HiitWorkout({
    super.key,
    required this.exercises,
    required this.rounds,
    required this.restDuration,
    required this.workDuration,
  });
  final List<String> exercises;
  final int rounds;
  final int restDuration;
  final int workDuration;

  @override
  State<HiitWorkout> createState() => _HiitWorkoutState();
}

class _HiitWorkoutState extends State<HiitWorkout>
    with SingleTickerProviderStateMixin {
  static const int _getReadyDuration = 5;
  // static const int _workDuration = 30;
  // static const int _restDuration = 10;
  // static const int _totalRounds = 1;

  late AnimationController _controller;
  late Animation<double> _animation;

  // Timer state
  int _currentRound = 0;
  int _currentExerciseIndex = 0;
  int _remainingTime = _getReadyDuration;
  bool _isRunning = false;
  bool _isWorkPhase = false;
  bool _isRestPhase = false;
  bool _isCompleted = false;
  Timer? _timer;

  String _currentExercise = '';

  @override
  void initState() {
    super.initState();
    _currentExercise = widget.exercises[0];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startGetReadyPhase() {
    setState(() {
      _isRunning = true;
      _isWorkPhase = false;
      _isRestPhase = false;
      _remainingTime = _getReadyDuration;

      _currentExercise = widget.exercises[_currentExerciseIndex];
    });
    _animateProgress();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        return;
      }

      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          _animateProgress();
        } else {
          timer.cancel();
          _startWorkPhase();
        }
      });
    });
  }

  void _startWorkPhase() {
    setState(() {
      _isRunning = true;
      _isWorkPhase = true;
      _isRestPhase = false;
      _remainingTime = widget.workDuration;
    });
    _animateProgress();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        return;
      }

      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          _animateProgress();
        } else {
          timer.cancel();

          _currentExerciseIndex++;

          if (_currentExerciseIndex >= widget.exercises.length) {
            _currentExerciseIndex = 0;
            _currentRound++;

            if (_currentRound >= widget.rounds) {
              _completeWorkout();
              return;
            }
          }
          _startRestPhase();
        }
      });
    });
  }

  void _startRestPhase() {
    setState(() {
      _isRunning = true;
      _isWorkPhase = false;
      _isRestPhase = true;
      _remainingTime = widget.restDuration;
    });
    _animateProgress();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        // Pause logic
        return;
      }

      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          _animateProgress();
        } else {
          timer.cancel();
          _startGetReadyPhase();
        }
      });
    });
  }

  void _completeWorkout() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isWorkPhase = false;
      _isRestPhase = false;
      _isCompleted = true;
    });

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Workout Complete!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Congratulations! You have completed all rounds.'),
              const SizedBox(height: 20),
              Image.asset(
                'assets/trophy.png', // Make sure to add this asset to your pubspec.yaml
                height: 100,
                width: 100,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.emoji_events,
                    size: 80,
                    color: Colors.amber,
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                'You completed ${widget.rounds} rounds of ${widget.exercises.length} exercises!',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetWorkout();
              },
              child: Text(
                'RESTART',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                context.goNamed('home');
              },
              child: Text(
                'DONE',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _resetWorkout() {
    setState(() {
      _currentRound = 0;
      _currentExerciseIndex = 0;
      _remainingTime = _getReadyDuration;
      _isRunning = false;
      _isWorkPhase = false;
      _isRestPhase = false;
      _isCompleted = false;
      _currentExercise = widget.exercises[0];
    });
  }

  void _animateProgress() {
    double targetValue;
    int totalDuration;

    if (_isWorkPhase) {
      totalDuration = widget.workDuration;
    } else if (_isRestPhase) {
      totalDuration = widget.restDuration;
    } else {
      totalDuration = _getReadyDuration;
    }

    targetValue = 1 - (_remainingTime / totalDuration);

    _controller.animateTo(
      targetValue,
      duration: const Duration(milliseconds: 950),
      curve: Curves.easeOut,
    );
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      if (_timer == null || !_timer!.isActive) {
        if (_isWorkPhase) {
          _startWorkPhase();
        } else if (_isRestPhase) {
          _startRestPhase();
        } else {
          _startGetReadyPhase();
        }
      }
    }
  }

  void _startWorkout() {
    setState(() {
      _currentRound = 1;
    });
    _startGetReadyPhase();
  }

  Color _getProgressColor() {
    if (_isWorkPhase) return Colors.red;
    if (_isRestPhase) return Colors.green;
    return Colors.blue;
  }

  String _getPhaseText() {
    if (_isWorkPhase) return 'WORK';
    if (_isRestPhase) return 'REST';
    return 'GET READY';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workout Timer',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Round $_currentRound/${widget.rounds}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Exercise ${_currentExerciseIndex + 1}/${widget.exercises.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _getPhaseText(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(),
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: CircularProgressIndicator(
                      value: _animation.value,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_remainingTime',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_isRunning || _timer != null && _timer!.isActive)
                        IconButton(
                          icon: Icon(
                            _isRunning ? Icons.pause : Icons.play_arrow,
                            size: 40,
                          ),
                          onPressed: _toggleTimer,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                _currentExercise,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_currentRound == 0 && !_isRunning) {
                        _startWorkout();
                      } else {
                        _stopWorkoutWithConfirmation(context);
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentRound == 0 && !_isRunning
                          ? 'START WORKOUT'
                          : 'STOP WORKOUT',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _stopWorkoutWithConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Stop Workout?'),
          content: const Text(
            'Are you sure you want to stop your current workout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'CANCEL',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                context.goNamed('home');
              },
              child: Text(
                'STOP',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
