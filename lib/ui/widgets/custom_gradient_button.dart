// lib/ui/widgets/custom_gradient_button.dart

import 'package:flutter/material.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:caminho_do_saber/services/audio_service.dart';

class CustomGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final baseTextStyle = Theme.of(context).textTheme.labelLarge ?? const TextStyle();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: baseTextStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        child: Text(text.toUpperCase()),
      ),
    );
  }
}
