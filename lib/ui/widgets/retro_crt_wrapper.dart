import 'package:flutter/material.dart';

class RetroCRTWrapper extends StatelessWidget {
  final Widget child;
  final bool showScanlines;

  const RetroCRTWrapper({required this.child, this.showScanlines = true, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (showScanlines)
          IgnorePointer(
            child: CustomPaint(
              size: Size.infinite,
              painter: ScanlinePainter(),
            ),
          ),
      ],
    );
  }
}

class ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1.5;

    for (double i = 0; i < size.height; i += 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
