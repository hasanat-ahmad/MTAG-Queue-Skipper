import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mtag_queue_skipper/config/stripe_config.dart';
import 'package:mtag_queue_skipper/firebase_options.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:mtag_queue_skipper/providers/bike_details_provider.dart';
import 'package:mtag_queue_skipper/screens/bike_details_screen.dart';
import 'package:mtag_queue_skipper/screens/bike_register_screen.dart';
import 'package:mtag_queue_skipper/screens/face_capture_screen.dart';
import 'package:mtag_queue_skipper/screens/home_screen.dart';
import 'package:mtag_queue_skipper/screens/login_screen.dart';
import 'package:mtag_queue_skipper/screens/payment_screen.dart';
import 'package:mtag_queue_skipper/screens/profile_screen.dart';
import 'package:mtag_queue_skipper/screens/register_screen.dart';
import 'package:mtag_queue_skipper/screens/splash_screen.dart';
import 'package:mtag_queue_skipper/screens/mtag_card_issuance_screen.dart';
import 'package:mtag_queue_skipper/screens/token_status_screen.dart';
import 'package:mtag_queue_skipper/services/face_verification_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb && StripeConfig.isConfigured) {
    Stripe.publishableKey = StripeConfig.publishableKey.trim();
    await Stripe.instance.applySettings();
  }

  if (!kIsWeb) {
    try {
      await FaceVerificationService.instance.ensureInitialized();
    } catch (e) {
      debugPrint('Face verification init skipped: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BikeDetailsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const Profile(),
        '/bike-register': (context) => const BikeRegisterScreen(),
        '/face-capture': (context) => const FaceCaptureScreen(),
        '/payment': (context) => const PaymentScreen(),
        '/bike-details': (context) => const BikeDetailsScreen(),
        '/token-status': (context) => const TokenStatusScreen(),
        '/mtag-card': (context) => const MtagCardIssuanceScreen(),
      },
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
