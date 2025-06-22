

import 'package:flutter/material.dart';

class CustomSnackBar extends StatelessWidget{
  const CustomSnackBar({
    super.key,
    required this.message,
    required this.type,
    this.disableCloseButton = false,
  });

  final String message;
  final String type;
  final bool disableCloseButton;

  SnackBar buildSnackBar(BuildContext context) {
    return SnackBar(
      content: Text(message,style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      )),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: type == 'error' ? Theme.of(context).primaryColor : const Color.fromARGB(255, 26, 234, 33),
      duration: const Duration(seconds: 3),
      action:!disableCloseButton? SnackBarAction(
        label: 'Close',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ):null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildSnackBar(context);
  }

}