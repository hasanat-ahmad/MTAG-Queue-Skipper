import 'package:flutter/widgets.dart';
import 'package:mtag_queue_skipper/features/auth/login_screen.dart';
import 'package:mtag_queue_skipper/features/auth/register_screen.dart';
import 'package:mtag_queue_skipper/screens/bike_details_screen.dart';
import 'package:mtag_queue_skipper/screens/bike_register_screen.dart';
import 'package:mtag_queue_skipper/screens/face_capture_screen.dart';
import 'package:mtag_queue_skipper/screens/home_screen.dart';
import 'package:mtag_queue_skipper/screens/mtag_card_issuance_screen.dart';
import 'package:mtag_queue_skipper/screens/payment_screen.dart';
import 'package:mtag_queue_skipper/screens/profile_screen.dart';
import 'package:mtag_queue_skipper/screens/splash_screen.dart';
import 'package:mtag_queue_skipper/screens/token_status_screen.dart';

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
    profile: (_) => const Profile(),
    bikeRegistration: (_) => const BikeRegisterScreen(),
    faceCapture: (_) => const FaceCaptureScreen(),
    payment: (_) => const PaymentScreen(),
    tokenStatus: (_) => const TokenStatusScreen(),
    bikeDetails: (_) => const BikeDetailsScreen(),
    cardIssuance: (_) => const MtagCardIssuanceScreen(),
  };
}
