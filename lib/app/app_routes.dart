import 'package:flutter/widgets.dart';
import 'package:mtag_queue_skipper/features/auth/login_screen.dart';
import 'package:mtag_queue_skipper/features/auth/register_screen.dart';
import 'package:mtag_queue_skipper/features/bike_details/bike_details_screen.dart';
import 'package:mtag_queue_skipper/features/bike_registration/bike_registration_screen.dart';
import 'package:mtag_queue_skipper/features/face_capture/face_capture_screen.dart';
import 'package:mtag_queue_skipper/features/home/home_screen.dart';
import 'package:mtag_queue_skipper/features/payment/payment_screen.dart';
import 'package:mtag_queue_skipper/features/profile/profile_screen.dart';
import 'package:mtag_queue_skipper/features/splash/splash_screen.dart';
import 'package:mtag_queue_skipper/features/token_status/token_status_screen.dart';
import 'package:mtag_queue_skipper/screens/mtag_card_issuance_screen.dart';

/// Named routes for every screen.
///
/// Navigate with these constants, e.g.
/// `Navigator.pushNamed(context, AppRoutes.home)`, so a typo in a route name
/// is a compile error instead of a runtime crash.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String bikeRegistration = '/bike-register';
  static const String faceCapture = '/face-capture';
  static const String payment = '/payment';
  static const String tokenStatus = '/token-status';
  static const String bikeDetails = '/bike-details';
  static const String cardIssuance = '/mtag-card';

  /// Route table for [MaterialApp.routes].
  static final Map<String, WidgetBuilder> table = {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const HomeScreen(),
    profile: (_) => const ProfileScreen(),
    bikeRegistration: (_) => const BikeRegistrationScreen(),
    faceCapture: (_) => const FaceCaptureScreen(),
    payment: (_) => const PaymentScreen(),
    tokenStatus: (_) => const TokenStatusScreen(),
    bikeDetails: (_) => const BikeDetailsScreen(),
    cardIssuance: (_) => const MtagCardIssuanceScreen(),
  };
}
