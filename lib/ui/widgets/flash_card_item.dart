// lib/ui/widgets/flash_card_item.dart

import 'package:flutter/material.dart';

class FlashCardItem extends StatelessWidget {
  final String title;

  const FlashCardItem({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.02, // Inclinação sutil para simular um papel colado
      child: Card(
        elevation: 8.0, // Sombra mais pronunciada para efeito de "colado"
        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25), // Bordas padrão Educlass
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.yellow[100]!, Colors.yellow[200]!], // Gradiente sutil de amarelo claro
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.1), // Borda fina para delimitar
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(3, 3), // Sombra mais suave
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600, // Peso da fonte Educlass Aura
                color: Colors.grey[800], // Cor de texto mais suave
                fontFamily: 'Caveat', // Uma fonte que lembre escrita à mão (adicione ao pubspec.yaml)
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Para usar a fonte 'Caveat', adicione ao seu pubspec.yaml:
// fonts:
//   - family: Caveat
//     fonts:
//       - asset: fonts/Caveat-Regular.ttf
//       - asset: fonts/Caveat-Bold.ttf
//         weight: 700
// (e coloque os arquivos .ttf na pasta fonts do seu projeto)
