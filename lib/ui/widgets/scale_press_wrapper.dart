import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScalePressWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const ScalePressWrapper({required this.child, required this.onTap, super.key});

  @override
  State<ScalePressWrapper> createState() => _ScalePressWrapperState();
}

class _ScalePressWrapperState extends State<ScalePressWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.92,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        _controller.forward();
        widget.onTap();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(scale: _controller, child: widget.child),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
