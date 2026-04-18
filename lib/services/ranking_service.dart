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
  final AppDatabase? _db;

  RankingService(this._db);

  final StreamController<int> _totalExplorersController = StreamController<int>.broadcast();
  final StreamController<List<Map<String, dynamic>>> _memoryRankingController = StreamController<List<Map<String, dynamic>>>.broadcast();
  List<Map<String, dynamic>> _lastRankingData = [];

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
        'stars': (totalPoints / 250).floor(),
        'lastUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Atualiza o cache local de memória para refletir na UI imediatamente (especialmente no Web)
      final index = _lastRankingData.indexWhere((item) => item['profileUid'] == profile.uid);
      final updatedItem = {
        'profileUid': profile.uid,
        'parentUid': user.uid,
        'name': profile.nome,
        'avatarPath': profile.avatarAssetPath,
        'totalPoints': totalPoints,
        'lastUpdate': DateTime.now(),
      };
      
      if (index != -1) {
        _lastRankingData[index] = updatedItem;
      } else {
        _lastRankingData.add(updatedItem);
      }
      // Re-ordena o cache por pontos
      _lastRankingData.sort((a, b) => (b['totalPoints'] as int).compareTo(a['totalPoints'] as int));
      _memoryRankingController.add(_lastRankingData);

      if (_db != null) {
        try {
          await _db!.into(_db!.globalRanking).insertOnConflictUpdate(
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
          debugPrint("Erro ao atualizar ranking local (ignorado no web): $e");
        }
      }
    } catch (e) {
      debugPrint("Erro ao atualizar o ranking do perfil: $e");
    }
  }

  Future<void> refreshLocalRankingCache() async {
    final user = _authService.currentUser;
    if (user == null) return; // Permitimos que anónimos (Visitantes) vejam o ranking

    try {
      debugPrint('[RankingService] A carregar ranking do Firestore...');
      final snapshot = await _firestore
          .collection('ranking_global')
          .orderBy('totalPoints', descending: true)
          .limit(100)
          .get();

      final List<Map<String, dynamic>> rankingList = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        DateTime lastUpdate;
        final dynamic rawDate = data['lastUpdate'];
        if (rawDate is Timestamp) {
          lastUpdate = rawDate.toDate();
        } else if (rawDate is String) {
          lastUpdate = DateTime.tryParse(rawDate) ?? DateTime.now();
        } else {
          lastUpdate = DateTime.now();
        }

        rankingList.add({
          'profileUid': data['profileUid'] ?? doc.id,
          'parentUid': data['parentUid'],
          'name': data['name'] ?? 'Explorador',
          'avatarPath': data['avatarPath'] ?? 'assets/avatars/default.png',
          'totalPoints': (data['totalPoints'] ?? 0).toInt(),
          'lastUpdate': lastUpdate,
        });
      }

      _lastRankingData = rankingList;
      _memoryRankingController.add(_lastRankingData);

      if (_db != null) {
        try {
          await _db!.transaction(() async {
            await _db!.delete(_db!.globalRanking).go();
            for (var item in rankingList) {
              await _db!.into(_db!.globalRanking).insertOnConflictUpdate(
                GlobalRankingCompanion.insert(
                  profileUid: item['profileUid'],
                  name: item['name'],
                  avatarPath: item['avatarPath'],
                  totalPoints: item['totalPoints'],
                  lastUpdate: item['lastUpdate'],
                  parentUid: Value(item['parentUid']?.toString()),
                ),
              );
            }
          });
        } catch (e) {
          debugPrint("DB local indisponível no Web, usando apenas memória.");
        }
      }

      final countSnapshot = await _firestore.collection('ranking_global').count().get();
      if (countSnapshot.count != null) {
        final totalCount = countSnapshot.count!.toInt();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('total_explorers_count', totalCount);
        _totalExplorersController.add(totalCount);
      }
      
    } catch (e) {
      debugPrint("Erro ao carregar ranking: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> getLocalRankingStream() async* {
    if (kIsWeb || _db == null) {
      // No Web, emitimos o último cache imediatamente para novos ouvintes
      yield _lastRankingData;
      yield* _memoryRankingController.stream;
    } else {
      yield* (_db!.select(_db!.globalRanking)
            ..orderBy([(t) => OrderingTerm(expression: t.totalPoints, mode: OrderingMode.desc)]))
          .watch()
          .map((rows) {
        if (rows.isEmpty && _lastRankingData.isNotEmpty) return _lastRankingData;
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
  }

  Stream<int> getTotalExplorersStream() async* {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getInt('total_explorers_count');
    if (cached != null) yield cached;
    
    yield* _totalExplorersController.stream;
  }

  void dispose() {
    _totalExplorersController.close();
    _memoryRankingController.close();
  }

  Stream<int> getProfileRankStream(String profileUid) {
    return getLocalRankingStream().map((list) {
      final index = list.indexWhere((item) => item['profileUid'] == profileUid);
      return index == -1 ? 0 : index + 1;
    });
  }

  Future<void> clearTestRankingData() async {
    final bots = ['bot_1', 'bot_2', 'bot_3', 'bot_4'];
    for (var botUid in bots) {
      try {
        await _firestore.collection('ranking_global').doc(botUid).delete();
      } catch (e) {
        debugPrint("Erro ao remover bot: $e");
      }
    }
    await refreshLocalRankingCache();
  }
}
