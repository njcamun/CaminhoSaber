// lib/services/ranking_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:caminho_do_saber/services/auth_service.dart';
import 'package:caminho_do_saber/database/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class RankingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final AppDatabase _db;

  RankingService(this._db);

  final StreamController<int> _totalExplorersController = StreamController<int>.broadcast();

  Future<void> updateProfileRanking(Profile profile, int totalPoints) async {
    final user = _authService.currentUser;
    if (user == null || user.isAnonymous) return;

    final rankingDocRef = _firestore.collection('ranking_global').doc(profile.uid);

    try {
      debugPrint('[RankingService] A enviar para o Ranking Global: ${profile.nome} com $totalPoints pontos');
      await rankingDocRef.set({
        'profileUid': profile.uid,
        'parentUid': user.uid,
        'name': profile.nome,
        'avatarPath': profile.avatarAssetPath,
        'totalPoints': totalPoints,
        'stars': (totalPoints / 250).floor(), // Campo adicionado para redundância e compatibilidade
        'lastUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Atualizar cache local imediatamente para refletir a mudança sem esperar pelo próximo refresh
      await _db.into(_db.globalRanking).insertOnConflictUpdate(
        GlobalRankingCompanion.insert(
          profileUid: profile.uid,
          name: profile.nome,
          avatarPath: profile.avatarAssetPath,
          totalPoints: totalPoints,
          lastUpdate: DateTime.now(),
          parentUid: Value(user.uid),
        ),
      );
    } catch (e) {
      debugPrint("Erro ao atualizar o ranking do perfil: $e");
    }
  }

  Future<void> refreshLocalRankingCache() async {
    try {
      // 1. Buscar o Top 100 Global
      final snapshot = await _firestore
          .collection('ranking_global')
          .orderBy('totalPoints', descending: true)
          .limit(100)
          .get();

      await _db.transaction(() async {
        await _db.delete(_db.globalRanking).go();
        
        final List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocsToCache = [...snapshot.docs];

        // 2. Buscar também os perfis do próprio utilizador para garantir visibilidade local
        final user = _authService.currentUser;
        if (user != null && !user.isAnonymous) {
          final userProfilesSnapshot = await _firestore
              .collection('ranking_global')
              .where('parentUid', isEqualTo: user.uid)
              .get();
          
          for (var userDoc in userProfilesSnapshot.docs) {
            if (!allDocsToCache.any((d) => d.id == userDoc.id)) {
              allDocsToCache.add(userDoc);
            }
          }
        }

        for (var doc in allDocsToCache) {
          final data = doc.data();
          await _db.into(_db.globalRanking).insertOnConflictUpdate(
            GlobalRankingCompanion.insert(
              profileUid: data['profileUid'] ?? doc.id,
              name: data['name'] ?? 'Explorador',
              avatarPath: data['avatarPath'] ?? 'assets/avatars/default.png',
              totalPoints: data['totalPoints'] ?? 0,
              lastUpdate: (data['lastUpdate'] as Timestamp?)?.toDate() ?? DateTime.now(),
              parentUid: Value(data['parentUid']),
            ),
          );
        }
      });

      // Atualizar a contagem total global
      final countSnapshot = await _firestore.collection('ranking_global').count().get();
      final totalCount = countSnapshot.count;
      if (totalCount != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('total_explorers_count', totalCount);
        _totalExplorersController.add(totalCount);
      }
      
      debugPrint("Cache do ranking global atualizado: ${snapshot.docs.length} perfis. Total: $totalCount");
    } catch (e) {
      debugPrint("Erro ao atualizar cache local: $e");
    }
  }

  // Stream para o ranking global vindo do banco LOCAL
  Stream<List<Map<String, dynamic>>> getLocalRankingStream() {
    return (_db.select(_db.globalRanking)
          ..orderBy([(t) => OrderingTerm(expression: t.totalPoints, mode: OrderingMode.desc)]))
        .watch()
        .map((rows) {
      return rows.map((row) => {
        'profileUid': row.profileUid,
        'parentUid': row.parentUid,
        'name': row.name,
        'avatarPath': row.avatarPath,
        'totalPoints': row.totalPoints,
        'lastUpdate': row.lastUpdate,
      }).toList();
    });
  }

  // Stream para contar o total de alunos inscritos (Híbrido: Cache + Local)
  Stream<int> getTotalExplorersStream() async* {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getInt('total_explorers_count');
    if (cached != null) {
      yield cached;
    } else {
      final row = await _db.customSelect('SELECT COUNT(*) as c FROM global_ranking').getSingle();
      yield row.read<int>('c');
    }
    yield* _totalExplorersController.stream;
  }

  void dispose() {
    _totalExplorersController.close();
  }

  // Obtém a posição de um perfil específico no ranking LOCAL
  Stream<int> getProfileRankStream(String profileUid) {
    return getLocalRankingStream().map((list) {
      final index = list.indexWhere((item) => item['profileUid'] == profileUid);
      return index == -1 ? 0 : index + 1;
    });
  }

  // Remove dados de teste do ranking global na cloud
  Future<void> clearTestRankingData() async {
    final bots = ['bot_1', 'bot_2', 'bot_3', 'bot_4'];

    for (var botUid in bots) {
      try {
        await _firestore.collection('ranking_global').doc(botUid).delete();
      } catch (e) {
        debugPrint("Erro ao remover bot: $e");
      }
    }
    // Forçar refresh após limpar
    await refreshLocalRankingCache();
  }
}
