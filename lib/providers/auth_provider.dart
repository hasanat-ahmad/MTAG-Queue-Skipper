import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mtag_queue_skipper/firebase_options.dart';
import 'package:mtag_queue_skipper/models/user.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;

  const AuthResult.success() : success = true, errorMessage = null;

  const AuthResult.failure(this.errorMessage) : success = false;
}

class AuthProvider with ChangeNotifier {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

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

  AuthProvider() {
    _user = _mapFirebaseUser(_firebaseAuth.currentUser);
    _firebaseAuth.authStateChanges().listen((firebaseUser) {
      _user = _mapFirebaseUser(firebaseUser);
      notifyListeners();
    });
  }

  User? _mapFirebaseUser(firebase_auth.User? firebaseUser) {
    if (firebaseUser == null) return null;
    return User.fromFirebase(firebaseUser);
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

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
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
      if (errorText.contains('apiexception: 10') || errorText.contains(': 10:')) {
        return AuthResult.failure(_androidDeveloperErrorMessage);
      }
      return AuthResult.failure('Google sign-in failed: $e');
    }
  }

  Future<void> loadUser() async {
    _user = _mapFirebaseUser(_firebaseAuth.currentUser);
    notifyListeners();
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
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
    _user = null;
    notifyListeners();
  }
}
