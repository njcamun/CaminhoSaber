import 'package:flutter/material.dart';

class NeumorphicWrapper extends StatelessWidget {
  final Widget child;
  final bool isPressed;
  final double borderRadius;
  final Color baseColor;

  const NeumorphicWrapper({
    required this.child,
    this.isPressed = false,
    this.borderRadius = 20,
    this.baseColor = Colors.white,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(4, 4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.9),
                  offset: const Offset(-4, -4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(6, 6),
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  offset: const Offset(-6, -6),
                  blurRadius: 10,
                ),
              ],
      ),
      child: child,
    );
  }
}
