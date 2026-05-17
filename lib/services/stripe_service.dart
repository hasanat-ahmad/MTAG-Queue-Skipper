import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:mtag_queue_skipper/config/stripe_config.dart';

class StripePaymentException implements Exception {
  StripePaymentException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class StripePaymentResult {
  const StripePaymentResult({
    required this.paymentIntentId,
    required this.clientSecret,
  });

  final String paymentIntentId;
  final String clientSecret;
}

class StripeService {
  void ensureConfigured() {
    if (!StripeConfig.isConfigured) {
      throw StripePaymentException(
        'Stripe is not configured. Copy lib/config/stripe_config.local.dart.example '
        'to stripe_config.local.dart and add your test keys.',
        code: 'not-configured',
      );
    }
  }

  Future<StripePaymentResult> createPaymentIntent() async {
    ensureConfigured();

    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${StripeConfig.secretKey.trim()}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': StripeConfig.amountCents.toString(),
          'currency': StripeConfig.currency,
          'payment_method_types[]': 'card',
          'description': 'MTAG bike registration fee',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StripePaymentException(
          _parseStripeError(response.body) ??
              'Could not create payment (${response.statusCode}).',
          code: 'create-intent-failed',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final clientSecret = json['client_secret'] as String?;
      final id = json['id'] as String?;

      if (clientSecret == null ||
          clientSecret.isEmpty ||
          id == null ||
          id.isEmpty) {
        throw StripePaymentException(
          'Stripe did not return a valid payment intent.',
          code: 'invalid-response',
        );
      }

      return StripePaymentResult(
        paymentIntentId: id,
        clientSecret: clientSecret,
      );
    } on StripePaymentException {
      rethrow;
    } catch (e) {
      throw StripePaymentException(e.toString());
    }
  }

  Future<void> presentPaymentSheet({
    required String clientSecret,
  }) async {
    ensureConfigured();

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'MTAG Queue Skipper',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        throw StripePaymentException(
          'Payment cancelled.',
          code: 'canceled',
        );
      }
      throw StripePaymentException(
        e.error.localizedMessage ?? e.error.message ?? 'Payment failed.',
        code: e.error.code.name,
      );
    } on StripePaymentException {
      rethrow;
    } catch (e) {
      throw StripePaymentException(e.toString());
    }
  }

  String? _parseStripeError(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      return error?['message'] as String?;
    } catch (_) {
      return null;
    }
  }
}
