
import 'package:flutter/material.dart';

class WorkoutSummaryItem {
  final String value;
  final String label;
  WorkoutSummaryItem({required this.value, required this.label});
}

class WorkoutCompletionDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<WorkoutSummaryItem> summaryItems;
  final VoidCallback? onRestart;
  final VoidCallback? onDone;
  final bool showRestartButton;

  const WorkoutCompletionDialog({
    super.key,
    this.title = 'Workout Complete!',
    this.subtitle = 'Congratulations! You crushed it!',
    required this.summaryItems,
    this.onRestart,
    this.onDone,
    this.showRestartButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      contentPadding: EdgeInsets.zero,
      content: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[50]!],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 247, 2, 2),
                    Color.fromARGB(255, 220, 20, 20),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Workout Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryItems(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      if (showRestartButton) ...[
                        Expanded(
                          child: _buildActionButton(
                            onTap: onRestart,
                            icon: Icons.restart_alt_rounded,
                            label: 'Restart',
                            isPrimary: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: _buildActionButton(
                          onTap: onDone,
                          icon: Icons.check_circle_rounded,
                          label: 'Done',
                          isPrimary: true,
                        ),
                      ),
                      
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItems() {
    if (summaryItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // If only one item, center it
    if (summaryItems.length == 1) {
      return _buildSummaryItem(summaryItems.first);
    }

    if (summaryItems.length == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: summaryItems.map((item) => _buildSummaryItem(item)).toList(),
      );
    }

    return Wrap(
      spacing: 20,
      runSpacing: 16,
      alignment: WrapAlignment.spaceAround,
      children: summaryItems.map((item) => _buildSummaryItem(item)).toList(),
    );
  }

  Widget _buildSummaryItem(WorkoutSummaryItem item) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          item.value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onTap,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isPrimary
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 247, 2, 2),
                  Color.fromARGB(255, 220, 20, 20),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey[50]!],
              ),
        borderRadius: BorderRadius.circular(16),
        border: isPrimary
            ? null
            : Border.all(
                color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.2),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? const Color.fromARGB(255, 247, 2, 2).withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: isPrimary ? 12 : 8,
            offset: Offset(0, isPrimary ? 4 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isPrimary 
                      ? Colors.white 
                      : const Color.fromARGB(255, 247, 2, 2),
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isPrimary 
                        ? Colors.white 
                        : const Color.fromARGB(255, 247, 2, 2),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    String? title,
    String? subtitle,
    required List<WorkoutSummaryItem> summaryItems,
    VoidCallback? onRestart,
    VoidCallback? onDone,
    bool showRestartButton = true,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WorkoutCompletionDialog(
          title: title ?? 'Workout Complete!',
          subtitle: subtitle ?? 'Congratulations! You crushed it!',
          summaryItems: summaryItems,
          onRestart: onRestart,
          onDone: onDone,
          showRestartButton: showRestartButton,
        );
      },
    );
  }
}