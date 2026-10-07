import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/config/stripe_config.dart';
import 'package:mtag_queue_skipper/data/services/face_verification_service.dart';
import 'package:mtag_queue_skipper/firebase_options.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';
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
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => RegistrationController()),
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
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.table,
      debugShowCheckedModeBanner: false,
    );
  }
}
