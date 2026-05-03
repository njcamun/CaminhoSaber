import 'package:flutter/material.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';

class NeumorphicWrapper extends StatelessWidget {
  final Widget child;
  final bool isPressed;
  final double borderRadius;
  final Color baseColor;

  const NeumorphicWrapper({
    required this.child,
    this.isPressed = false,
    this.borderRadius = 25, // Padronizado Educlass Aura
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
          ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2))]
          : AppShadows.primaryShadow,
      ),
      child: child,
    );
  }
}
