import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mtag_queue_skipper/config/stripe_config.dart';
import 'package:mtag_queue_skipper/core/errors/app_exception.dart';

class StripePaymentException extends AppException {
  const StripePaymentException(super.message, {super.code});
}

/// Shows Stripe's Payment Sheet for a PaymentIntent created by the server
/// (BackendService.createPaymentIntent). The app never talks to the Stripe
/// API with a secret key.
class StripeService {
  void ensureConfigured() {
    if (!StripeConfig.isConfigured) {
      throw const StripePaymentException(
        'Stripe is not configured. Copy lib/config/stripe_config.local.dart.example '
        'to stripe_config.local.dart and add your publishable key.',
        code: 'not-configured',
      );
    }
  }

  /// Completes when the rider has paid. Throws [StripePaymentException]
  /// with code `canceled` when they close the sheet.
  Future<void> presentPaymentSheet({required String clientSecret}) async {
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
        throw const StripePaymentException(
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
}
