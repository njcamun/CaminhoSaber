import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class StreakFire extends StatelessWidget {
  final int days;
  final bool isActive;

  const StreakFire({required this.days, this.isActive = true, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (isActive)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: 50,
              height: 50,
              child: kIsWeb 
                ? Icon(Icons.local_fire_department_rounded, color: isActive ? Colors.orange : Colors.grey, size: 35)
                : Lottie.asset(
                    'assets/animations/fire.json',
                    animate: isActive,
                    repeat: true,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 30);
                    },
                  ),
            ),
            Positioned(
              bottom: 2,
              child: Text(
                '$days',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
