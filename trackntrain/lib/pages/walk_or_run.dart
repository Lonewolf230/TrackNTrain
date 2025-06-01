// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:async';

// import 'package:trackntrain/components/end_workout.dart';

// class WalkProgress extends StatefulWidget {
//   const WalkProgress({super.key});

//   @override
//   State<WalkProgress> createState() => _WalkProgressState();
// }

// class _WalkProgressState extends State<WalkProgress> {
//   final MapController _mapController = MapController();
  
//   // Timer and tracking state
//   Timer? _timer;
//   Timer? _locationTimer;
//   int _elapsedSeconds = 0;
//   bool _isRunning = false;
//   bool _isPaused = false;
  
//   // Location tracking
//   final List<LatLng> _routePoints = [];
//   LatLng? _currentLocation;
//   bool _locationPermissionGranted = false;
  
//   // Enhanced location tracking
//   StreamSubscription<Position>? _positionStreamSubscription;
//   String _locationSource = 'Unknown';
//   double _locationAccuracy = 0.0;
//   DateTime? _lastLocationUpdate;

//   @override
//   void initState() {
//     super.initState();
//     _requestLocationPermission();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _locationTimer?.cancel();
//     _positionStreamSubscription?.cancel();
//     super.dispose();
//   }

//   // Enhanced location settings for real device
//   LocationSettings get _locationSettings {
//     if (Theme.of(context).platform == TargetPlatform.android) {
//       return AndroidSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 5, // Update every 5 meters
//         forceLocationManager: false, // Use Google Play Services
//         intervalDuration: const Duration(seconds: 3),
//       );
//     } else if (Theme.of(context).platform == TargetPlatform.iOS) {
//       return AppleSettings(
//         accuracy: LocationAccuracy.high,
//         activityType: ActivityType.fitness,
//         distanceFilter: 5,
//         pauseLocationUpdatesAutomatically: false,
//         showBackgroundLocationIndicator: true,
//       );
//     } else {
//       return const LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 5,
//       );
//     }
//   }

//   // Start continuous location stream
//   void _startLocationStream() {
//     if (!_locationPermissionGranted) return;

//     _positionStreamSubscription?.cancel();
//     _positionStreamSubscription = Geolocator.getPositionStream(
//       locationSettings: _locationSettings,
//     ).listen(
//       (Position position) {
//         print('Stream location update: ${position.latitude}, ${position.longitude}');
//         print('Accuracy: ${position.accuracy}m, Provider: ${position.isMocked ? "Mock" : "Real"}');
        
//         LatLng newLocation = LatLng(position.latitude, position.longitude);
        
//         setState(() {
//           _currentLocation = newLocation;
//           _locationAccuracy = position.accuracy;
//           _lastLocationUpdate = DateTime.now();
//           _locationSource = position.isMocked ? 'Mock/Emulator' : 'Real GPS';
          
//           if (_isRunning && !_isPaused) {
//             // Only add point if we moved significantly (reduce noise)
//             if (_routePoints.isEmpty || 
//                 Geolocator.distanceBetween(
//                   _routePoints.last.latitude,
//                   _routePoints.last.longitude,
//                   newLocation.latitude,
//                   newLocation.longitude,
//                 ) > 3) { // 3 meters threshold
//               _routePoints.add(newLocation);
//               print('Added point to route. Total points: ${_routePoints.length}');
//             }
//           }
//         });

//         // Update map position smoothly
//         _mapController.move(newLocation, _mapController.camera.zoom);
//       },
//       onError: (error) {
//         print('Location stream error: $error');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Location tracking error: $error'),
//             action: SnackBarAction(
//               label: 'Retry',
//               onPressed: _startLocationStream,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Request location permission with enhanced checks
//   Future<void> _requestLocationPermission() async {
//     try {
//       // Check if location services are enabled
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Location services are disabled. Please enable them in settings.'),
//             duration: const Duration(seconds: 5),
//             action: SnackBarAction(
//               label: 'Open Settings',
//               onPressed: () => Geolocator.openLocationSettings(),
//             ),
//           ),
//         );
//         return;
//       }

//       // Check current permission status
//       LocationPermission permission = await Geolocator.checkPermission();
//       print('Current permission status: $permission');

