import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mtag_queue_skipper/app/mtag_app.dart';
import 'package:mtag_queue_skipper/config/stripe_config.dart';
import 'package:mtag_queue_skipper/data/services/face_verification_service.dart';
import 'package:mtag_queue_skipper/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initStripe();
  await _initFaceVerification();
  runApp(const MtagApp());
}

Future<void> _initStripe() async {
  if (kIsWeb || !StripeConfig.isConfigured) return;
  Stripe.publishableKey = StripeConfig.publishableKey.trim();
  await Stripe.instance.applySettings();
}

Future<void> _initFaceVerification() async {
  if (kIsWeb) return;
  try {
    await FaceVerificationService.instance.ensureInitialized();
  } catch (e) {
    debugPrint('Face verification init skipped: $e');
  }
}
