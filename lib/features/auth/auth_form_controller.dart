import 'package:mtag_queue_skipper/core/state/safe_change_notifier.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';

/// State and actions behind the login and sign-up screens.
///
/// After a successful sign-in it loads the rider's profile and registration,
/// so the home screen opens with their token already in place.
class AuthFormController extends SafeChangeNotifier {
  AuthFormController({
    required AuthController auth,
    required RegistrationController registration,
  }) : _auth = auth,
       _registration = registration;

  final AuthController _auth;
  final RegistrationController _registration;

  bool _isSubmitting = false;
  bool _isPasswordHidden = true;

  bool get isSubmitting => _isSubmitting;
  bool get isPasswordHidden => _isPasswordHidden;

  void togglePasswordVisibility() {
    _isPasswordHidden = !_isPasswordHidden;
    notifyListeners();
  }

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _submit(
      () => _auth.signInWithEmail(email: email, password: password),
    );
  }

  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return _submit(
      () => _auth.signUpWithEmail(email: email, password: password),
    );
  }

  Future<AuthResult> continueWithGoogle() => _submit(_auth.signInWithGoogle);

  Future<AuthResult> _submit(Future<AuthResult> Function() attempt) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      final result = await attempt();
      final uid = _auth.uid;
      if (result.success && uid != null) {
        await _auth.refreshProfile();
        await _registration.loadForUser(uid);
      }
      return result;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
