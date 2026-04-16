import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:caminho_do_saber/database/database.dart';
import 'package:caminho_do_saber/providers/profile_provider.dart';
import 'package:caminho_do_saber/services/ranking_service.dart';
import 'dart:async';
import 'dart:math';

class ProgressoService with ChangeNotifier {
  final AppDatabase _db;
  ProfileProvider? _profileProvider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final RankingService _rankingService;

  int _totalXP = 0;
  int _totalDiamantes = 0;
  int _currentStreak = 0;
  final Map<String, int> _progressoPorCapitulo = {};
  final Map<String, List<Map<String, dynamic>>> _cloudProgressCache = {};
  final Map<String, Map<String, dynamic>> _cloudProfileCache = {};

  int get totalXP => _totalXP;
  int get totalStarsTotal => (_totalXP / 250).floor();
  int get totalStarsDisplay => totalStarsTotal % 50;
  int get totalPontos => totalStarsTotal; // Para compatibilidade com níveis
  int get totalDiamantes => _totalDiamantes;
  int get currentStreak => _currentStreak;
  Map<String, int> get progressoPorCapitulo => _progressoPorCapitulo;

  String getLevelName(int totalStars) {
    if (totalStars < 500) return 'Iniciante';
    if (totalStars < 1000) return 'Aprendiz';
    if (totalStars < 3000) return 'Aventureiro';
    if (totalStars < 6000) return 'Explorador';
    return 'Mestre do Saber';
  }

  double getNextLevelXP(int currentStars) {
    if (currentStars < 500) return 500;
    if (currentStars < 1000) return 1000;
    if (currentStars < 3000) return 3000;
    if (currentStars < 6000) return 6000;
    return (currentStars + 1000).toDouble();
  }

  ProgressoService(this._db, ProfileProvider? profileProvider) {
    _rankingService = RankingService(_db);
    if (profileProvider != null) {
      updateProvider(profileProvider);
    }
  }

  void updateProvider(ProfileProvider newProvider) {
    _profileProvider?.removeListener(_onProfileChanged);
    _profileProvider = newProvider;
    _profileProvider?.addListener(_onProfileChanged);
    _loadProgresso();
  }

  void _onProfileChanged() {
    _loadProgresso();
  }

  Future<void> _loadProgresso() async {
    final activeProfile = _profileProvider?.activeProfile;
    if (activeProfile == null) {
      _progressoPorCapitulo.clear();
      _totalXP = 0;
      _totalDiamantes = 0;
      _currentStreak = 0;
      Future.microtask(() => notifyListeners());
      return;
    }

    final activeProfileUid = activeProfile.uid;

    List<ProgressoCapitulo> todosProgressos = [];
    try {
      final query = _db.select(_db.progressoCapitulos)..where((t) => t.profileUid.equals(activeProfileUid));
      todosProgressos = await query.get();
    } catch (dbError) {
      debugPrint('[ProgressoService] _loadProgresso local DB failed: $dbError');
      _applyCloudFallbackForActiveProfile();
      return;
    }

    // On web, DB can be unavailable or empty. If we already restored from Firestore,
    // apply the cached cloud data directly to keep UI synced.
    if (todosProgressos.isEmpty && _cloudProgressCache.containsKey(activeProfileUid)) {
      _applyCloudFallbackForActiveProfile();
      return;
    }

    _progressoPorCapitulo.clear();
    int xpSoma = 0;
    int diamantesSoma = 0;

    for (var progresso in todosProgressos) {
      final tipo = progresso.tipo ?? 'quiz';

      if (tipo == 'leitura' || tipo == 'quiz' || tipo == 'arcade' || tipo == 'challenge' || tipo == 'bonus') {
         // Acumula o XP bruto de todas as atividades
         xpSoma += progresso.pontuacao;

         if (tipo == 'leitura' || tipo == 'quiz') {
           _progressoPorCapitulo[progresso.capituloId] = progresso.pontuacao;
         }
      }

      if (tipo == 'achievement' || tipo == 'payment') {
        diamantesSoma += progresso.pontuacao;
      }
    }

    _totalXP = xpSoma;

    // Regra: 250 XP = 1 Estrela
    // Regra: 50 Estrelas = 1 Diamante
    int totalEstrelasGerais = (_totalXP / 250).floor();
    int diamantesPorEstrelas = (totalEstrelasGerais / 50).floor();

    _totalDiamantes = diamantesPorEstrelas + diamantesSoma;

    await _updateAndLoadStreak();

    if (activeProfile.totalPontos != totalPontos ||
        activeProfile.totalDiamantes != _totalDiamantes ||
        activeProfile.currentStreak != _currentStreak) {
      
      try {
        await (_db.update(_db.profiles)..where((t) => t.uid.equals(activeProfile.uid))).write(
          ProfilesCompanion(
            totalPontos: Value(totalPontos),
            totalDiamantes: Value(_totalDiamantes),
            currentStreak: Value(_currentStreak),
          ),
        );
      } catch (e) {
        debugPrint('[ProgressoService] Erro ao atualizar perfil local: $e');
      }
    }

    // IMPORTANTE: Removemos o refreshActiveProfile() daqui para quebrar o loop circular.
    // O UI já usa Consumer2<ProfileProvider, ProgressoService> e terá os dados atualizados.
    Future.microtask(() => notifyListeners());
    // Removido syncWithCloud daqui para evitar loop de atualização.
    // O syncWithCloud deve ser chamado apenas após alterações locais.
  }

