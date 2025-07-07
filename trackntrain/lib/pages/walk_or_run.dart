import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'package:trackntrain/components/end_workout.dart';
import 'package:trackntrain/main.dart';
import 'package:trackntrain/utils/auth_service.dart';
import 'package:trackntrain/utils/classes.dart';
import 'package:trackntrain/utils/connectivity.dart';
import 'package:trackntrain/utils/db_util_funcs.dart';

class WalkProgress extends StatefulWidget {
  const WalkProgress({super.key});

  @override
  State<WalkProgress> createState() => _WalkProgressState();
}

class _WalkProgressState extends State<WalkProgress> {
  final MapController _mapController = MapController();

  Timer? _timer;
  Timer? _locationTimer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;

  bool _isConnected=true;
  late ConnectivityService connectivityService;
  StreamSubscription<bool>? _connectivitySubscription;

  final List<LatLng> _routePoints = [];
  LatLng? _currentLocation;
  bool _locationPermissionGranted = false;

  StreamSubscription<Position>? _positionStreamSubscription;
  String _locationSource = 'Unknown';
  double _locationAccuracy = 0.0;
  double _locationSpeed = 0.0;
  DateTime? _lastLocationUpdate;

  bool _isWalkFinished = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    connectivityService = ConnectivityService();
    _listenToConnectivity(); 
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
    _locationTimer?.cancel();
    _positionStreamSubscription?.cancel();
    _speedDecayTimer?.cancel();
    super.dispose();
  }

  LocationSettings get _locationSettings {
    if (Theme.of(context).platform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2,
        forceLocationManager: false,
        intervalDuration: const Duration(seconds: 1),
      );
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.fitness,
        distanceFilter: 2,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      return const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2,
      );
    }
  }

  double _currentSpeed = 0.0;
  double _averageSpeed = 0.0;

  LatLng? _previousLocation;
  DateTime? _previousLocationTime;
  final List<double> _recentSpeeds = [];
  static const int _speedHistorySize = 5;
  Timer? _speedDecayTimer;

  //To measure values accurately (from AI)
  static const double _maxAcceptableAccuracy = 15.0; // meters
  static const double _minDistanceThreshold = 1.0; // meters
  static const double _maxReasonableSpeed =
      15.0; // m/s (54 km/h - max reasonable for running/cycling)
  static const int _minTimeBetweenUpdates = 800; // milliseconds

  void _startLocationStream() {
    if (!_locationPermissionGranted) return;

    _positionStreamSubscription?.cancel();
    _speedDecayTimer?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).listen(
      (Position position) {

        // Filter out inaccurate GPS readings
        if (position.accuracy > _maxAcceptableAccuracy) {
          return;
        }

        LatLng newLocation = LatLng(position.latitude, position.longitude);
        DateTime currentTime = DateTime.now();

        double calculatedSpeed = 0.0;
        bool shouldUpdateSpeed = false;

        if (_previousLocation != null && _previousLocationTime != null) {
          int timeDiffMs =
              currentTime.difference(_previousLocationTime!).inMilliseconds;

          //Debouncing so that updates happen only if a minimum time has passed
          if (timeDiffMs < _minTimeBetweenUpdates) {
            return;
          }

          double distance = Geolocator.distanceBetween(
            _previousLocation!.latitude,
            _previousLocation!.longitude,
            newLocation.latitude,
            newLocation.longitude,
          );


          // Only calc speed if a min dist in passed
          if (distance >= _minDistanceThreshold && timeDiffMs > 0) {
            calculatedSpeed = distance / (timeDiffMs / 1000.0);

            if (calculatedSpeed <= _maxReasonableSpeed) {
              shouldUpdateSpeed = true;

            } else {
              //Avoiding GPS spikes
              return;
            }
          } else if (distance < _minDistanceThreshold) {
            //Avoid updates if distance is too small
            calculatedSpeed = 0.0;
            shouldUpdateSpeed = true;
          }
        } else {
          // First location update
          shouldUpdateSpeed = true;
          calculatedSpeed = 0.0;
        }

        if (!shouldUpdateSpeed) {
          return;
        }

        // Update speed history for smoothing
        _recentSpeeds.add(calculatedSpeed);
        if (_recentSpeeds.length > _speedHistorySize) {
          _recentSpeeds.removeAt(0);
        }

        // Trying to smooth the speed to avoid abrupt changes
        double smoothedSpeed = 0.0;
        if (_recentSpeeds.isNotEmpty) {
          // Remove outliers and calculate average
          List<double> sortedSpeeds = List.from(_recentSpeeds)..sort();

          if (sortedSpeeds.length >= 3) {
            sortedSpeeds.removeAt(0); // Remove lowest
            sortedSpeeds.removeAt(sortedSpeeds.length - 1); // Remove highest
          }

          if (sortedSpeeds.isNotEmpty) {
            smoothedSpeed =
                sortedSpeeds.reduce((a, b) => a + b) / sortedSpeeds.length;
          }
        }

        _previousLocation = newLocation;
        _previousLocationTime = currentTime;

        setState(() {
          _currentLocation = newLocation;
          _locationAccuracy = position.accuracy;
          _lastLocationUpdate = DateTime.now();
          _locationSource = position.isMocked ? 'Mock/Emulator' : 'Real GPS';
          _locationSpeed = smoothedSpeed;
          _currentSpeed = smoothedSpeed;

          if (_isRunning && !_isPaused) {
            if (_routePoints.isEmpty ||
                Geolocator.distanceBetween(
                      _routePoints.last.latitude,
                      _routePoints.last.longitude,
                      newLocation.latitude,
                      newLocation.longitude,
                    ) >=
                    _minDistanceThreshold) {
              _routePoints.add(newLocation);
              _updateAverageSpeed();

            }
          }
        });

        _resetSpeedDecayTimer();

        _mapController.move(newLocation, _mapController.camera.zoom);
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text('Location tracking error: $error'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _startLocationStream,
            ),
          ),
        );
      },
    );
  }

  void _resetSpeedDecayTimer() {
    _speedDecayTimer?.cancel();
    _speedDecayTimer = Timer(const Duration(seconds: 3), () {
      // Gradually decay speed to zero if no updates
      Timer.periodic(const Duration(milliseconds: 300), (timer) {
        if (_currentSpeed > 0.1) {
          setState(() {
            _currentSpeed *= 0.7;
            _locationSpeed = _currentSpeed;
          });
        } else {
          setState(() {
            _currentSpeed = 0.0;
            _locationSpeed = 0.0;
          });
          timer.cancel();
        }
      });
    });
  }

  void _updateAverageSpeed() {
    if (_elapsedSeconds > 0 && _routePoints.length > 1) {
      double totalDistance = _calculateTotalDistance();
      _averageSpeed = (totalDistance * 1000) / _elapsedSeconds;
    } else {
      _averageSpeed = 0.0;
    }
  }

  void _startTimer() {
    if (_isPaused) {
      setState(() {
        _isPaused = false;
        _isRunning = true;
      });
    } else if (_isWalkFinished) {
      setState(() {
        _elapsedSeconds = 0;
        _routePoints.clear();
        _isRunning = true;
        _isWalkFinished = false;
        _currentSpeed = 0.0;
        _averageSpeed = 0.0;
        _recentSpeeds.clear();
        _previousLocation = null;
        _previousLocationTime = null;
      });
      _getCurrentLocation();
    } else {
      setState(() {
        _isWalkFinished = false;
        _elapsedSeconds = 0;
        _routePoints.clear();
        _isRunning = true;
        _currentSpeed = 0.0;
        _averageSpeed = 0.0;
        _recentSpeeds.clear();
        _previousLocation = _currentLocation;
        _previousLocationTime = null;
      });
      _getCurrentLocation();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
      _updateAverageSpeed();
    });
    _startLocationStream();
  }

  void _pauseTimer() {
    _timer?.cancel();
    _positionStreamSubscription?.cancel();
    _speedDecayTimer?.cancel();
    setState(() {
      _isPaused = true;
      _isWalkFinished = false;
    });
  }

  void _stopTimer() {
    bool wasRunning = _isRunning && !_isPaused;
    _timer?.cancel();
    _positionStreamSubscription?.cancel();
    _speedDecayTimer?.cancel();
    setState(() {
      _isPaused = false;
    });

    double distance = _calculateTotalDistance();
    String formattedTime = _formatTime(_elapsedSeconds);
    WorkoutCompletionDialog.show(
      context,
      summaryItems: [
        WorkoutSummaryItem(value: formattedTime, label: 'Time'),
        WorkoutSummaryItem(
          value: '${distance.toStringAsFixed(2)} km',
          label: 'Distance',
        ),
        WorkoutSummaryItem(
          value:
              '${distance > 0 ? ((_averageSpeed * 3.6).toStringAsFixed(1)) : "0"} km/h',
          label: 'Average Speed',
        ),
        WorkoutSummaryItem(
          value: '${_routePoints.length}',
          label: 'Route Points',
        ),
      ],
      showRestartButton: false,
      onDone: () {
        WalkData walkData = WalkData(
          userId: AuthService.currentUser!.uid,
          distance: _calculateTotalDistance(),
          elapsedTime: _elapsedSeconds,
          averageSpeed: _averageSpeed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        if(distance>0.2 && _elapsedSeconds>60){
          createWalk(context, walkData);
          updateWorkoutStatus();
        }
        setState(() {
          _isRunning = false;
          _isPaused = false;
          _currentSpeed = 0.0;
          _locationSpeed = 0.0;
        });
        context.goNamed('home');
      },
      onClose: () {
        if (wasRunning) {
          setState(() {
            _isPaused = false;
            _isRunning = true;
          });
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            setState(() {
              _elapsedSeconds++;
            });
            _updateAverageSpeed();
          });
          _startLocationStream();
        }
      },
    );
  }

  Future<void> _requestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: const Text(
              'Location services are disabled. Please enable them in settings.',
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Open Settings',
              onPressed: () => Geolocator.openLocationSettings(),
            ),
          ),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          showGlobalSnackBar(message: 'Location permissions are denied. Please enable them in app settings.', type: 'error');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Location permissions are permanently denied. Please enable them in app settings.',
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'App Settings',
              onPressed: () => Geolocator.openAppSettings(),
            ),
          ),
        );
        return;
      }

      setState(() {
        _locationPermissionGranted = true;
      });


      await _getCurrentLocation();
      _startLocationStream();
    } catch (e) {
      showGlobalSnackBar(message: 'Error requesting location permission: $e', type: 'error');
    }
  }

  // Get current location with enhanced error handling
  Future<void> _getCurrentLocation() async {
    if (!_locationPermissionGranted) {
      return;
    }

    try {

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );

      LatLng newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = newLocation;
        _locationAccuracy = position.accuracy;
        _lastLocationUpdate = DateTime.now();
        _locationSource = position.isMocked ? 'Mock/Emulator' : 'Real GPS';
        _locationSpeed = 0.0;

        if (_isRunning && !_isPaused) {
          _routePoints.add(newLocation);
        }
      });

      _mapController.move(newLocation, 18.0);
    } catch (e) {

      String errorMessage = 'Failed to get location: ';
      if (e.toString().contains('PERMISSION_DENIED')) {
        errorMessage += 'Permission denied';
      } else if (e.toString().contains('POSITION_UNAVAILABLE')) {
        errorMessage +=
            'Position unavailable. Try moving to an open area or check if you\'re using a real device.';
      } else if (e.toString().contains('TIMEOUT')) {
        errorMessage += 'Location timeout. Check your GPS signal.';
      } else {
        errorMessage += e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _getCurrentLocation,
          ),
        ),
      );
    }
  }

  double _calculateTotalDistance() {
    if (_routePoints.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < _routePoints.length - 1; i++) {
      double segmentDistance = Geolocator.distanceBetween(
        _routePoints[i].latitude,
        _routePoints[i].longitude,
        _routePoints[i + 1].latitude,
        _routePoints[i + 1].longitude,
      );

      if (segmentDistance <= 100) {
        totalDistance += segmentDistance;
      } else {
        print(
          'Skipping unrealistic segment: ${segmentDistance.toStringAsFixed(2)}m',
        );
      }
    }
    return totalDistance / 1000;
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Walk/Run Progress',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 247, 2, 2),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 247, 2, 2),
                Color.fromARGB(255, 220, 0, 0),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Map Container - Expanded to fill more space
            Flexible(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter:
                              _currentLocation ??
                              const LatLng(13.0827, 80.2707),
                          initialZoom: 18.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.trackntrain',
                          ),
                          const RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution(
                                'OpenStreetMap contributors',
                              ),
                            ],
                          ),
                          if (_currentLocation != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _currentLocation!,
                                  width: 30,
                                  height: 30,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          _locationSource.contains('Mock')
                                              ? Colors.orange
                                              : Colors.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.my_location,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (_routePoints.isNotEmpty)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: _routePoints,
                                  color: const Color.fromARGB(255, 247, 2, 2),
                                  strokeWidth: 5,
                                ),
                              ],
                            ),
                          if (_routePoints.isNotEmpty)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _routePoints.first,
                                  width: 25,
                                  height: 25,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _currentLocation != null
                                    ? (_locationSource.contains('Mock')
                                        ? Colors.orange
                                        : Colors.green)
                                    : Colors.red,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _currentLocation != null
                                    ? Icons.gps_fixed
                                    : Icons.gps_not_fixed,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _currentLocation != null
                                    ? (_locationSource.contains('Mock')
                                        ? 'MOCK GPS'
                                        : 'REAL GPS')
                                    : 'NO GPS',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ConnectivityStatusWidget(
                            isConnected: _isConnected,
                        ),
                      )),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {
                                await _getCurrentLocation();
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.my_location,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFF8F9FA)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color.fromARGB(
                              255,
                              247,
                              2,
                              2,
                            ).withOpacity(0.1),
                            const Color.fromARGB(
                              255,
                              247,
                              2,
                              2,
                            ).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color.fromARGB(
                            255,
                            247,
                            2,
                            2,
                          ).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _formatTime(_elapsedSeconds),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 247, 2, 2),
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            'ELAPSED TIME',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '${_calculateTotalDistance().toStringAsFixed(2)}',
                            'km',
                            'Distance',
                            Icons.route_rounded,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _buildCurrentSpeedStatCard()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildAverageSpeedStatCard()),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!_isRunning || _isPaused)
                    Expanded(
                      child: _buildControlButton(
                        onPressed:
                            _locationPermissionGranted ? _startTimer : null,
                        icon: Icons.play_arrow_rounded,
                        label:
                            (_elapsedSeconds > 0 || _isPaused)
                                ? 'Resume'
                                : 'Start',
                        color: Colors.green,
                        isEnabled: _locationPermissionGranted,
                      ),
                    ),

                  if (_isRunning && !_isPaused)
                    Expanded(
                      child: _buildControlButton(
                        onPressed: _pauseTimer,
                        icon: Icons.pause,
                        label: 'Pause',
                        color: Colors.orange,
                      ),
                    ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _buildControlButton(
                      onPressed: _stopTimer,
                      icon: Icons.stop_circle_outlined,
                      label: 'Stop',
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
    bool isEnabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            isEnabled
                ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.8)],
                )
                : null,
        color: isEnabled ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isEnabled ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isEnabled ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSpeedStatCard() {
    return _buildStatCard(
      '${(_currentSpeed * 3.6).toStringAsFixed(1)}', // Convert m/s to km/h
      'km/h',
      'Current Speed',
      Icons.speed_rounded,
      Colors.orange,
    );
  }

  Widget _buildAverageSpeedStatCard() {
    return _buildStatCard(
      '${(_averageSpeed * 3.6).toStringAsFixed(1)}', // Convert m/s to km/h
      'km/h',
      'Avg Speed',
      Icons.trending_up_rounded,
      Colors.purple,
    );
  }

  Widget _buildStatCard(
    String value,
    String unit,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
