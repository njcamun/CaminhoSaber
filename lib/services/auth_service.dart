// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? _lastAuthError;

  User? get currentUser => _auth.currentUser;
  String? get lastAuthError => _lastAuthError;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Erro no login com e-mail: $e');
      return null;
    }
  }

  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('Erro no login anónimo: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    _lastAuthError = null;
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});
        return await _auth.signInWithPopup(googleProvider);
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // O utilizador cancelou o login
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // On web, browsers may block popups. Redirect is a safe fallback.
      if (kIsWeb && (e.code == 'popup-blocked' || e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request')) {
        try {
          final googleProvider = GoogleAuthProvider()
            ..setCustomParameters({'prompt': 'select_account'});
          await _auth.signInWithRedirect(googleProvider);
          return null;
        } on FirebaseAuthException catch (redirectError) {
          _lastAuthError = '${redirectError.code}: ${redirectError.message ?? 'Erro no login Google.'}';
          debugPrint('Erro no redirect Google: $_lastAuthError');
          return null;
        }
      }

      _lastAuthError = '${e.code}: ${e.message ?? 'Erro no login Google.'}';
      debugPrint('Erro no login com Google: $_lastAuthError');
      return null;
    } catch (e) {
      _lastAuthError = e.toString();
      debugPrint('Erro no login com Google: $_lastAuthError');
      return null;
    }
  }

  Future<UserCredential?> registerWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Erro no registo: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }
}
