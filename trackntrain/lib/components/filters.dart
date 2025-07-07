import 'package:flutter/material.dart';

class Filters extends StatelessWidget {
  const Filters({
    super.key,
    required this.filters,
    required this.toggleFilters,
    required this.onApply,
  });
  
  final List<Map<String, dynamic>> filters;
  final void Function(String muscleGroup, bool value) toggleFilters;
  final VoidCallback onApply;

  List<Widget> _buildFilterChips() {
    return filters.map((filter) {
      final bool isSelected = filter['selected'] ?? false;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: FilterChip(
          label: Text(
            filter['muscleGroup'],
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontFamily: 'Poppins',
              fontSize: 13,
            ),
          ),
          selected: isSelected,
          selectedColor: const Color.fromARGB(255, 247, 2, 2),
          backgroundColor: Colors.grey[50],
          checkmarkColor: Colors.white,
          side: BorderSide(
            color: isSelected 
                ? const Color.fromARGB(255, 247, 2, 2)
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          onSelected: (value) {
            toggleFilters(filter['muscleGroup'], value);
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = filters.where((filter) => filter['selected'] == true).length;
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = screenHeight - keyboardHeight;
    
    // Adjust spacing based on available height
    final isCompactScreen = availableHeight < 600;
    final headerSpacing = isCompactScreen ? 16.0 : 24.0;
    final containerPadding = isCompactScreen ? 16.0 : 24.0;
    final buttonSpacing = isCompactScreen ? 16.0 : 24.0;
    
    return Container(
      margin: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: availableHeight * 0.8, // Limit to 80% of available height
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with icon and title
          Padding(
            padding: EdgeInsets.all(containerPadding),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: Color.fromARGB(255, 247, 2, 2),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Muscle Groups',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black87,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      if (selectedCount > 0)
                        Text(
                          '$selectedCount muscle group${selectedCount > 1 ? 's' : ''} selected',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Filter chips in a flexible, scrollable container
          Flexible(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: containerPadding),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color.fromARGB(255, 247, 2, 2).withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildFilterChips(),
                ),
              ),
            ),
          ),
          
          SizedBox(height: buttonSpacing),
          
          // Apply button
          Padding(
            padding: EdgeInsets.fromLTRB(containerPadding, 0, containerPadding, containerPadding),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 247, 2, 2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}