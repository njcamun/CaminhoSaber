import 'package:drift/drift.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:caminho_do_saber/database/database.dart';
import 'package:flutter/foundation.dart';
import 'package:caminho_do_saber/providers/profile_provider.dart';

class FlashcardService with ChangeNotifier {
  final AppDatabase _db;
  ProfileProvider? _profileProvider;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FlashcardService(this._db, ProfileProvider? profileProvider);

  void updateProvider(ProfileProvider newProvider) {
    _profileProvider = newProvider;
  }

  Future<List<UserFlashcard>> loadFlashcardsForProfile(String profileUid) async {
    final query = _db.select(_db.userFlashcards)..where((t) => t.profileUid.equals(profileUid));
    return await query.get();
  }

  Future<void> addFlashcard({
    required String pergunta,
    required String resposta,
    required String disciplinaId,
    required String profileUid,
    required String parentUid,
  }) async {
    await _db.into(_db.userFlashcards).insert(UserFlashcardsCompanion.insert(
      profileUid: profileUid,
      parentUid: parentUid,
      disciplinaId: disciplinaId,
      pergunta: pergunta,
      resposta: resposta,
      dataCriacao: Value(DateTime.now()),
    ));
    
    notifyListeners();
    syncWithCloud();
  }

  Future<void> updateFlashcard(UserFlashcard flashcard) async {
    await (_db.update(_db.userFlashcards)..where((t) => t.id.equals(flashcard.id))).write(
      UserFlashcardsCompanion(
        pergunta: Value(flashcard.pergunta),
        resposta: Value(flashcard.resposta),
        disciplinaId: Value(flashcard.disciplinaId),
      ),
    );
    
    notifyListeners();
    syncWithCloud();
  }

  Future<void> deleteFlashcard(int id) async {
    await (_db.delete(_db.userFlashcards)..where((t) => t.id.equals(id))).go();
    
    notifyListeners();
    syncWithCloud();
  }

  Future<void> syncWithCloud() async {
    final user = _auth.currentUser;
    final activeProfile = _profileProvider?.activeProfile;
    if (user == null || activeProfile == null || user.isAnonymous) return;

    try {
      final localFlashcards = await loadFlashcardsForProfile(activeProfile.uid);
      final batch = _firestore.batch();
      
      final flashcardsRef = _firestore.collection('users').doc(user.uid).collection('profiles').doc(activeProfile.uid).collection('flashcards');
      
      // Since it's a small list, we can just replace everything or use doc IDs.
      // For now, let's use the drift ID as the doc ID in Firestore.
      
      for (var f in localFlashcards) {
        final docRef = flashcardsRef.doc(f.id.toString());
        batch.set(docRef, {
          'pergunta': f.pergunta,
          'resposta': f.resposta,
          'disciplinaId': f.disciplinaId,
          'dataCriacao': f.dataCriacao,
          'parentUid': f.parentUid,
          'profileUid': f.profileUid,
        }, SetOptions(merge: true));
      }
      
      await batch.commit();
    } catch (e) {
      debugPrint('Flashcard sync error: $e');
    }
  }

  Future<void> restoreFromCloud() async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return;

    try {
      final profilesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profiles')
          .get();

      await _db.transaction(() async {
        for (var profileDoc in profilesSnapshot.docs) {
          final profileUid = profileDoc.id;
          final flashcardsSnapshot = await profileDoc.reference.collection('flashcards').get();
          
          for (var flashDoc in flashcardsSnapshot.docs) {
            final data = flashDoc.data();
            
            // Note: Since IDs might not match exactly or we don't have a unique key other than the content
            // we should probably check if a similar card exists or use a UUID.
            // For now, we'll use a simple check based on content or the original Drift ID.
            
            final existing = await (_db.select(_db.userFlashcards)
                ..where((t) => t.profileUid.equals(profileUid) & t.pergunta.equals(data['pergunta'])))
                .getSingleOrNull();

            if (existing == null) {
              await _db.into(_db.userFlashcards).insert(UserFlashcardsCompanion.insert(
                profileUid: profileUid,
                parentUid: data['parentUid'] ?? user.uid,
                disciplinaId: data['disciplinaId'] ?? 'OUTROS',
                pergunta: data['pergunta'] ?? '',
                resposta: data['resposta'] ?? '',
                dataCriacao: Value((data['dataCriacao'] as Timestamp?)?.toDate() ?? DateTime.now()),
              ));
            }
          }
        }
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Flashcard restore error: $e');
    }
  }
}