//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         print('Permission after request: $permission');
        
//         if (permission == LocationPermission.denied) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Location permissions are denied. Cannot track location.'),
//               duration: Duration(seconds: 5),
//             ),
//           );
//           return;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Location permissions are permanently denied. Please enable them in app settings.'),
//             duration: const Duration(seconds: 5),
//             action: SnackBarAction(
//               label: 'App Settings',
//               onPressed: () => Geolocator.openAppSettings(),
//             ),
//           ),
//         );
//         return;
//       }

//       // Permission granted
//       setState(() {
//         _locationPermissionGranted = true;
//       });
      
//       print('Location permission granted, starting location tracking...');
      
//       // Get initial location and start stream
//       await _getCurrentLocation();
//       _startLocationStream();
      
//     } catch (e) {
//       print('Error in permission request: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error requesting location permission: $e')),
//       );
//     }
//   }

//   // Get current location with enhanced error handling
//   Future<void> _getCurrentLocation() async {
//     if (!_locationPermissionGranted) {
//       print('Location permission not granted');
//       return;
//     }

//     try {
//       print('Getting current location...');
      
//       Position position = await Geolocator.getCurrentPosition(
//         locationSettings: _locationSettings
//       );
      
//       print('Got location: ${position.latitude}, ${position.longitude}');
//       print('Accuracy: ${position.accuracy}m');
//       print('Provider: ${position.isMocked ? "Mock/Emulator" : "Real GPS"}');
//       print('Altitude: ${position.altitude}m');
//       print('Speed: ${position.speed}m/s');
      
//       LatLng newLocation = LatLng(position.latitude, position.longitude);
      
//       setState(() {
//         _currentLocation = newLocation;
//         _locationAccuracy = position.accuracy;
//         _lastLocationUpdate = DateTime.now();
//         _locationSource = position.isMocked ? 'Mock/Emulator' : 'Real GPS';
        
//         if (_isRunning && !_isPaused) {
//           _routePoints.add(newLocation);
//           print('Added point to route. Total points: ${_routePoints.length}');
//         }
//       });

//       // Move map to current location
//       _mapController.move(newLocation, 18.0);
      
//     } catch (e) {
//       print('Error getting location: $e');
      
//       String errorMessage = 'Failed to get location: ';
//       if (e.toString().contains('PERMISSION_DENIED')) {
//         errorMessage += 'Permission denied';
//       } else if (e.toString().contains('POSITION_UNAVAILABLE')) {
//         errorMessage += 'Position unavailable. Try moving to an open area or check if you\'re using a real device.';
//       } else if (e.toString().contains('TIMEOUT')) {
//         errorMessage += 'Location timeout. Check your GPS signal.';
//       } else {
//         errorMessage += e.toString();
//       }
      
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(errorMessage),
//           duration: const Duration(seconds: 5),
//           action: SnackBarAction(
//             label: 'Retry',
//             onPressed: _getCurrentLocation,
//           ),
//         ),
//       );
//     }
//   }

//   // Start the timer and location tracking
//   void _startTimer() {
//     if (_isPaused) {
//       // Resume from pause
//       setState(() {
//         _isPaused = false;
//       });
//     } else {
//       // Fresh start
//       setState(() {
//         _elapsedSeconds = 0;
//         _routePoints.clear();
//         _isRunning = true;
//       });
      
//       // Get initial location for the route
//       _getCurrentLocation();
//     }

//     // Start the timer (1 second intervals)
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         _elapsedSeconds++;
//       });
//     });

//     // Start continuous location tracking
//     _startLocationStream();
//   }

//   // Pause the timer and location tracking
//   void _pauseTimer() {
//     _timer?.cancel();
//     _positionStreamSubscription?.cancel();
//     setState(() {
//       _isPaused = true;
//     });
//   }

