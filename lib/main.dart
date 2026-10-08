import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mtag_queue_skipper/app/mtag_app.dart';
import 'package:mtag_queue_skipper/config/stripe_config.dart';
import 'package:mtag_queue_skipper/firebase_options.dart';

/// Only what the first screen needs is set up before runApp. The face
/// model is loaded later, by the selfie screens that use it.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initStripe();
  runApp(const MtagApp());
}

Future<void> _initStripe() async {
  if (kIsWeb || !StripeConfig.isConfigured) return;
  Stripe.publishableKey = StripeConfig.publishableKey.trim();
  await Stripe.instance.applySettings();
}
