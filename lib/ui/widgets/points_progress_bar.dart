import 'package:flutter/material.dart';

class PointsProgressBar extends StatelessWidget {
  final double currentPoints;
  final double nextLevelPoints;
  final List<Color>? gradientColors;
  final Color? color; // Mantido por compatibilidade

  const PointsProgressBar({
    required this.currentPoints,
    required this.nextLevelPoints,
    this.gradientColors,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (nextLevelPoints > 0) 
        ? (currentPoints / nextLevelPoints).clamp(0.0, 1.0) 
        : 0.0;

    final List<Color> effectiveColors = gradientColors ?? [
      color ?? Colors.orange,
      (color ?? Colors.orange).withValues(alpha: 0.7),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Container(
          height: 16,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(25),
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
                          colors: effectiveColors,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: effectiveColors.first.withValues(alpha: 0.3),
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
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
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