//   // Stop/End the timer and location tracking
//   void _stopTimer() {
//     _timer?.cancel();
//     _positionStreamSubscription?.cancel();
//     setState(() {
//       _isRunning = false;
//       _isPaused = false;
//     });
//     double distance = _calculateTotalDistance();
//     String formattedTime = _formatTime(_elapsedSeconds);
//     // Show completion dialog
//     WorkoutCompletionDialog.show(
//       context,
//       summaryItems: [
//         WorkoutSummaryItem(value: formattedTime, label:'Time' ),
//         WorkoutSummaryItem(value: '${distance.toStringAsFixed(2)} km', label: 'Distance'),
//         WorkoutSummaryItem(value: '${distance > 0 ? ((distance / (_elapsedSeconds / 3600)).toStringAsFixed(1)) : "0"} km/h', label: 'Average Speed'),
//         WorkoutSummaryItem(value: '${_routePoints.length}', label: 'Route Points'),
//       ],
//       showRestartButton: false
//     );
//   }

//   // Calculate total distance of the route
//   double _calculateTotalDistance() {
//     if (_routePoints.length < 2) return 0.0;
    
//     double totalDistance = 0.0;
//     for (int i = 0; i < _routePoints.length - 1; i++) {
//       totalDistance += Geolocator.distanceBetween(
//         _routePoints[i].latitude,
//         _routePoints[i].longitude,
//         _routePoints[i + 1].latitude,
//         _routePoints[i + 1].longitude,
//       );
//     }
//     return totalDistance / 1000; // Convert to kilometers
//   }

//   // Format time as HH:MM:SS
//   String _formatTime(int seconds) {
//     int hours = seconds ~/ 3600;
//     int minutes = (seconds % 3600) ~/ 60;
//     int remainingSeconds = seconds % 60;
    
//     if (hours > 0) {
//       return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
//     }
//     return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Walk/Run Progress',
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//         backgroundColor: Theme.of(context).primaryColor,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Column(
//         children: [
//           // Map Container
//           Container(
//             margin: const EdgeInsets.all(20),
//             padding: const EdgeInsets.all(20),
//             constraints: const BoxConstraints.tightFor(width: 400, height: 300),
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
//                 width: 1,
//               ),
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   spreadRadius: 0,
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Colors.white, Colors.grey[50]!],
//               ),
//             ),
//             child: Stack(
//               children: [
//                 FlutterMap(
//                   mapController: _mapController,
//                   options: MapOptions(
//                     initialCenter: _currentLocation ?? const LatLng(13.0827, 80.2707), // Chennai coordinates as fallback
//                     initialZoom: 18.0,
//                   ),
//                   children: [
//                     TileLayer(
//                       urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                       userAgentPackageName: 'com.example.trackntrain',
//                     ),
//                     const RichAttributionWidget(
//                       attributions: [
//                         TextSourceAttribution('OpenStreetMap contributors'),
//                       ],
//                     ),
//                     // Current location marker
//                     if (_currentLocation != null)
//                       MarkerLayer(
//                         markers: [
//                           Marker(
//                             point: _currentLocation!,
//                             width: 25,
//                             height: 25,
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: _locationSource.contains('Mock') ? Colors.orange : Colors.blue,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: Colors.white, width: 2),
//                               ),
//                               child: Icon(
//                                 Icons.my_location, 
//                                 color: Colors.white, 
//                                 size: 15
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     // Route polyline
//                     if (_routePoints.isNotEmpty)
//                       PolylineLayer(
//                         polylines: [
//                           Polyline(
//                             points: _routePoints,
//                             color: Colors.red,
//                             strokeWidth: 4,
//                           ),
//                         ],
//                       ),
//                     // Route start marker
//                     if (_routePoints.isNotEmpty)
//                       MarkerLayer(
//                         markers: [
//                           Marker(
//                             point: _routePoints.first,
//                             width: 20,
//                             height: 20,
//                             child: const CircleAvatar(
//                               backgroundColor: Colors.red,
//                               child: Icon(Icons.person, color: Colors.white, size: 12),
//                             ),
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//                 // Location status indicator
//                 Positioned(
//                   top: 10,
//                   right: 10,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: _currentLocation != null 
//                         ? (_locationSource.contains('Mock') ? Colors.orange : Colors.green)
//                         : Colors.red,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           _currentLocation != null ? Icons.gps_fixed : Icons.gps_not_fixed,
//                           color: Colors.white,
//                           size: 12,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           _currentLocation != null 
//                             ? (_locationSource.contains('Mock') ? 'MOCK' : 'GPS')
//                             : 'NO GPS',
//                           style: const TextStyle(color: Colors.white, fontSize: 10),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Manual location button
//                 Positioned(
//                   bottom: 10,
//                   right: 10,
//                   child: FloatingActionButton(
//                     mini: true,
//                     onPressed: () async {
//                       await _getCurrentLocation();
//                     },
//                     backgroundColor: Colors.blue,
//                     child: const Icon(Icons.refresh, color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           const SizedBox(height: 10),
          