  void _applyCloudFallbackForActiveProfile() {
    final activeProfile = _profileProvider?.activeProfile;
    if (activeProfile == null) return;

    final profileUid = activeProfile.uid;
    final cloudEntries = _cloudProgressCache[profileUid] ?? const [];
    final cloudProfile = _cloudProfileCache[profileUid] ?? const {};

    _progressoPorCapitulo.clear();
    int xpSoma = 0;
    int diamantesSoma = 0;

    for (final entry in cloudEntries) {
      final tipo = (entry['tipo'] ?? 'quiz').toString();
      final capituloId = (entry['capituloId'] ?? '').toString();
      final pontuacao = (entry['pontuacao'] as num?)?.toInt() ?? 0;

      if (tipo == 'leitura' || tipo == 'quiz' || tipo == 'arcade' || tipo == 'challenge' || tipo == 'bonus') {
        xpSoma += pontuacao;
        if ((tipo == 'leitura' || tipo == 'quiz') && capituloId.isNotEmpty) {
          _progressoPorCapitulo[capituloId] = pontuacao;
        }
      }

      if (tipo == 'achievement' || tipo == 'payment') {
        diamantesSoma += pontuacao;
      }
    }

    _totalXP = (cloudProfile['totalXP'] as num?)?.toInt() ?? xpSoma;
    final totalEstrelasGerais = (_totalXP / 250).floor();
    final diamantesPorEstrelas = (totalEstrelasGerais / 50).floor();
    _totalDiamantes = (cloudProfile['totalDiamantes'] as num?)?.toInt() ?? (diamantesPorEstrelas + diamantesSoma);
    _currentStreak = (cloudProfile['currentStreak'] as num?)?.toInt() ?? 0;

    Future.microtask(() => notifyListeners());
  }

