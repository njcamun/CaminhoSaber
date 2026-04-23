// lib/ui/widgets/background_container.dart

import 'package:flutter/material.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;

  const BackgroundContainer({super.key, required this.child, this.baseColor});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Padrão Educlass: Fundo sólido e limpo para realçar os cards neumórficos e as cores vibrantes.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      ),
      child: child,
    );
  }
}
