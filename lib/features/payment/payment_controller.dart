import 'package:flutter/foundation.dart';
import 'package:mtag_queue_skipper/config/stripe_config.dart';
import 'package:mtag_queue_skipper/core/errors/app_exception.dart';
import 'package:mtag_queue_skipper/core/state/safe_change_notifier.dart';
import 'package:mtag_queue_skipper/data/services/firestore_service.dart';
import 'package:mtag_queue_skipper/data/services/stripe_service.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';

/// How a payment attempt ended.
enum PaymentOutcome {
  paid,

  /// The rider closed the Payment Sheet; nothing was charged.
  cancelled,

  /// See [PaymentController.error].
  failed,
}

/// Takes the registration fee through the Stripe Payment Sheet.
class PaymentController extends SafeChangeNotifier {
  PaymentController({
    required AuthController auth,
    StripeService? stripe,
    FirestoreService? firestore,
  }) : _auth = auth,
       _stripe = stripe ?? StripeService(),
       _firestore = firestore ?? FirestoreService();

  final AuthController _auth;
  final StripeService _stripe;
  final FirestoreService _firestore;

  bool _isPaying = false;
  String? _error;

  bool get isPaying => _isPaying;

  /// Why the last attempt failed, shown above the pay button.
  String? get error => _error;

  /// False when the Stripe keys are missing from the build.
  bool get isConfigured => StripeConfig.isConfigured;

  /// The fee as shown to the rider, e.g. `$5.00`.
  String get formattedFee => StripeConfig.formattedAmount;

  Future<PaymentOutcome> pay() async {
    if (kIsWeb) {
      return _fail(
        'Stripe Payment Sheet is not supported on web. Use a device.',
      );
    }
    final uid = _auth.uid;
    if (uid == null) return _fail('Please sign in to complete payment.');

    _isPaying = true;
    _error = null;
    notifyListeners();

    try {
      final intent = await _stripe.createPaymentIntent();
      await _stripe.presentPaymentSheet(clientSecret: intent.clientSecret);
      await _firestore.savePaymentRecord(
        uid: uid,
        paymentIntentId: intent.paymentIntentId,
        amountCents: StripeConfig.amountCents,
        currency: StripeConfig.currency,
      );
      return PaymentOutcome.paid;
    } on StripePaymentException catch (e) {
      if (e.code == 'canceled') return PaymentOutcome.cancelled;
      return _fail(e.message);
    } on AppException catch (e) {
      return _fail(e.message);
    } catch (e) {
      return _fail(e.toString());
    } finally {
      _isPaying = false;
      notifyListeners();
    }
  }

  PaymentOutcome _fail(String message) {
    _error = message;
    notifyListeners();
    return PaymentOutcome.failed;
  }
}
