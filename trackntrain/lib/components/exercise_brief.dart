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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isChecked 
            ? const Color.fromARGB(255, 247, 2, 2).withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isChecked 
              ? const Color.fromARGB(255, 247, 2, 2).withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Transform.scale(
          scale: 1.2,
          child: Checkbox.adaptive(
            activeColor: const Color.fromARGB(255, 247, 2, 2),
            checkColor: Colors.white,
            value: widget.isChecked,
            onChanged: widget.onChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: widget.isChecked ? FontWeight.w600 : FontWeight.w500,
            color: Colors.black87,
            fontFamily: 'Poppins',
            fontSize: 15,
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: Color.fromARGB(255, 247, 2, 2),
              size: 20,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(
                          'Description',
                          widget.description,
                          Icons.description,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoSection(
                          'Special Considerations',
                          widget.specialConsiderations,
                          Icons.warning_amber_rounded,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 247, 2, 2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Got it',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: const Color.fromARGB(255, 247, 2, 2),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}