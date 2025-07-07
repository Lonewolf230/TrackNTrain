import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:trackntrain/components/appbar_text_field.dart';
import 'package:trackntrain/components/end_workout.dart';
import 'package:trackntrain/components/stop_without_finishing.dart';
import 'package:trackntrain/utils/auth_service.dart';
import 'package:trackntrain/utils/classes.dart';
import 'package:trackntrain/utils/connectivity.dart';
import 'package:trackntrain/utils/db_util_funcs.dart';
import 'package:trackntrain/utils/misc.dart';

class HiitWorkout extends StatefulWidget {
  const HiitWorkout({
    super.key,
    required this.exercises,
    required this.rounds,
    required this.restDuration,
    required this.workDuration,
    required this.mode,
    this.workoutId,
    this.name,
  });
  final List<String> exercises;
  final int rounds;
  final int restDuration;
  final int workDuration;
  final String mode;
  final String? workoutId;
  final String? name;

  @override
  State<HiitWorkout> createState() => _HiitWorkoutState();
}

class _HiitWorkoutState extends State<HiitWorkout>
    with SingleTickerProviderStateMixin {
  static const int _getReadyDuration = 5;

  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController _workoutController = TextEditingController();

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

  bool _isConnected = true;
  late ConnectivityService connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _currentExercise = widget.exercises[0];
    connectivityService = ConnectivityService();
    _listenToConnectivity();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  void _listenToConnectivity() {
    _connectivitySubscription = connectivityService.connectivityStream.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
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
          if (_remainingTime <= 2) AudioManager.playBeep();
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
          if (_remainingTime <= 2) AudioManager.playBeep();
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
        return;
      }

      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          _animateProgress();
          if (_remainingTime <= 2) AudioManager.playBeep();
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
    WorkoutCompletionDialog.show(
      context,
      summaryItems: [
        WorkoutSummaryItem(value: '${widget.rounds}', label: 'Rounds'),
        WorkoutSummaryItem(
          value: '${widget.exercises.length}',
          label: 'Exercises',
        ),
      ],
      onDone: () {
        if (widget.mode == 'new') {
          HIITWorkout hiitWorkout = HIITWorkout(
            exercises: widget.exercises,
            rounds: widget.rounds,
            restDuration: widget.restDuration,
            workDuration: widget.workDuration,
            name:
                _workoutController.text.isNotEmpty
                    ? _workoutController.text
                    : 'My HIIT Workout',
            userId: AuthService.currentUser!.uid,
          );
          saveHiit(hiitWorkout, context);
        } else if (widget.mode == 'reuse' && widget.workoutId != null) {
          changeUpdatedAt(widget.workoutId!, 'userHiitWorkouts');
        }
        updateWorkoutStatus();
        context.goNamed('home');
      },
      onRestart: () {
        Navigator.of(context).pop();
        _resetWorkout();
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
        title:
            (widget.mode == 'reuse' && widget.name != null)
                ? Text(widget.name!, style: TextStyle(color: Colors.white))
                : AppbarTextField(controller: _workoutController),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 247, 2, 2),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color.fromARGB(255, 247, 2, 2),
                        const Color.fromARGB(255, 220, 20, 20),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          247,
                          2,
                          2,
                        ).withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Workout Timer',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Round $_currentRound/${widget.rounds}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Exercise ${_currentExerciseIndex + 1}/${widget.exercises.length}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getPhaseText(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _getProgressColor(),
                                backgroundColor: Colors.white,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ConnectivityStatusWidget(isConnected: _isConnected),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.grey[50]!, Colors.white],
                          ),
                          borderRadius: BorderRadius.circular(16),
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
                            Text(
                              'Current Exercise',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentExercise,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _getProgressColor().withOpacity(0.2),
                                  spreadRadius: 0,
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CircularProgressIndicator(
                              value: _animation.value,
                              strokeWidth: 16,
                              backgroundColor: Colors.grey[100],
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
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: _getProgressColor(),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_isRunning ||
                                  _timer != null && _timer!.isActive)
                                Container(
                                  decoration: BoxDecoration(
                                    color: _getProgressColor().withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      _isRunning
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      size: 32,
                                      color: _getProgressColor(),
                                    ),
                                    onPressed: _toggleTimer,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          _currentRound == 0 && !_isRunning
                              ? [
                                const Color.fromARGB(255, 247, 2, 2),
                                const Color.fromARGB(255, 220, 20, 20),
                              ]
                              : [Colors.grey[600]!, Colors.grey[700]!],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (_currentRound == 0 && !_isRunning
                                ? const Color.fromARGB(255, 247, 2, 2)
                                : Colors.grey[600]!)
                            .withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (_currentRound == 0 && !_isRunning) {
                          _startWorkout();
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => StopWithoutFinishing(),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _currentRound == 0 && !_isRunning
                                  ? Icons.play_arrow_rounded
                                  : Icons.stop_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _currentRound == 0 && !_isRunning
                                  ? 'START WORKOUT'
                                  : 'STOP WORKOUT',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
