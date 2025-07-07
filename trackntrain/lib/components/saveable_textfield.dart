import 'package:flutter/material.dart';
import 'package:trackntrain/utils/misc.dart';

class SaveableTextField extends StatefulWidget {
  final String? initialValue;
  final String hintText;
  final Function(String)? onSave;

  const SaveableTextField({
    super.key,
    this.initialValue,
    this.hintText = 'Enter text',
    this.onSave,
  });

  @override
  State<SaveableTextField> createState() => _SaveableTextFieldState();
}

class _SaveableTextFieldState extends State<SaveableTextField> {
  late TextEditingController _controller;
  bool _isEditing = false;
  String _originalValue = '';

  @override
  void initState() {
    super.initState();
    _originalValue = widget.initialValue ?? '';
    _controller = TextEditingController(text: _originalValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    setState(() {
      _originalValue = _controller.text;
      _isEditing = false;
    });
    widget.onSave?.call(_controller.text);
    showCustomSnackBar(
      context: context,
      message: 'Profile updated successfully',
      disableCloseButton: true,
    );
  }

  void _cancel() {
    setState(() {
      _controller.text = _originalValue;
      _isEditing = false;
    });
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[50]!, Colors.white],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        maxLength: 100,
        controller: _controller,
        cursorColor: Theme.of(context).primaryColor,
        
        readOnly: !_isEditing,
        onTap: _isEditing ? null : _startEditing,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontFamily: 'Poppins',
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          suffixIcon: 
            Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: _cancel,
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: _save,
                  ),
                ],
              )
        ),
      ),
    );
  }
}