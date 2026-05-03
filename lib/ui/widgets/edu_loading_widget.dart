import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';

class EduLoadingWidget extends StatelessWidget {
  final String? message;
  const EduLoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 120,
            child: Lottie.asset(
              'assets/animations/arcade.json', // Usando a animação de arcade como loading temático
              repeat: true,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            (message ?? 'SINCRIZANDO CONHECIMENTO...').toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 150,
            child: LinearProgressIndicator(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              borderRadius: BorderRadius.circular(10),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
