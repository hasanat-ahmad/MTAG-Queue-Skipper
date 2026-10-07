import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mtag_queue_skipper/core/errors/app_exception.dart';
import 'package:mtag_queue_skipper/firebase_options.dart';

/// Thrown when signing in or up fails. [message] is safe to show the rider.
class AuthException extends AppException {
  const AuthException(super.message);
}

/// Firebase Authentication with email/password and Google Sign-In.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn =
          googleSignIn ??
          GoogleSignIn(
            scopes: const ['email', 'profile'],
            serverClientId: DefaultFirebaseOptions.googleWebClientId,
            clientId: _googleClientIdForPlatform,
          );

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

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

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    } catch (_) {
      throw const AuthException('Sign up failed. Please try again.');
    }
  }

  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_messageFor(e));
    } catch (_) {
      throw const AuthException('Login failed. Please try again.');
    }
  }

  /// Opens the Google account picker and signs in to Firebase with the
  /// chosen account. Always shows the picker, even if an account was used
  /// before.
  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Sign-in was cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw const AuthException(
          'Google did not return an ID token. Check Firebase Google Sign-In setup.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } on AuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Google sign-in error: ${e.code} ${e.message}');
      throw AuthException(_messageFor(e));
    } on PlatformException catch (e) {
      debugPrint('Platform Google sign-in error: ${e.code} ${e.message}');
      if (_isAndroidDeveloperError('${e.code} ${e.message}')) {
        throw AuthException(_androidDeveloperErrorMessage);
      }
      throw AuthException(e.message ?? 'Google sign-in failed (${e.code}).');
    } catch (e, stackTrace) {
      debugPrint('Google sign-in error: $e\n$stackTrace');
      if (_isAndroidDeveloperError(e.toString())) {
        throw AuthException(_androidDeveloperErrorMessage);
      }
      throw AuthException('Google sign-in failed: $e');
    }
  }

  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  String _messageFor(FirebaseAuthException e) {
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

  /// Google Play Services reports a SHA-1 mismatch as ApiException 10
  /// (DEVELOPER_ERROR).
  bool _isAndroidDeveloperError(String errorText) {
    final message = errorText.toLowerCase();
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
}