//           // Enhanced Debug Info
//           if (_currentLocation != null)
//             Container(
//               padding: const EdgeInsets.all(12),
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               decoration: BoxDecoration(
//                 color: _locationSource.contains('Mock') ? Colors.orange[50] : Colors.green[50],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: _locationSource.contains('Mock') ? Colors.orange : Colors.green,
//                   width: 1,
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         _locationSource.contains('Mock') ? Icons.warning : Icons.check_circle,
//                         size: 16,
//                         color: _locationSource.contains('Mock') ? Colors.orange : Colors.green,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Location Status: $_locationSource', 
//                         style: TextStyle(
//                           fontSize: 12, 
//                           fontWeight: FontWeight.bold,
//                           color: _locationSource.contains('Mock') ? Colors.orange[800] : Colors.green[800],
//                         )
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text('Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}', style: const TextStyle(fontSize: 10)),
//                   Text('Lng: ${_currentLocation!.longitude.toStringAsFixed(6)}', style: const TextStyle(fontSize: 10)),
//                   Text('Accuracy: ${_locationAccuracy.toStringAsFixed(1)}m', style: const TextStyle(fontSize: 10)),
//                   Text('Route Points: ${_routePoints.length}', style: const TextStyle(fontSize: 10)),
//                   if (_lastLocationUpdate != null)
//                     Text('Last Update: ${_lastLocationUpdate!.toString().split('.')[0]}', style: const TextStyle(fontSize: 10)),
//                   if (_locationSource.contains('Mock'))
//                     const Text(
//                       'Using emulator location. For real GPS, use a physical device.',
//                       style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
//                     ),
//                 ],
//               ),
//             ),
          
//           const SizedBox(height: 20),
          
//           // Timer Display
//           Container(
//             padding: const EdgeInsets.all(20),
//             margin: const EdgeInsets.symmetric(horizontal: 20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   spreadRadius: 0,
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Colors.white, Colors.grey[50]!],
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Column(
//                   children: [
//                     Text(
//                       _formatTime(_elapsedSeconds),
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const Text('Time', style: TextStyle(color: Colors.black54)),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     Text(
//                       '${_calculateTotalDistance().toStringAsFixed(2)} km',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const Text('Distance', style: TextStyle(color: Colors.black54)),
//                   ],
//                 ),
//                 if (_elapsedSeconds > 0)
//                   Column(
//                     children: [
//                       Text(
//                         '${(_calculateTotalDistance() / (_elapsedSeconds / 3600)).toStringAsFixed(1)}',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const Text('km/h', style: TextStyle(color: Colors.black54)),
//                     ],
//                   ),
//               ],
//             ),
//           ),
          
//           const SizedBox(height: 20),
          
//           // Control Buttons
//           Container(
//             padding: const EdgeInsets.all(20),
//             margin: const EdgeInsets.symmetric(horizontal: 20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   spreadRadius: 0,
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Colors.white, Colors.grey[50]!],
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 // Start/Resume Button
//                 if (!_isRunning || _isPaused)
//                   ElevatedButton.icon(
//                     onPressed: _locationPermissionGranted ? _startTimer : null,
//                     icon: Icon(_isPaused ? Icons.play_arrow : Icons.play_arrow),
//                     label: Text(_isPaused ? 'Resume' : 'Start'),
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color.fromARGB(255, 247, 2, 2),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                     ),
//                   ),
                
//                 // Pause Button
//                 if (_isRunning && !_isPaused)
//                   ElevatedButton.icon(
//                     onPressed: _pauseTimer,
//                     icon: const Icon(Icons.pause),
//                     label: const Text('Pause'),
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color.fromARGB(255, 247, 2, 2),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                     ),
//                   ),
                
