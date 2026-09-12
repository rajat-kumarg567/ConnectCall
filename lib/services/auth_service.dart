import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Handles sign up, login, logout and online-status bookkeeping.
/// Exposed as a ChangeNotifier so the UI can react to auth-state changes.
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register a new account and create the matching Firestore user doc.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;
    await _db.collection(AppConstants.usersCollection).doc(uid).set(
          UserModel(uid: uid, name: name.trim(), email: email.trim(), isOnline: true)
              .toMap(),
        );
    await credential.user!.updateDisplayName(name.trim());
  }

  Future<void> login({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _setOnline(credential.user!.uid, true);
  }

  Future<void> logout() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) await _setOnline(uid, false);
    await _auth.signOut();
  }

  Future<void> _setOnline(String uid, bool online) async {
    await _db.collection(AppConstants.usersCollection).doc(uid).set(
      {'isOnline': online, 'lastSeen': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  /// Call when the app resumes/pauses to keep online status accurate.
  Future<void> updatePresence(bool online) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) await _setOnline(uid, online);
  }

  /// Friendly error messages instead of raw FirebaseAuthException text.
  String mapError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with that email.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'weak-password':
          return 'Password should be at least 6 characters.';
        case 'network-request-failed':
          return 'No internet connection. Please try again.';
        default:
          return e.message ?? 'Something went wrong. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
