// lib/services/ranking_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:caminho_do_saber/services/auth_service.dart';
import 'package:caminho_do_saber/database/database.dart';

class RankingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Atualiza o ranking para um perfil específico
  Future<void> updateProfileRanking(Profile profile, int totalPontos) async {
    final user = _authService.currentUser;
    if (user == null || user.isAnonymous) return;

    // Usamos uma coleção dedicada 'ranking_global' para facilitar a consulta de todos os perfis de todos os users
    final rankingDocRef = _firestore.collection('ranking_global').doc(profile.uid);

    try {
      await rankingDocRef.set({
        'profileUid': profile.uid,
        'parentUid': user.uid,
        'name': profile.nome,
        'avatarPath': profile.avatarAssetPath,
        'totalPoints': totalPontos,
        'lastUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Erro ao atualizar o ranking do perfil: $e");
    }
  }

  // Stream para os 10 melhores alunos de toda a aplicação
  Stream<List<Map<String, dynamic>>> getGlobalTop10Stream() {
    return _firestore
        .collection('ranking_global')
        .orderBy('totalPoints', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // NOVO: Stream para contar o total de alunos inscritos no ranking
  Stream<int> getTotalExplorersStream() {
    return _firestore.collection('ranking_global').snapshots().map((snapshot) => snapshot.docs.length);
  }

  // Obtém a posição de um perfil específico no ranking global
  Stream<int> getProfileRankStream(String profileUid) {
    return _firestore.collection('ranking_global').doc(profileUid).snapshots().asyncMap((doc) async {
      if (!doc.exists || !doc.data()!.containsKey('totalPoints')) {
        return 0;
      }

      final points = doc.data()!['totalPoints'];

      final snapshot = await _firestore
          .collection('ranking_global')
          .where('totalPoints', isGreaterThan: points)
          .count()
          .get();

      return (snapshot.count ?? 0) + 1;
    });
  }
}
