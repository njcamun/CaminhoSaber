import 'dart:async';
import 'package:flutter/material.dart';

class RetroTypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;

  const RetroTypewriterText({
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 800),
    super.key,
  });

  @override
  State<RetroTypewriterText> createState() => _RetroTypewriterTextState();
}

class _RetroTypewriterTextState extends State<RetroTypewriterText> {
  String _displayedText = "";
  int _charIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(RetroTypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _displayedText = "";
      _charIndex = 0;
      _timer?.cancel();
      _startTyping();
    }
  }

  void _startTyping() {
    if (widget.text.isEmpty) return;
    final charDuration = widget.duration.inMilliseconds ~/ widget.text.length;
    
    _timer = Timer.periodic(Duration(milliseconds: charDuration.clamp(10, 100)), (timer) {
      if (_charIndex < widget.text.length) {
        if (mounted) {
          setState(() {
            _displayedText += widget.text[_charIndex];
            _charIndex++;
          });
        }
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
      textAlign: TextAlign.center,
    );
  }
}
