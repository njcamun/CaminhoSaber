// lib/ui/widgets/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.icon,
    this.isPassword = false,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = AppColors.primary;
    // Usar estilos base do tema para garantir consistência na herança (inherit)
    final labelStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: primaryColor,
      fontWeight: FontWeight.w600,
    ) ?? const TextStyle(color: primaryColor, fontWeight: FontWeight.w600);

    final errorStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppColors.error,
      fontWeight: FontWeight.w600,
    ) ?? const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600);

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: TextStyle(color: primaryColor, fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily),
      decoration: InputDecoration(
        labelText: labelText.toUpperCase(),
        labelStyle: labelStyle,
        errorStyle: errorStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        prefixIcon: Icon(icon, color: primaryColor),
      ),
      validator: validator,
    );
  }
}
