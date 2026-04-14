// lib/providers/profile_provider.dart

import 'package:flutter/foundation.dart';
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
  bool get pendingRestore => _pendingRestore;

  void markRestoreDone() => _pendingRestore = false;

  ProfileProvider(this._db) {
    _authSubscription = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void setProgressoService(ProgressoService progressoService) {
    if (_progressoService == progressoService) return;
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

    // Web does not support dart:io file checks.
    if (kIsWeb) return 'assets/avatars/default.png';

    try {
      final file = File(path);
      if (file.existsSync()) {
        return path;
      }
    } catch (_) {
      return 'assets/avatars/default.png';
    }
    
    return 'assets/avatars/default.png';
  }

  Future<void> _loadProfilesForUser(User firebaseUser) async {
    if (_isRestoring) return;
    _isRestoring = true;
    
    _isLoading = true;
    notifyListeners();
    debugPrint('[ProfileProvider] _loadProfilesForUser called for UID: ${firebaseUser.uid}');

    try {
      if (!firebaseUser.isAnonymous) {
        _pendingRestore = true;
        try {
          debugPrint('[ProfileProvider] Attempting to load profiles from Firestore for ${firebaseUser.uid}');
          final querySnapshot = await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .collection('profiles')
              .get();

          debugPrint('[ProfileProvider] Firestore profiles found: ${querySnapshot.docs.length}');
          if (kIsWeb) {
            _allProfiles = querySnapshot.docs.map((doc) {
              try {
                final data = doc.data();
                return Profile(
                  id: -1,
                  uid: doc.id,
                  parentUid: firebaseUser.uid,
                  nome: (data['nome'] as String?) ?? 'Perfil',
                  avatarAssetPath: _validateAvatarPath(data['avatarAssetPath'] as String?),
                  isMainProfile: (data['isMainProfile'] as bool?) ?? (doc.id == firebaseUser.uid),
                  totalPontos: (data['totalPontos'] as num?)?.toInt() ?? 0,
                  totalDiamantes: (data['totalDiamantes'] as num?)?.toInt() ?? 0,
                  currentStreak: (data['currentStreak'] as num?)?.toInt() ?? 0,
                );
              } catch (e) {
                debugPrint('Error parsing profile ${doc.id}: $e');
                return Profile(
                  id: -1,
                  uid: doc.id,
                  parentUid: firebaseUser.uid,
                  nome: 'Erro Perfil',
                  avatarAssetPath: 'assets/avatars/default.png',
                  isMainProfile: false,
                  totalPontos: 0,
                  totalDiamantes: 0,
                  currentStreak: 0,
                );
              }
            }).toList();

            if (_allProfiles.isEmpty) {
              final defaultName = firebaseUser.displayName ??
                  (firebaseUser.email != null ? firebaseUser.email!.split('@').first : 'Utilizador');
              _allProfiles = [
                Profile(
                  id: -1,
                  uid: firebaseUser.uid,
                  parentUid: firebaseUser.uid,
                  nome: defaultName,
                  avatarAssetPath: 'assets/avatars/default.png',
                  isMainProfile: true,
                  totalPontos: 0,
                  totalDiamantes: 0,
                  currentStreak: 0,
                )
              ];
            }

            _activeProfile = _allProfiles.firstWhere(
              (p) => p.isMainProfile,
              orElse: () => _allProfiles.first,
            );

            _isLoading = false;
            _isRestoring = false;
            notifyListeners();
            _tryRestore();
            return;
          }

          if (querySnapshot.docs.isNotEmpty) {
            try {
              // Try to persist to local database
              await _db.transaction(() async {
                for (var doc in querySnapshot.docs) {
                  final data = doc.data();
                  final pUid = doc.id;

                  final companion = ProfilesCompanion.insert(
                    uid: pUid,
                    parentUid: firebaseUser.uid,
                    nome: data['nome'] ?? 'Perfil',
                    avatarAssetPath: _validateAvatarPath(data['avatarAssetPath'] as String?),
                    isMainProfile: (data['isMainProfile'] as bool?) ?? (pUid == firebaseUser.uid),
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
              debugPrint('[ProfileProvider] Profiles persisted to local DB');
            } catch (dbError) {
              debugPrint('[ProfileProvider] Local DB persistence failed: $dbError, loading from Firestore only');
              // On web or if DB fails, load profiles from Firestore directly into memory
              _allProfiles = querySnapshot.docs.map((doc) {
                final data = doc.data();
                return Profile(
                  id: -1,
                  uid: doc.id,
                  parentUid: firebaseUser.uid,
                  nome: (data['nome'] as String?) ?? 'Perfil',
                  avatarAssetPath: _validateAvatarPath(data['avatarAssetPath'] as String?),
                  isMainProfile: (data['isMainProfile'] as bool?) ?? (doc.id == firebaseUser.uid),
                  totalPontos: (data['totalPontos'] as num?)?.toInt() ?? 0,
                  totalDiamantes: (data['totalDiamantes'] as num?)?.toInt() ?? 0,
                  currentStreak: (data['currentStreak'] as num?)?.toInt() ?? 0,
                );
              }).toList();
              debugPrint('[ProfileProvider] Loaded ${_allProfiles.length} profiles from Firestore into memory');
              if (_activeProfile == null && _allProfiles.isNotEmpty) {
                _activeProfile = _allProfiles.firstWhere((p) => p.isMainProfile, orElse: () => _allProfiles.first);
              }
              _isLoading = false;
              _isRestoring = false;
              notifyListeners();
              _tryRestore();
              return;
            }
          }
        } catch (e) {
          debugPrint('[ProfileProvider] Erro Cloud Sync Perfis: $e');
        }
      }

      try {
        final query = _db.select(_db.profiles)..where((t) => t.parentUid.equals(firebaseUser.uid));
        _allProfiles = await query.get();
        debugPrint('[ProfileProvider] Local DB profiles loaded: ${_allProfiles.length}');
      } catch (dbError) {
        debugPrint('[ProfileProvider] Failed to load from local DB: $dbError');
        _allProfiles = [];
      }

      if (_allProfiles.isEmpty) {
        String defaultName = firebaseUser.displayName ?? 
                            (firebaseUser.email != null ? firebaseUser.email!.split('@').first : 'Utilizador');
        debugPrint('[ProfileProvider] Creating default profile for: $defaultName');
        
        try {
          await _db.into(_db.profiles).insert(ProfilesCompanion.insert(
            uid: firebaseUser.uid,
            parentUid: firebaseUser.uid,
            nome: defaultName,
            avatarAssetPath: 'assets/avatars/default.png',
            isMainProfile: true,
          ));
          
          final query = _db.select(_db.profiles)..where((t) => t.parentUid.equals(firebaseUser.uid));
          _allProfiles = await query.get();
          debugPrint('[ProfileProvider] Default profile created. Profiles now: ${_allProfiles.length}');
        } catch (dbError) {
          debugPrint('[ProfileProvider] Could not create profile in DB: $dbError');
          // Create profile in-memory if DB fails
          _allProfiles = [Profile(
            id: -1,
            uid: firebaseUser.uid,
            parentUid: firebaseUser.uid,
            nome: defaultName,
            avatarAssetPath: 'assets/avatars/default.png',
            isMainProfile: true,
            totalPontos: 0,
            totalDiamantes: 0,
            currentStreak: 0,
          )];
        }
      }

      if (_activeProfile != null) {
        _activeProfile = _allProfiles.cast<Profile?>().firstWhere(
          (p) => p?.uid == _activeProfile!.uid,
          orElse: () => _allProfiles.firstWhere((p) => p.isMainProfile, orElse: () => _allProfiles.first),
        );
      } else {
        _activeProfile = _allProfiles.firstWhere((p) => p.isMainProfile, orElse: () => _allProfiles.first);
      }
    } finally {
      _isLoading = false;
      _isRestoring = false;
      notifyListeners();
      debugPrint('[ProfileProvider] _loadProfilesForUser finished. Active profile: ${_activeProfile?.nome}');
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