//                 // Stop Button
//                 if (_isRunning)
//                   ElevatedButton.icon(
//                     onPressed: _stopTimer,
//                     icon: const Icon(Icons.stop),
//                     label: const Text('End'),
//                     style:    ElevatedButton.styleFrom(               
//                       backgroundColor: const Color.fromARGB(255, 247, 2, 2),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 20),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),)
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'package:trackntrain/components/end_workout.dart';

class WalkProgress extends StatefulWidget {
  const WalkProgress({super.key});

  @override
  State<WalkProgress> createState() => _WalkProgressState();
}

class _WalkProgressState extends State<WalkProgress> {
  final MapController _mapController = MapController();
  
  // Timer and tracking state
  Timer? _timer;
  Timer? _locationTimer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  
  // Location tracking
  final List<LatLng> _routePoints = [];
  LatLng? _currentLocation;
  bool _locationPermissionGranted = false;
  
  // Enhanced location tracking
  StreamSubscription<Position>? _positionStreamSubscription;
  String _locationSource = 'Unknown';
  double _locationAccuracy = 0.0;
  DateTime? _lastLocationUpdate;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _locationTimer?.cancel();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // Enhanced location settings for real device
  LocationSettings get _locationSettings {
    if (Theme.of(context).platform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
        forceLocationManager: false, // Use Google Play Services
        intervalDuration: const Duration(seconds: 3),
      );
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 5,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );
    }
  }

  // Start continuous location stream
  void _startLocationStream() {
    if (!_locationPermissionGranted) return;

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).listen(
      (Position position) {
        print('Stream location update: ${position.latitude}, ${position.longitude}');
        print('Accuracy: ${position.accuracy}m, Provider: ${position.isMocked ? "Mock" : "Real"}');
        
        LatLng newLocation = LatLng(position.latitude, position.longitude);
        
        setState(() {
          _currentLocation = newLocation;
          _locationAccuracy = position.accuracy;
          _lastLocationUpdate = DateTime.now();
          _locationSource = position.isMocked ? 'Mock/Emulator' : 'Real GPS';
          
          if (_isRunning && !_isPaused) {
            // Only add point if we moved significantly (reduce noise)
            if (_routePoints.isEmpty || 
                Geolocator.distanceBetween(
                  _routePoints.last.latitude,
                  _routePoints.last.longitude,
                  newLocation.latitude,
                  newLocation.longitude,
                ) > 3) { // 3 meters threshold
              _routePoints.add(newLocation);
              print('Added point to route. Total points: ${_routePoints.length}');
            }
          }
        });

        // Update map position smoothly
        _mapController.move(newLocation, _mapController.camera.zoom);
      },
      onError: (error) {
        print('Location stream error: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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

  // Request location permission with enhanced checks
  Future<void> _requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location services are disabled. Please enable them in settings.'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Open Settings',
              onPressed: () => Geolocator.openLocationSettings(),
            ),
          ),
        );
        return;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      print('Current permission status: $permission');

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print('Permission after request: $permission');
        
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are denied. Cannot track location.'),
              duration: Duration(seconds: 5),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location permissions are permanently denied. Please enable them in app settings.'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'App Settings',
              onPressed: () => Geolocator.openAppSettings(),
            ),
          ),
        );
        return;
      }

      // Permission granted
      setState(() {
        _locationPermissionGranted = true;
      });
      
      print('Location permission granted, starting location tracking...');
      
      // Get initial location and start stream
      await _getCurrentLocation();
      _startLocationStream();
      
    } catch (e) {
      print('Error in permission request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error requesting location permission: $e')),
      );
    }
  }

  // Get current location with enhanced error handling
  Future<void> _getCurrentLocation() async {
    if (!_locationPermissionGranted) {
      print('Location permission not granted');
      return;
    }

    try {
      print('Getting current location...');
      
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings
      );
      
      print('Got location: ${position.latitude}, ${position.longitude}');
      print('Accuracy: ${position.accuracy}m');
      print('Provider: ${position.isMocked ? "Mock/Emulator" : "Real GPS"}');
      print('Altitude: ${position.altitude}m');
      print('Speed: ${position.speed}m/s');
      
      LatLng newLocation = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _currentLocation = newLocation;
        _locationAccuracy = position.accuracy;
        _lastLocationUpdate = DateTime.now();
        _locationSource = position.isMocked ? 'Mock/Emulator' : 'Real GPS';
        
        if (_isRunning && !_isPaused) {
          _routePoints.add(newLocation);
          print('Added point to route. Total points: ${_routePoints.length}');
        }
      });

      // Move map to current location
      _mapController.move(newLocation, 18.0);
      
    } catch (e) {
      print('Error getting location: $e');
      
      String errorMessage = 'Failed to get location: ';
      if (e.toString().contains('PERMISSION_DENIED')) {
        errorMessage += 'Permission denied';
      } else if (e.toString().contains('POSITION_UNAVAILABLE')) {
        errorMessage += 'Position unavailable. Try moving to an open area or check if you\'re using a real device.';
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

  // Start the timer and location tracking
  void _startTimer() {
    if (_isPaused) {
      // Resume from pause
      setState(() {
        _isPaused = false;
      });
    } else {
      // Fresh start
      setState(() {
        _elapsedSeconds = 0;
        _routePoints.clear();
        _isRunning = true;
      });
      
      // Get initial location for the route
      _getCurrentLocation();
    }

    // Start the timer (1 second intervals)
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });

    // Start continuous location tracking
    _startLocationStream();
  }

  // Pause the timer and location tracking
  void _pauseTimer() {
    _timer?.cancel();
    _positionStreamSubscription?.cancel();
    setState(() {
      _isPaused = true;
    });
  }

  // Stop/End the timer and location tracking
  void _stopTimer() {
    _timer?.cancel();
    _positionStreamSubscription?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });
    double distance = _calculateTotalDistance();
    String formattedTime = _formatTime(_elapsedSeconds);
    // Show completion dialog
    WorkoutCompletionDialog.show(
      context,
      summaryItems: [
        WorkoutSummaryItem(value: formattedTime, label:'Time' ),
        WorkoutSummaryItem(value: '${distance.toStringAsFixed(2)} km', label: 'Distance'),
        WorkoutSummaryItem(value: '${distance > 0 ? ((distance / (_elapsedSeconds / 3600)).toStringAsFixed(1)) : "0"} km/h', label: 'Average Speed'),
        WorkoutSummaryItem(value: '${_routePoints.length}', label: 'Route Points'),
      ],
      showRestartButton: false
    );
  }

  // Calculate total distance of the route
  double _calculateTotalDistance() {
    if (_routePoints.length < 2) return 0.0;
    
    double totalDistance = 0.0;
    for (int i = 0; i < _routePoints.length - 1; i++) {
      totalDistance += Geolocator.distanceBetween(
        _routePoints[i].latitude,
        _routePoints[i].longitude,
        _routePoints[i + 1].latitude,
        _routePoints[i + 1].longitude,
      );
    }
    return totalDistance / 1000; // Convert to kilometers
  }

  // Format time as HH:MM:SS
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
                          initialCenter: _currentLocation ?? const LatLng(13.0827, 80.2707),
                          initialZoom: 18.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.trackntrain',
                          ),
                          const RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution('OpenStreetMap contributors'),
                            ],
                          ),
                          // Current location marker
                          if (_currentLocation != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _currentLocation!,
                                  width: 30,
                                  height: 30,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _locationSource.contains('Mock') ? Colors.orange : Colors.blue,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
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
                                      size: 18
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          // Route polyline
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
                          // Route start marker
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
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 14),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      // Location status indicator - Enhanced design
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _currentLocation != null 
                              ? (_locationSource.contains('Mock') ? Colors.orange : Colors.green)
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
                                _currentLocation != null ? Icons.gps_fixed : Icons.gps_not_fixed,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _currentLocation != null 
                                  ? (_locationSource.contains('Mock') ? 'MOCK GPS' : 'REAL GPS')
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
                      // Manual location button - Enhanced design
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
            
            // Debug Info - Improved design (temporary)
            // if (_currentLocation != null)
            //   Container(
            //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            //     padding: const EdgeInsets.all(16),
            //     decoration: BoxDecoration(
            //       color: _locationSource.contains('Mock') ? Colors.orange[50] : Colors.green[50],
            //       borderRadius: BorderRadius.circular(16),
            //       border: Border.all(
            //         color: (_locationSource.contains('Mock') ? Colors.orange : Colors.green).withOpacity(0.3),
            //         width: 1,
            //       ),
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.black.withOpacity(0.05),
            //           spreadRadius: 0,
            //           blurRadius: 10,
            //           offset: const Offset(0, 2),
            //         ),
            //       ],
            //     ),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Row(
            //           children: [
            //             Icon(
            //               _locationSource.contains('Mock') ? Icons.warning_rounded : Icons.check_circle_rounded,
            //               size: 18,
            //               color: _locationSource.contains('Mock') ? Colors.orange[700] : Colors.green[700],
            //             ),
            //             const SizedBox(width: 8),
            //             Text(
            //               'Location Status: $_locationSource', 
            //               style: TextStyle(
            //                 fontSize: 13, 
            //                 fontWeight: FontWeight.w600,
            //                 color: _locationSource.contains('Mock') ? Colors.orange[800] : Colors.green[800],
            //               )
            //             ),
            //           ],
            //         ),
            //         const SizedBox(height: 8),
            //         Wrap(
            //           spacing: 16,
            //           runSpacing: 4,
            //           children: [
            //             Text('Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}', 
            //               style: TextStyle(fontSize: 11, color: Colors.grey[700])),
            //             Text('Lng: ${_currentLocation!.longitude.toStringAsFixed(6)}', 
            //               style: TextStyle(fontSize: 11, color: Colors.grey[700])),
            //             Text('Accuracy: ${_locationAccuracy.toStringAsFixed(1)}m', 
            //               style: TextStyle(fontSize: 11, color: Colors.grey[700])),
            //             Text('Points: ${_routePoints.length}', 
            //               style: TextStyle(fontSize: 11, color: Colors.grey[700])),
            //           ],
            //         ),
            //         if (_locationSource.contains('Mock'))
            //           Padding(
            //             padding: const EdgeInsets.only(top: 8),
            //             child: Text(
            //               'ℹ Using emulator location. For real GPS, use a physical device.',
            //               style: TextStyle(
            //                 fontSize: 11, 
            //                 color: Colors.orange[700], 
            //                 fontWeight: FontWeight.w500,
            //                 fontStyle: FontStyle.italic,
            //               ),
            //             ),
            //           ),
            //       ],
            //     ),
            //   ),
            
            // Stats Display - Enhanced and expanded
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
                    // Main timer display
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                            const Color.fromARGB(255, 247, 2, 2).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.2),
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
                    
                    // Secondary stats
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
                        Expanded(
                          child: _buildStatCard(
                            _elapsedSeconds > 0 
                              ? '${(_calculateTotalDistance() / (_elapsedSeconds / 3600)).toStringAsFixed(1)}'
                              : '0.0',
                            'km/h',
                            'Avg Speed',
                            Icons.speed_rounded,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Control Buttons - Enhanced design
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                children: [
                  // Start/Resume Button
                  if (!_isRunning || _isPaused)
                    Expanded(
                      child: _buildControlButton(
                        onPressed: _locationPermissionGranted ? _startTimer : null,
                        icon: _isPaused ? Icons.play_arrow_rounded : Icons.play_arrow_rounded,
                        label: _isPaused ? 'Resume' : 'Start',
                        color: const Color.fromARGB(255, 247, 2, 2),
                        isEnabled: _locationPermissionGranted,
                      ),
                    ),
                  
                  // Pause Button
                  if (_isRunning && !_isPaused)
                    Expanded(
                      child: _buildControlButton(
                        onPressed: _pauseTimer,
                        icon: Icons.pause_rounded,
                        label: 'Pause',
                        color: Colors.orange,
                      ),
                    ),
                  
                  // Spacing between buttons
                  if (_isRunning) const SizedBox(width: 12),
                  
                  // Stop Button
                  if (_isRunning)
                    Expanded(
                      child: _buildControlButton(
                        onPressed: _stopTimer,
                        icon: Icons.stop_rounded,
                        label: 'End',
                        color: Colors.red[700]!,
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
  
  Widget _buildStatCard(String value, String unit, String label, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
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
  
  Widget _buildControlButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
    bool isEnabled = true,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: isEnabled ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ) : null,
        color: isEnabled ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled ? [
                      BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
}