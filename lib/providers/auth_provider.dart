import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mtag_queue_skipper/firebase_options.dart';
import 'package:mtag_queue_skipper/models/user.dart';
import 'package:mtag_queue_skipper/services/firestore_service.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;

  const AuthResult.success() : success = true, errorMessage = null;

  const AuthResult.failure(this.errorMessage) : success = false;
}

class AuthProvider with ChangeNotifier {
  AuthProvider({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService() {
    _user = _mapFirebaseUser(_firebaseAuth.currentUser);
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirestoreService _firestoreService;

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
    serverClientId: DefaultFirebaseOptions.googleWebClientId,
    clientId: _googleClientIdForPlatform,
  );

  static String? get _googleClientIdForPlatform {
    if (kIsWeb) return null;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return DefaultFirebaseOptions.googleIosClientId;
      default:
        return null;
    }
  }

  User? _user;

  User? get user => _user;
  firebase_auth.User? get firebaseUser => _firebaseAuth.currentUser;

  void _onAuthStateChanged(firebase_auth.User? firebaseUser) {
    if (firebaseUser == null) {
      _user = null;
      notifyListeners();
      return;
    }

    _user = _mergeWithExistingProfile(User.fromFirebase(firebaseUser));
    notifyListeners();
    loadUserProfileFromFirestore();
  }

  User _mergeWithExistingProfile(User mapped) {
    final existing = _user;
    if (existing == null || existing.uid != mapped.uid) return mapped;

    return mapped.copyWith(
      name: existing.name.trim().isNotEmpty ? existing.name : mapped.name,
      cnic: existing.cnic,
      phoneNumber: existing.phoneNumber,
    );
  }

  User? _mapFirebaseUser(firebase_auth.User? firebaseUser) {
    if (firebaseUser == null) return null;
    return _mergeWithExistingProfile(User.fromFirebase(firebaseUser));
  }

  /// Loads owner profile from Firestore for the signed-in user.
  Future<void> loadUserProfileFromFirestore() async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null || _user == null) return;

    try {
      final data = await _firestoreService.getUserProfile(uid);
      if (data == null || _user?.uid != uid) return;

      _user = _user!.copyWith(
        name: (data['name'] as String?)?.trim().isNotEmpty == true
            ? data['name'] as String
            : _user!.name,
        cnic: data['cnic'] as String? ?? _user!.cnic,
        phoneNumber: data['phoneNumber'] as String? ?? _user!.phoneNumber,
        email: data['email'] as String? ?? _user!.email,
      );
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

  /// Saves owner details from bike registration to profile and Firestore.
  Future<void> updateOwnerProfile({
    required String name,
    required String cnic,
    required String phoneNumber,
  }) async {
    if (_user == null) return;

    final trimmedName = name.trim();
    final trimmedCnic = cnic.trim();
    final trimmedPhone = phoneNumber.trim();

    _user = _user!.copyWith(
      name: trimmedName,
      cnic: trimmedCnic,
      phoneNumber: trimmedPhone,
    );
    notifyListeners();

    final firebaseUser = _firebaseAuth.currentUser;
    final uid = firebaseUser?.uid;
    if (uid != null) {
      try {
        await _firestoreService.saveUserProfile(
          uid: uid,
          email: _user!.email,
          name: trimmedName,
          cnic: trimmedCnic,
          phoneNumber: trimmedPhone,
        );
      } on FirestoreException catch (e) {
        debugPrint('Failed to save user profile to Firestore: $e');
      } catch (e) {
        debugPrint('Failed to save user profile to Firestore: $e');
      }
    }

    if (firebaseUser != null && trimmedName.isNotEmpty) {
      try {
        await firebaseUser.updateDisplayName(trimmedName);
      } catch (e) {
        debugPrint('Failed to update Firebase display name: $e');
      }
    }
  }

  String _authErrorMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'popup-closed-by-user':
        return 'Sign-in was cancelled.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = _mapFirebaseUser(credential.user);
      notifyListeners();
      return const AuthResult.success();
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_authErrorMessage(e));
    } catch (_) {
      return const AuthResult.failure('Sign up failed. Please try again.');
    }
  }

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _user = _mapFirebaseUser(credential.user);
      notifyListeners();
      return const AuthResult.success();
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_authErrorMessage(e));
    } catch (_) {
      return const AuthResult.failure('Login failed. Please try again.');
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const AuthResult.failure('Sign-in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        return const AuthResult.failure(
          'Google did not return an ID token. Check Firebase Google Sign-In setup.',
        );
      }

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      _user = _mapFirebaseUser(userCredential.user);
      notifyListeners();
      return const AuthResult.success();
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('Firebase Google sign-in error: ${e.code} ${e.message}');
      return AuthResult.failure(_authErrorMessage(e));
    } on PlatformException catch (e) {
      debugPrint('Platform Google sign-in error: ${e.code} ${e.message}');
      if (_isAndroidDeveloperError(e)) {
        return AuthResult.failure(_androidDeveloperErrorMessage);
      }
      return AuthResult.failure(
        e.message ?? 'Google sign-in failed (${e.code}).',
      );
    } catch (e, stackTrace) {
      debugPrint('Google sign-in error: $e\n$stackTrace');
      final errorText = e.toString().toLowerCase();
      if (errorText.contains('apiexception: 10') ||
          errorText.contains(': 10:')) {
        return AuthResult.failure(_androidDeveloperErrorMessage);
      }
      return AuthResult.failure('Google sign-in failed: $e');
    }
  }

  Future<void> loadUser() async {
    _user = _mapFirebaseUser(_firebaseAuth.currentUser);
    notifyListeners();
    await loadUserProfileFromFirestore();
  }

  bool _isAndroidDeveloperError(PlatformException e) {
    final message = '${e.code} ${e.message}'.toLowerCase();
    return message.contains('apiexception: 10') ||
        message.contains('developer_error') ||
        message.contains(': 10:') ||
        message.contains('error 10');
  }

  String get _androidDeveloperErrorMessage =>
      'Google Sign-In is not configured for this Android build (error 10). '
      'In Firebase Console → Project settings → Your Android app '
      '(com.example.mtag_queue_skipper), add SHA-1:\n'
      '${DefaultFirebaseOptions.androidDebugSha1}\n'
      'Then download a new google-services.json, replace '
      'android/app/google-services.json, and run flutter clean && flutter run.';

  Future<void> logout() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    _user = null;
    notifyListeners();
  }
}
