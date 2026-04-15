import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:caminho_do_saber/ui/widgets/punch_counter.dart';

class AnimatedStatIcon extends StatelessWidget {
  final String lottieAsset;
  final int value;
  final Color fallbackColor;
  final IconData fallbackIcon;
  final double size;

  const AnimatedStatIcon({
    required this.lottieAsset,
    required this.value,
    required this.fallbackColor,
    required this.fallbackIcon,
    this.size = 40,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Lottie.asset(
            lottieAsset,
            repeat: true,
            errorBuilder: (context, error, stackTrace) {
              return Icon(fallbackIcon, color: fallbackColor, size: size * 0.7);
            },
          ),
        ),
        PunchCounter(value: value, color: fallbackColor),
      ],
    );
  }
}
