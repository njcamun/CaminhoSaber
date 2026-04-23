// lib/ui/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Paleta Educlass Aura Original
  static const Color primary = Color(0xFF00C5FE);    // Azul Edu
  static const Color secondary = Color(0xFF00D2B4);  // Turquesa/Seafoam
  static const Color tertiary = Color(0xFF9575CD);   // Lavanda Suave
  static const Color accent = Color(0xFFFFB300);     // Âmbar/Dourado
  
  // Padrão Educlass: Fundo Branco Puro para destaque dos componentes coloridos
  static const Color background = Color(0xFFFFFFFF); 

  static const Color success = Color(0xFF66BB6A);    // Verde Suave
  static const Color error = Color(0xFFE57373);      // Vermelho Suave
  static const Color gold = Color(0xFFFF8F00);
  static const Color yellow = Color(0xFFFEDE28);
  static const Color orange = Color(0xFFFF9800);
  static const Color green = Color(0xFF4CAF50);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
}

class AppShadows {
  // Sombra Neumórfica Padrão Aura
  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: Colors.grey.shade400.withValues(alpha: 0.3),
      blurRadius: 15,
      offset: const Offset(0, 8),
    ),
  ];

  // Sombra de topo para seções e cards de disciplina
  static List<BoxShadow> get topShadow => [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.15),
      blurRadius: 20,
      offset: const Offset(0, -8),
    ),
  ];

  // Sombra suave para itens menores
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}
