import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/config/stripe_config.dart';
import 'package:mtag_queue_skipper/firebase_options.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:mtag_queue_skipper/providers/bike_details_provider.dart';
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
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.table,
      debugShowCheckedModeBanner: false,
    );
  }
}
