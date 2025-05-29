import 'package:flutter/material.dart';

class TopBanner extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const TopBanner({
    super.key,
    required this.message,
    required this.onClose,
  }) ;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(248, 1, 173, 252),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 20,
                  color: Colors.white,
                ),
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showTopBanner({
  required BuildContext context,
  required String message,
  Duration duration = const Duration(seconds: 2),
  VoidCallback? onClose,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;
  
  void close() {
    overlayEntry.remove();
    if (onClose != null) onClose();
  }
  
  overlayEntry = OverlayEntry(
    builder: (context) => TopBanner(
      message: message,
      onClose: close,
    ),
  );

  overlay.insert(overlayEntry);
  Future.delayed(duration, close);
}