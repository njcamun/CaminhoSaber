import 'package:flutter/material.dart';

class PunchCounter extends StatefulWidget {
  final int value;
  final Color? color;
  final double fontSize;

  const PunchCounter({
    required this.value,
    this.color,
    this.fontSize = 24,
    super.key,
  });

  @override
  State<PunchCounter> createState() => _PunchCounterState();
}

class _PunchCounterState extends State<PunchCounter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    // Fix: Move the curve into each sequence item instead of the driving animation
    // to avoid the "t >= 0.0 && t <= 1.0" assertion error in TweenSequence.
    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(PunchCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Text(
        '${widget.value}',
        style: TextStyle(
          fontSize: widget.fontSize,
          fontWeight: FontWeight.w600,
          color: widget.color ?? Colors.orangeAccent,
        ),
      ),
    );
  }
}
