import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:mtag_queue_skipper/data/models/user_profile.dart';
import 'package:mtag_queue_skipper/data/services/auth_service.dart';
import 'package:mtag_queue_skipper/data/services/firestore_service.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;

  const AuthResult.success() : success = true, errorMessage = null;

  const AuthResult.failure(this.errorMessage) : success = false;
}

class AuthProvider with ChangeNotifier {
  AuthProvider({AuthService? authService, FirestoreService? firestoreService})
    : _authService = authService ?? AuthService(),
      _firestoreService = firestoreService ?? FirestoreService() {
    _user = _mapFirebaseUser(_authService.currentUser);
    _authSubscription = _authService.authStateChanges().listen(
      _onAuthStateChanged,
    );
  }

  final AuthService _authService;
  final FirestoreService _firestoreService;
  late final StreamSubscription<firebase_auth.User?> _authSubscription;

  UserProfile? _user;

  UserProfile? get user => _user;

  void _onAuthStateChanged(firebase_auth.User? firebaseUser) {
    if (firebaseUser == null) {
      _user = null;
      notifyListeners();
      return;
    }

    _user = _mergeWithExistingProfile(_profileFromFirebaseUser(firebaseUser));
    notifyListeners();
    loadUserProfileFromFirestore();
  }

  UserProfile _mergeWithExistingProfile(UserProfile mapped) {
    final existing = _user;
    if (existing == null || existing.uid != mapped.uid) return mapped;

    return mapped.copyWith(
      name: existing.name.trim().isNotEmpty ? existing.name : mapped.name,
      cnic: existing.cnic,
      phoneNumber: existing.phoneNumber,
    );
  }

  UserProfile? _mapFirebaseUser(firebase_auth.User? firebaseUser) {
    if (firebaseUser == null) return null;
    return _mergeWithExistingProfile(_profileFromFirebaseUser(firebaseUser));
  }

  /// Uses the Firebase display name, falling back to the e-mail prefix.
  UserProfile _profileFromFirebaseUser(firebase_auth.User firebaseUser) {
    final email = firebaseUser.email ?? '';
    final displayName = firebaseUser.displayName?.trim();
    final fallbackName = email.isNotEmpty ? email.split('@').first : 'User';

    return UserProfile(
      uid: firebaseUser.uid,
      name: (displayName != null && displayName.isNotEmpty)
          ? displayName
          : fallbackName,
      email: email,
    );
  }

  /// Loads owner profile from Firestore for the signed-in user.
  Future<void> loadUserProfileFromFirestore() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null || _user == null) return;

    try {
      final data = await _firestoreService.getUserProfile(uid);
      if (data == null || _user?.uid != uid) return;

      _user = _user!.mergeStoredProfile(data);
      notifyListeners();
    } on FirestoreException catch (e) {
      debugPrint('Failed to load user profile from Firestore: $e');
    } catch (e) {
      debugPrint('Failed to load user profile from Firestore: $e');
    }
  }

  /// Updates owner fields in memory only (e.g. after a combined Firestore save).
  void applyLocalOwnerProfile({
    required String name,
    required String cnic,
    required String phoneNumber,
  }) {
    if (_user == null) return;
    _user = _user!.copyWith(
      name: name.trim(),
      cnic: cnic.trim(),
      phoneNumber: phoneNumber.trim(),
    );
    notifyListeners();
  }

  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return _signIn(
      () => _authService.signUpWithEmail(email: email, password: password),
    );
  }

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _signIn(
      () => _authService.signInWithEmail(email: email, password: password),
    );
  }

  Future<AuthResult> signInWithGoogle() {
    return _signIn(_authService.signInWithGoogle);
  }

  Future<AuthResult> _signIn(
    Future<firebase_auth.User?> Function() attempt,
  ) async {
    try {
      final firebaseUser = await attempt();
      _user = _mapFirebaseUser(firebaseUser);
      notifyListeners();
      return const AuthResult.success();
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
