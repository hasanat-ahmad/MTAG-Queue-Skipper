import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';

/// Decides where the app goes after the splash screen.
class SplashController {
  SplashController({
    required AuthController auth,
    required RegistrationController registration,
    this.minimumDisplayTime = const Duration(milliseconds: 1500),
  }) : _auth = auth,
       _registration = registration;

  final AuthController _auth;
  final RegistrationController _registration;

  /// How long the splash stays up even when nothing needs loading: about
  /// one sweep of the logo animation. Loading the rider's profile runs in
  /// parallel and can keep it up longer.
  final Duration minimumDisplayTime;

  /// Returns [AppRoutes.home] for a rider Firebase remembers (with their
  /// profile and registration loaded), otherwise [AppRoutes.login].
  Future<String> resolveStartRoute() async {
    final minimumDelay = Future<void>.delayed(minimumDisplayTime);
    final uid = _auth.uid;
    if (uid == null) {
      await minimumDelay;
      return AppRoutes.login;
    }

    await Future.wait([
      minimumDelay,
      _auth.refreshProfile(),
      _registration.loadForUser(uid),
    ]);
    return AppRoutes.home;
  }
}
