import 'package:flutter/material.dart';

class ExerciseBrief extends StatefulWidget {
  const ExerciseBrief({
    super.key,
    required this.title,
    required this.description,
    required this.specialConsiderations,
    required this.isChecked,
    required this.onChanged,
  });
  final String title;
  final String description;
  final String specialConsiderations;
  final bool isChecked;
  final void Function(bool?) onChanged;

  @override
  State<ExerciseBrief> createState() => _ExerciseBriefState();
}

class _ExerciseBriefState extends State<ExerciseBrief> {

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox.adaptive(
        activeColor: Theme.of(context).primaryColor,
        value: widget.isChecked,
        onChanged: widget.onChanged
      ),
      horizontalTitleGap: 50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      title: Text(widget.title),
      trailing: IconButton(
        icon: const Icon(Icons.info_outline),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(widget.title,textAlign: TextAlign.center,),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.description),
                  const SizedBox(height: 10),
                  const Text(
                    'Special Considerations:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(widget.specialConsiderations),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor
                  ),
                  child: Text('OK',style: TextStyle(color: Colors.white),),
                ),
              ],
            ));
        },
      ),
    );
  }
}
