// lib/providers/profile_provider.dart

import 'package:flutter/material.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:caminho_do_saber/services/auth_service.dart';
import 'package:caminho_do_saber/database/database.dart';
import 'dart:async';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:caminho_do_saber/services/progresso_service.dart';

class ProfileProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final AppDatabase _db;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _authSubscription;

  ProgressoService? _progressoService;

  Profile? _activeProfile;
  List<Profile> _allProfiles = [];
  bool _isLoading = true;
  bool _isRestoring = false;
  bool _pendingRestore = false;

  Profile? get activeProfile => _activeProfile;
  List<Profile> get allProfiles => _allProfiles;
  bool get isLoading => _isLoading;

  ProfileProvider(this._db) {
    _authSubscription = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void setProgressoService(ProgressoService progressoService) {
    _progressoService = progressoService;
    _tryRestore();
  }

  void _tryRestore() {
    if (_pendingRestore && _progressoService != null) {
      final user = _authService.currentUser;
      if (user != null && !user.isAnonymous) {
        _pendingRestore = false;
        _progressoService!.restoreFromCloud();
      }
    }
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _activeProfile = null;
      _allProfiles = [];
      _isLoading = false;
      _pendingRestore = false;
      notifyListeners();
    } else {
      if (firebaseUser.isAnonymous) {
        _isLoading = true;
        _pendingRestore = false;
        notifyListeners();

        final tempProfile = Profile(
          id: -1,
          uid: firebaseUser.uid,
          parentUid: firebaseUser.uid,
          nome: 'Visitante',
          avatarAssetPath: 'assets/avatars/default.png',
          isMainProfile: true,
          totalPontos: 0,
          totalDiamantes: 0,
          currentStreak: 0,
        );

        _activeProfile = tempProfile;
        _allProfiles = [tempProfile];
        _isLoading = false;
        notifyListeners();
      } else {
        await _loadProfilesForUser(firebaseUser);
      }
    }
  }

  String _validateAvatarPath(String? path) {
    if (path == null || path.isEmpty) return 'assets/avatars/default.png';
    if (path.startsWith('assets/')) return path;
    
    final file = File(path);
    if (file.existsSync()) {
      return path;
    }
    
    return 'assets/avatars/default.png';
  }

  Future<void> _loadProfilesForUser(User firebaseUser) async {
    if (_isRestoring) return;
    _isRestoring = true;
    
    _isLoading = true;
    notifyListeners();

    try {
      if (!firebaseUser.isAnonymous) {
        _pendingRestore = true;
        try {
          final querySnapshot = await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .collection('profiles')
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            await _db.transaction(() async {
              for (var doc in querySnapshot.docs) {
                final data = doc.data();
                final pUid = doc.id;

                final companion = ProfilesCompanion.insert(
                  uid: pUid,
                  parentUid: firebaseUser.uid,
                  nome: data['nome'] ?? 'Perfil',
                  avatarAssetPath: _validateAvatarPath(data['avatarAssetPath']),
                  isMainProfile: data['isMainProfile'] ?? (pUid == firebaseUser.uid),
                  totalPontos: Value(data['totalPontos'] ?? 0),
                  totalDiamantes: Value(data['totalDiamantes'] ?? 0),
                  currentStreak: Value(data['currentStreak'] ?? 0),
                );

                final existing = await (_db.select(_db.profiles)..where((t) => t.uid.equals(pUid))).getSingleOrNull();
                if (existing != null) {
                  await (_db.update(_db.profiles)..where((t) => t.uid.equals(pUid))).write(companion);
                } else {
                  await _db.into(_db.profiles).insert(companion);
                }
              }
            });
            // O restauro do progresso é agora gerido pelo _tryRestore
          }
        } catch (e) {
          debugPrint('Erro Cloud Sync Perfis: $e');
        }
      }

      final query = _db.select(_db.profiles)..where((t) => t.parentUid.equals(firebaseUser.uid));
      _allProfiles = await query.get();

      if (_allProfiles.isEmpty) {
        String defaultName = firebaseUser.displayName ?? 
                            (firebaseUser.email != null ? firebaseUser.email!.split('@').first : 'Utilizador');
        
        await _db.into(_db.profiles).insert(ProfilesCompanion.insert(
          uid: firebaseUser.uid,
          parentUid: firebaseUser.uid,
          nome: defaultName,
          avatarAssetPath: 'assets/avatars/default.png',
          isMainProfile: true,
        ));
        
        _allProfiles = await query.get();
      }

      if (_activeProfile != null) {
        _activeProfile = _allProfiles.cast<Profile?>().firstWhere(
          (p) => p?.uid == _activeProfile!.uid,
          orElse: () => _allProfiles.firstWhere((p) => p.isMainProfile),
        );
      } else {
        _activeProfile = _allProfiles.firstWhere((p) => p.isMainProfile);
      }
    } finally {
      _isLoading = false;
      _isRestoring = false;
      notifyListeners();
      _tryRestore();
    }
  }

  void setActiveProfile(Profile newProfile) {
    if (_activeProfile?.uid != newProfile.uid) {
      _activeProfile = newProfile;
      notifyListeners();
    }
  }

  /// Recarrega o perfil ativo do banco de dados para garantir que pontos/diamantes/streak
  /// estejam atualizados após operações do ProgressoService.
  Future<void> refreshActiveProfile() async {
    if (_activeProfile == null) return;
    
    final query = _db.select(_db.profiles)..where((t) => t.uid.equals(_activeProfile!.uid));
    final updatedProfile = await query.getSingleOrNull();
    
    if (updatedProfile != null) {
      _activeProfile = updatedProfile;
      // Também atualizamos a lista de todos os perfis para manter a consistência
      final index = _allProfiles.indexWhere((p) => p.uid == updatedProfile.uid);
      if (index != -1) {
        _allProfiles[index] = updatedProfile;
      }
      notifyListeners();
    }
  }

  Future<void> addDependent({required String nome, required String avatarAssetPath}) async {
    final parent = _allProfiles.firstWhere((p) => p.isMainProfile);

    await _db.into(_db.profiles).insert(ProfilesCompanion.insert(
      uid: const Uuid().v4(),
      parentUid: parent.parentUid,
      nome: nome,
      avatarAssetPath: avatarAssetPath,
      isMainProfile: false,
    ));

    await _loadProfilesForUser(_authService.currentUser!);
    await _progressoService?.syncWithCloud(); // Sincroniza a criação do dependente
  }

  Future<void> editDependent({
    required String profileUid,
    required String newName,
    required String newAvatarPath,
  }) async {
    await (_db.update(_db.profiles)..where((t) => t.uid.equals(profileUid))).write(
      ProfilesCompanion(
        nome: Value(newName),
        avatarAssetPath: Value(newAvatarPath),
      ),
    );
    
    await _loadProfilesForUser(_authService.currentUser!);
    await _progressoService?.syncWithCloud(); // Sincroniza a criação do dependente
  }

  Future<void> removeDependent(String profileUid) async {
    if (_activeProfile?.uid == profileUid) {
      final mainProfile = _allProfiles.firstWhere((p) => p.isMainProfile);
      setActiveProfile(mainProfile);
    }

    await (_db.delete(_db.profiles)..where((t) => t.uid.equals(profileUid))).go();

    await _progressoService?.removeProgressForProfile(profileUid);

    await _loadProfilesForUser(_authService.currentUser!);
    await _progressoService?.syncWithCloud(); // Sincroniza a criação do dependente
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
