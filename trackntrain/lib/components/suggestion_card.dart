

import 'package:flutter/material.dart';

class SuggestionCard extends StatefulWidget{
  final String suggestion;
  final bool isLoading;
  final bool showTypingIndicator;

  const SuggestionCard({super.key, required this.suggestion, this.isLoading = false, this.showTypingIndicator = false});
  @override
  State<SuggestionCard> createState() => _SuggestionCardState();

}
class _SuggestionCardState extends State<SuggestionCard> with TickerProviderStateMixin {
  late AnimationController _typingController;
  late Animation<int> _characterCount;
  String _displayedText = '';
  bool _isAnimating = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _typingController=AnimationController(
      vsync:this,
      duration: Duration(milliseconds: widget.suggestion.length * 50),
    );
  }

  @override
  void didUpdateWidget(covariant SuggestionCard oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if(widget.suggestion != oldWidget.suggestion
      && widget.suggestion.isNotEmpty
      && widget.showTypingIndicator){
        _startTypingAnimation();
    } else if (widget.suggestion.isEmpty) {
      setState(() {
        _displayedText=widget.suggestion;
      });
    }
      }

  void _startTypingAnimation() {
    setState(() {
      _displayedText = '';
      _isAnimating = true;
    });
    _typingController.duration=Duration(milliseconds: widget.suggestion.length * 50);

    _characterCount=IntTween(
      begin: 0,
      end: widget.suggestion.length,
    ).animate(CurvedAnimation(parent: _typingController, curve: Curves.easeOut));

    _typingController.addListener((){
      setState(() {
        _displayedText = widget.suggestion.substring(0, _characterCount.value);
      });
    });

    _typingController.addStatusListener((status){
      if(status == AnimationStatus.completed){
        setState(() {
          _isAnimating = false;
        });
      }
    });
    _typingController.forward(from: 0);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _typingController.dispose();
    super.dispose();
  }
  
  
  @override
  Widget build(BuildContext context) {
    if(widget.suggestion.isEmpty && !widget.isLoading) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Insights',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Content
            if (widget.isLoading)
              _buildLoadingIndicator()
            else if (_displayedText.isNotEmpty || widget.suggestion.isNotEmpty)
              _buildTextContent()
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Analyzing your data...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Shimmer effect for loading
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.showTypingIndicator ? _displayedText : widget.suggestion,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
            children: [
              // Add blinking cursor while typing
              if (_isAnimating && widget.showTypingIndicator)
                WidgetSpan(
                  child: AnimatedOpacity(
                    opacity: _isAnimating ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      width: 2,
                      height: 20,
                      color: Theme.of(context).primaryColor,
                      margin: const EdgeInsets.only(left: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Progress indicator for typing
        if (_isAnimating && widget.showTypingIndicator)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(
              value: _characterCount.value / widget.suggestion.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
      ],
    );
  }
}