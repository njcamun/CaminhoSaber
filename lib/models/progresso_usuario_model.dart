// lib/models/progresso_usuario_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressoUsuario {
  final String uid;
  int pontos;
  Map<String, int> estrelasPorCapitulo;
  String ultimoCapituloDesbloqueado;

  ProgressoUsuario({
    required this.uid,
    this.pontos = 0,
    this.estrelasPorCapitulo = const {},
    this.ultimoCapituloDesbloqueado = '',
  });

  // Converte um documento do Firestore em um objeto ProgressoUsuario
  factory ProgressoUsuario.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgressoUsuario(
      uid: doc.id,
      pontos: data['pontos'] ?? 0,
      estrelasPorCapitulo: Map<String, int>.from(data['estrelasPorCapitulo'] ?? {}),
      ultimoCapituloDesbloqueado: data['ultimoCapituloDesbloqueado'] ?? '',
    );
  }

  // Converte o objeto ProgressoUsuario em um formato para o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'pontos': pontos,
      'estrelasPorCapitulo': estrelasPorCapitulo,
      'ultimoCapituloDesbloqueado': ultimoCapituloDesbloqueado,
    };
  }
}
