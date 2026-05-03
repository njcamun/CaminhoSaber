// lib/ui/widgets/flash_card_item.dart

import 'package:flutter/material.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';

class FlashCardItem extends StatelessWidget {
  final String text;
  final bool isFront;

  const FlashCardItem({
    required this.text,
    required this.isFront,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(isFront),
      decoration: BoxDecoration(
        color: isFront ? Colors.white : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: SingleChildScrollView(
          child: Text(
            text.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isFront ? AppColors.primary : Colors.black87,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