  Future<void> _updateAndLoadStreak() async {
    if (_profileProvider?.activeProfile == null) return;
    final uid = _profileProvider!.activeProfile!.uid;

    final stats = await (_db.select(_db.userStatsTable)..where((t) => t.profileUid.equals(uid))).getSingleOrNull();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (stats == null) {
      await _db.into(_db.userStatsTable).insert(UserStatsTableCompanion.insert(
        profileUid: uid,
        lastActivityDate: today,
        currentStreak: const Value(0),
      ));
      _currentStreak = 0;
    } else {
      final lastDate = DateTime(stats.lastActivityDate.year, stats.lastActivityDate.month, stats.lastActivityDate.day);
      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        _currentStreak = stats.currentStreak;
      } else if (difference > 1) {
        await (_db.update(_db.userStatsTable)..where((t) => t.profileUid.equals(uid))).write(
          const UserStatsTableCompanion(currentStreak: Value(0)),
        );
        _currentStreak = 0;
      } else {
        _currentStreak = stats.currentStreak;
      }
    }
  }

  Future<void> saveProgresso(String capituloId, int novaPontuacao, {String tipo = 'quiz'}) async {
    if (_profileProvider?.activeProfile == null) return;
    final activeProfileUid = _profileProvider!.activeProfile!.uid;
    
    try {
      await Future<void>(() async {
        final progressoExistente = await (_db.select(_db.progressoCapitulos)
          ..where((t) => t.profileUid.equals(activeProfileUid) & t.capituloId.equals(capituloId)))
          .getSingleOrNull();

        if (tipo == 'payment' || progressoExistente == null || (tipo != 'payment' && novaPontuacao > progressoExistente.pontuacao)) {
          await _db.transaction(() async {
            if (tipo == 'payment') {
              await _db.into(_db.progressoCapitulos).insert(ProgressoCapitulosCompanion.insert(
                capituloId: '${capituloId}_${DateTime.now().millisecondsSinceEpoch}',
                pontuacao: novaPontuacao,
                dataConclusao: DateTime.now(),
                profileUid: activeProfileUid,
                tipo: Value(tipo),
              ));
            } else if (progressoExistente == null) {
              await _db.into(_db.progressoCapitulos).insert(ProgressoCapitulosCompanion.insert(
                capituloId: capituloId,
                pontuacao: novaPontuacao,
                dataConclusao: DateTime.now(),
                profileUid: activeProfileUid,
                tipo: Value(tipo),
              ));
            } else {
              await (_db.update(_db.progressoCapitulos)
                ..where((t) => t.id.equals(progressoExistente.id)))
                .write(ProgressoCapitulosCompanion(
                  pontuacao: Value(novaPontuacao),
                  dataConclusao: Value(DateTime.now()),
                ));
            }
            
            if (tipo == 'quiz' || tipo == 'leitura') {
              final stats = await (_db.select(_db.userStatsTable)..where((t) => t.profileUid.equals(activeProfileUid))).getSingleOrNull();
              final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
              
              if (stats != null) {
                final lastDate = DateTime(stats.lastActivityDate.year, stats.lastActivityDate.month, stats.lastActivityDate.day);
                if (today.difference(lastDate).inDays == 1) {
                  int newStreak = stats.currentStreak + 1;
                  int newHighest = max(newStreak, stats.highestStreak);
                  await (_db.update(_db.userStatsTable)..where((t) => t.profileUid.equals(activeProfileUid))).write(
                    UserStatsTableCompanion(
                      currentStreak: Value(newStreak),
                      lastActivityDate: Value(today),
                      highestStreak: Value(newHighest),
                    ),
                  );

                  // Bónus: A cada 6 dias consecutivos, ganha 500 XP
                  if (newStreak % 6 == 0) {
                    await _db.into(_db.progressoCapitulos).insert(ProgressoCapitulosCompanion.insert(
                      capituloId: 'bonus_streak_${newStreak}_${today.millisecondsSinceEpoch}',
                      pontuacao: 500,
                      dataConclusao: DateTime.now(),
                      profileUid: activeProfileUid,
                      tipo: const Value('bonus'),
                    ));
                  }
                } else if (today.difference(lastDate).inDays > 1 || stats.currentStreak == 0) {
                  await (_db.update(_db.userStatsTable)..where((t) => t.profileUid.equals(activeProfileUid))).write(
                    UserStatsTableCompanion(
                      currentStreak: const Value(1),
                      lastActivityDate: Value(today),
                    ),
                  );
                }
              } else {
                await _db.into(_db.userStatsTable).insert(UserStatsTableCompanion.insert(
                  profileUid: activeProfileUid,
                  currentStreak: const Value(1),
                  lastActivityDate: today,
                ));
              }
            }
          });
          await _loadProgresso();
          
          // Sincroniza com o ranking global (Atualiza local imediatamente e cloud se logado)
          final updatedProfile = _profileProvider?.activeProfile;
          if (updatedProfile != null) {
            await _rankingService.updateProfileRanking(updatedProfile, totalPontos);
          }

          await syncWithCloud(); // Sincroniza logo após salvar localmente
        }
      }).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('[ProgressoService] Error saving progresso: $e');
      _progressoPorCapitulo[capituloId] = max(_progressoPorCapitulo[capituloId] ?? 0, novaPontuacao);
      _totalXP += novaPontuacao;
      notifyListeners();
    }
  }

  Future<void> restoreFromCloud() async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return;
    debugPrint('[ProgressoService] Starting restoreFromCloud for UID: ${user.uid}');

    try {
      final profilesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profiles')
          .get();
      debugPrint('[ProgressoService] Found ${profilesSnapshot.docs.length} profiles in Firestore');

      final Map<String, List<Map<String, dynamic>>> fetchedProgress = {};
      final Map<String, Map<String, dynamic>> fetchedProfiles = {};

      for (var profileDoc in profilesSnapshot.docs) {
        final profileUid = profileDoc.id;
        final profileData = profileDoc.data();
        fetchedProfiles[profileUid] = profileData;

        final progressoSnapshot = await profileDoc.reference.collection('progresso').get();
        fetchedProgress[profileUid] = progressoSnapshot.docs.map((progDoc) {
          final data = progDoc.data();
          final capituloId = (data['capituloId'] ?? progDoc.id).toString();
          return {
            'capituloId': capituloId,
            'pontuacao': (data['pontuacao'] as num?)?.toInt() ?? 0,
            'tipo': (data['tipo'] ?? 'quiz').toString(),
            'dataConclusao': data['dataConclusao'],
          };
        }).toList();
      }

      _cloudProgressCache
        ..clear()
        ..addAll(fetchedProgress);
      _cloudProfileCache
        ..clear()
        ..addAll(fetchedProfiles);

      if (kIsWeb) {
        _applyCloudFallbackForActiveProfile();
        debugPrint('[ProgressoService] restoreFromCloud completed (web cloud-only mode)');
        return;
      }

      try {
        await _db.transaction(() async {
          for (var profileDoc in profilesSnapshot.docs) {
            final profileUid = profileDoc.id;
            
            final profileData = profileDoc.data();
            if (profileData.containsKey('currentStreak')) {
              final existingStats = await (_db.select(_db.userStatsTable)..where((t) => t.profileUid.equals(profileUid))).getSingleOrNull();
              if (existingStats == null) {
                await _db.into(_db.userStatsTable).insert(UserStatsTableCompanion.insert(
                  profileUid: profileUid, 
                  lastActivityDate: DateTime.now(),
                  currentStreak: Value(profileData['currentStreak'] ?? 0),
                  highestStreak: Value(profileData['highestStreak'] ?? 0),
                ));
              }
            }

            final progressoSnapshot = await profileDoc.reference.collection('progresso').get();
            for (var progDoc in progressoSnapshot.docs) {
              final data = progDoc.data();
              final capituloId = (data['capituloId'] ?? progDoc.id).toString();
              
              final existing = await (_db.select(_db.progressoCapitulos)
                  ..where((t) => t.profileUid.equals(profileUid) & t.capituloId.equals(capituloId)))
                  .getSingleOrNull();

              final cloudPontuacao = data['pontuacao'] ?? 0;

              if (existing == null) {
                await _db.into(_db.progressoCapitulos).insert(ProgressoCapitulosCompanion.insert(
                  capituloId: capituloId,
                  profileUid: profileUid,
                  pontuacao: cloudPontuacao,
                  tipo: Value(data['tipo'] ?? 'quiz'),
                  dataConclusao: (data['dataConclusao'] as Timestamp?)?.toDate() ?? DateTime.now(),
                ));
              } else if (existing.pontuacao < cloudPontuacao) {
                await (_db.update(_db.progressoCapitulos)..where((t) => t.id.equals(existing.id))).write(
                  ProgressoCapitulosCompanion(
                    pontuacao: Value(cloudPontuacao),
                    tipo: Value(data['tipo'] ?? 'quiz'),
                    dataConclusao: Value((data['dataConclusao'] as Timestamp?)?.toDate() ?? DateTime.now()),
                  ),
                );
              }
            }
          }
        });
        debugPrint('[ProgressoService] Progress persisted to local DB');
      } catch (dbError) {
        debugPrint('[ProgressoService] Local DB persistence failed: $dbError, using Firestore data only');
        _applyCloudFallbackForActiveProfile();
        return;
      }
      
      await _loadProgresso();
      debugPrint('[ProgressoService] restoreFromCloud completed successfully');
    } catch (e) {
      debugPrint('[ProgressoService] Erro ao restaurar progresso da cloud: $e');
    }
  }

  Future<void> syncWithCloud() async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return;

    try {
      // 1. Sincroniza o documento do utilizador (Parent)
      await _firestore.collection('users').doc(user.uid).set({
        'lastSync': FieldValue.serverTimestamp(),
        'email': user.email,
      }, SetOptions(merge: true));

      // 2. Sincroniza TODOS os perfis locais
      final allLocalProfiles = await _db.select(_db.profiles).get();
      debugPrint('[ProgressoService] Iniciando sync massivo para ${allLocalProfiles.length} perfis');

      for (final profile in allLocalProfiles) {
        final localProgressos = await (_db.select(_db.progressoCapitulos)
          ..where((t) => t.profileUid.equals(profile.uid))).get();

        // Limita o batch por perfil para segurança
        final batch = _firestore.batch();
        
        for (var p in localProgressos) {
          final docRef = _firestore
              .collection('users').doc(user.uid)
              .collection('profiles').doc(profile.uid)
              .collection('progresso').doc(p.capituloId);
          
          batch.set(docRef, {
            'pontuacao': p.pontuacao,
            'dataConclusao': p.dataConclusao,
            'capituloId': p.capituloId,
            'tipo': p.tipo
          }, SetOptions(merge: true));
        }

        final profileRef = _firestore
            .collection('users').doc(user.uid)
            .collection('profiles').doc(profile.uid);
            
        batch.set(profileRef, {
          'uid': profile.uid,
          'totalPontos': profile.totalPontos,
          'totalDiamantes': profile.totalDiamantes,
          'currentStreak': profile.currentStreak,
          'nome': profile.nome,
          'lastSync': FieldValue.serverTimestamp(),
          'avatarAssetPath': profile.avatarAssetPath
        }, SetOptions(merge: true));

        await batch.commit().timeout(const Duration(seconds: 10));
        
        // Sincroniza com o ranking global (essencial para listar todos os perfis)
        await _rankingService.updateProfileRanking(profile, profile.totalPontos);
      }
      debugPrint('[ProgressoService] Sync massivo concluído com sucesso');
    } catch (e) {
      debugPrint('SyncCloud Multi-Profile Erro: $e');
    }
  }

  Future<void> removeProgressForProfile(String profileUid) async {
    await (_db.delete(_db.progressoCapitulos)..where((t) => t.profileUid.equals(profileUid))).go();
    await (_db.delete(_db.userStatsTable)..where((t) => t.profileUid.equals(profileUid))).go();
    
    final user = _auth.currentUser;
    if (user != null && !user.isAnonymous) {
      try {
        final batch = _firestore.batch();
        final progressSnapshot = await _firestore.collection('users').doc(user.uid).collection('profiles').doc(profileUid).collection('progresso').get();
        for (var doc in progressSnapshot.docs) { batch.delete(doc.reference); }
        batch.delete(_firestore.collection('users').doc(user.uid).collection('profiles').doc(profileUid));
        batch.delete(_firestore.collection('ranking_global').doc(profileUid));
        await batch.commit();
      } catch (e) { debugPrint('Erro Sync Delete: $e'); }
    }
    await _loadProgresso();
  }

  bool isCapituloConcluido(String capituloId) => _progressoPorCapitulo.containsKey(capituloId);

  Future<Map<String, int>> getProgresso(String disciplinaId) async {
    if (_profileProvider?.activeProfile == null) return {};
    if (kIsWeb) {
      return Map<String, int>.fromEntries(
        _progressoPorCapitulo.entries.where((e) => e.key.startsWith(disciplinaId)),
      );
    }

    final activeProfileUid = _profileProvider!.activeProfile!.uid;

    try {
      final query = _db.select(_db.progressoCapitulos)
        ..where((t) => t.profileUid.equals(activeProfileUid) & t.capituloId.like('$disciplinaId%'));
      final progressos = await query.get();

      final Map<String, int> progressoMap = {};
      for (var p in progressos) {
        progressoMap[p.capituloId] = p.pontuacao;
      }
      return progressoMap;
    } catch (_) {
      return Map<String, int>.fromEntries(
        _progressoPorCapitulo.entries.where((e) => e.key.startsWith(disciplinaId)),
      );
    }
  }

  int countSpecialAchievements(String type) {
    return _progressoPorCapitulo.keys
        .where((id) => id.startsWith('achievement_$type'))
        .length;
  }

  Future<void> registerSpecialAchievement(String type) async {
    if (_profileProvider?.activeProfile == null) return;
    final achievementId = 'achievement_${type}_${DateTime.now().millisecondsSinceEpoch}';
    await saveProgresso(achievementId, 5, tipo: 'achievement');
  }

  Future<void> addArcadePoints(int pontosGanhos) async {
    if (_profileProvider?.activeProfile == null || pontosGanhos <= 0) return;
    final arcadeId = 'arcade_session_${DateTime.now().millisecondsSinceEpoch}';
    await saveProgresso(arcadeId, pontosGanhos, tipo: 'arcade');
  }

  Future<bool> updateArcadeRecord(String disciplinaId, int novaPontuacao) async {
    if (_profileProvider?.activeProfile == null) return false;
    final recordId = 'arcade_pb_$disciplinaId';
    // Usamos um tipo diferente para o recorde pessoal para não duplicar XP
    await saveProgresso(recordId, novaPontuacao, tipo: 'arcade_record');
    return true;
  }

  int getProgressoQuizzes(String disciplinaId) {
    return _progressoPorCapitulo.keys
        .where((id) => id.startsWith('${disciplinaId}_') && id.contains('_capitulo_'))
        .length;
  }

  int getProgressoLeituras(String disciplinaId) {
    return _progressoPorCapitulo.keys
        .where((id) => id.startsWith('${disciplinaId}_') && !id.contains('_capitulo_') && !id.contains('arcade'))
        .length;
  }

  int getProgressoDisciplina(String disciplinaId) {
    return _progressoPorCapitulo.keys
        .where((id) => id.startsWith('${disciplinaId}_capitulo_'))
        .length;
  }

  @override
  void dispose() {
    _profileProvider?.removeListener(_onProfileChanged);
    super.dispose();
  }
}
