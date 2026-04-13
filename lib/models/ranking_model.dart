// lib/models/ranking_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class RankingEntry {
  final String uid;
  final String nomeUsuario;
  final int pontosTotal;

  RankingEntry({
    required this.uid,
    required this.nomeUsuario,
    required this.pontosTotal,
  });

  factory RankingEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RankingEntry(
      uid: doc.id,
      nomeUsuario: data['nome_utilizador'] ?? 'Anónimo',
      pontosTotal: data['pontos_total'] ?? 0,
    );
  }
}
