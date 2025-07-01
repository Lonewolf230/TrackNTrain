

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
              _buildMarkdownContent()
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

  Widget _buildMarkdownContent() {
    String textToDisplay = widget.showTypingIndicator ? _displayedText : widget.suggestion;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _parseMarkdown(textToDisplay),
        ),

        // Typing cursor
        if (_isAnimating && widget.showTypingIndicator)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: AnimatedOpacity(
              opacity: _isAnimating ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                width: 2,
                height: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),

        // Progress indicator for typing animation
        if (_isAnimating && widget.showTypingIndicator)
          Padding(
            padding: const EdgeInsets.only(top: 12),
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

  List<Widget> _parseMarkdown(String text) {
    List<Widget> widgets = [];
    List<String> lines = text.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }
      
      // Headers
      if (line.startsWith('### ')) {
        widgets.add(_buildHeader(line.substring(4), 18));
      } else if (line.startsWith('## ')) {
        widgets.add(_buildHeader(line.substring(3), 20));
      } else if (line.startsWith('# ')) {
        widgets.add(_buildHeader(line.substring(2), 24));
      }
      // Bullet points
      else if (line.trim().startsWith('- ') || line.trim().startsWith('* ')) {
        widgets.add(_buildBulletPoint(line.trim().substring(2)));
      }
      // Numbered lists
      else if (RegExp(r'^\d+\.\s').hasMatch(line.trim())) {
        String content = line.trim().replaceFirst(RegExp(r'^\d+\.\s'), '');
        String number = line.trim().split('.')[0];
        widgets.add(_buildNumberedPoint(content, number));
      }
      // Code blocks
      else if (line.trim().startsWith('```')) {
        // Find the end of code block
        int endIndex = i + 1;
        List<String> codeLines = [];
        while (endIndex < lines.length && !lines[endIndex].trim().startsWith('```')) {
          codeLines.add(lines[endIndex]);
          endIndex++;
        }
        if (endIndex < lines.length) {
          widgets.add(_buildCodeBlock(codeLines.join('\n')));
          i = endIndex; // Skip processed lines
        }
      }
      // Blockquotes
      else if (line.trim().startsWith('> ')) {
        widgets.add(_buildBlockquote(line.substring(2)));
      }
      // Regular paragraph
      else {
        widgets.add(_buildParagraph(line));
      }
      
      // Add spacing between elements
      if (i < lines.length - 1) {
        widgets.add(const SizedBox(height: 8));
      }
    }
    
    return widgets;
  }

  Widget _buildHeader(String text, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: _parseInlineMarkdown(text, TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
          height: 1.3,
        )),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return RichText(
      text: _parseInlineMarkdown(text, const TextStyle(
        fontSize: 16,
        color: Colors.black87,
        height: 1.5,
      )),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 8),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: RichText(
              text: _parseInlineMarkdown(text, const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedPoint(String text, String number) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$number.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: _parseInlineMarkdown(text, const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildBlockquote(String text) {
    return Container(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 4,
          ),
        ),
      ),
      child: RichText(
        text: _parseInlineMarkdown(text, TextStyle(
          fontSize: 16,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
          height: 1.5,
        )),
      ),
    );
  }

  TextSpan _parseInlineMarkdown(String text, TextStyle baseStyle) {
    List<TextSpan> spans = [];
    
    // Replace **bold** and __bold__
    text = text.replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) {
      return '§BOLD§${match.group(1)}§/BOLD§';
    });
    text = text.replaceAllMapped(RegExp(r'__(.*?)__'), (match) {
      return '§BOLD§${match.group(1)}§/BOLD§';
    });
    
    // Replace *italic* and _italic_
    text = text.replaceAllMapped(RegExp(r'\*(.*?)\*'), (match) {
      return '§ITALIC§${match.group(1)}§/ITALIC§';
    });
    text = text.replaceAllMapped(RegExp(r'_(.*?)_'), (match) {
      return '§ITALIC§${match.group(1)}§/ITALIC§';
    });
    

    List<String> parts = text.split(RegExp(r'§(BOLD|ITALIC|CODE|/BOLD|/ITALIC|/CODE)§'));
    
    TextStyle currentStyle = baseStyle;
    bool isBold = false;
    bool isItalic = false;
    bool isCode = false;
    
    for (int i = 0; i < parts.length; i++) {
      String part = parts[i];
      
      if (part == 'BOLD') {
        isBold = true;
        currentStyle = _updateStyle(baseStyle, isBold, isItalic, isCode);
      } else if (part == '/BOLD') {
        isBold = false;
        currentStyle = _updateStyle(baseStyle, isBold, isItalic, isCode);
      } else if (part == 'ITALIC') {
        isItalic = true;
        currentStyle = _updateStyle(baseStyle, isBold, isItalic, isCode);
      } else if (part == '/ITALIC') {
        isItalic = false;
        currentStyle = _updateStyle(baseStyle, isBold, isItalic, isCode);
      } else if (part == 'CODE') {
        isCode = true;
        currentStyle = _updateStyle(baseStyle, isBold, isItalic, isCode);
      } else if (part == '/CODE') {
        isCode = false;
        currentStyle = _updateStyle(baseStyle, isBold, isItalic, isCode);
      } else if (part.isNotEmpty) {
        spans.add(TextSpan(text: part, style: currentStyle));
      }
    }
    
    return TextSpan(children: spans);
  }

  TextStyle _updateStyle(TextStyle baseStyle, bool isBold, bool isItalic, bool isCode) {
    return baseStyle.copyWith(
      fontWeight: isBold ? FontWeight.bold : baseStyle.fontWeight,
      fontStyle: isItalic ? FontStyle.italic : baseStyle.fontStyle,
      backgroundColor: isCode ? Colors.grey[200] : baseStyle.backgroundColor,
      fontFamily: isCode ? 'monospace' : baseStyle.fontFamily,
      fontSize: isCode ? (baseStyle.fontSize! - 2) : baseStyle.fontSize,
    );
  }
}