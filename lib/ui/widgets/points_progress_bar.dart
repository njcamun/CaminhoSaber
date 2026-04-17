import 'package:flutter/material.dart';

class PointsProgressBar extends StatelessWidget {
  final double currentPoints;
  final double nextLevelPoints;
  final Color? color;

  const PointsProgressBar({
    required this.currentPoints,
    required this.nextLevelPoints,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (nextLevelPoints > 0) 
        ? (currentPoints / nextLevelPoints).clamp(0.0, 1.0) 
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Container(
          height: 16,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  final double safeValue = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);

                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: safeValue,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color ?? Colors.orange,
                            (color ?? Colors.orange).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: (color ?? Colors.orange).withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.4),
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
