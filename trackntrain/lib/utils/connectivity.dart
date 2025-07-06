import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trackntrain/utils/misc.dart';

class ConnectivityService {

  Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      print('Error checking internet connection: $e');
      return false;
    }
  }
  // Stream that emits connectivity status changes
  Stream<bool> get connectivityStream async* {
    bool lastStatus = await isConnected();
    yield lastStatus;
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      bool currentStatus = await isConnected();
      if (currentStatus != lastStatus) {
        yield currentStatus;
        lastStatus = currentStatus;
      }
    }
  }
  Future<bool> checkAndShowError(BuildContext context,String message) async {
    final isConnected = await this.isConnected();
    if (!isConnected) {
      showNoConnectionSnackBar(context,message);
    }
    return isConnected;
  }

  bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('unreachable') ||
        errorString.contains('unavailable') ||
        errorString.contains('connection') ||
        errorString.contains('host') ||
        errorString.contains('socketexception');
  }

  void showNoConnectionSnackBar(BuildContext context,String message) {
    
    showCustomSnackBar(context: context, message: message,type: 'error');
  }
}


class ConnectivityStatusWidget extends StatelessWidget {
  final bool isConnected;
  final double iconSize;
  final String onlineText;
  final String offlineText;
  final Duration overlayDuration;
  final double? overlayTop;
  final double? overlayRight;
  final double? overlayLeft;
  final double? overlayBottom;
  final VoidCallback? onTap;

  const ConnectivityStatusWidget({
    super.key,
    required this.isConnected,
    this.iconSize = 20,
    this.onlineText = 'Online',
    this.offlineText = 'Offline : Progress wont be saved',
    this.overlayDuration = const Duration(seconds: 1),
    this.overlayTop,
    this.overlayRight,
    this.overlayLeft,
    this.overlayBottom,
    this.onTap,
  });

  void _showOverlay(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: overlayTop ?? 60,
        right: overlayRight ?? 30,
        left: overlayLeft,
        bottom: overlayBottom,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isConnected ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isConnected
                      ? Icons.signal_wifi_4_bar
                      : Icons.signal_wifi_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isConnected ? onlineText : offlineText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(overlayDuration).then((_) {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => _showOverlay(context),
      child: Icon(
        isConnected ? Icons.signal_wifi_4_bar : Icons.signal_wifi_off,
        color: isConnected ? Colors.green : Colors.red,
        size: iconSize,
      ),
    );
  }
}
