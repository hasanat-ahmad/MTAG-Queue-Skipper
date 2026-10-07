import 'package:flutter/foundation.dart';
import 'package:mtag_queue_skipper/config/stripe_config.dart';
import 'package:mtag_queue_skipper/core/errors/app_exception.dart';
import 'package:mtag_queue_skipper/core/state/safe_change_notifier.dart';
import 'package:mtag_queue_skipper/data/services/backend_service.dart';
import 'package:mtag_queue_skipper/data/services/stripe_service.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';

/// How a payment attempt ended.
enum PaymentOutcome {
  paid,

  /// The rider closed the Payment Sheet; nothing was charged.
  cancelled,

  /// See [PaymentController.error].
  failed,
}

/// Takes the registration fee.
///
/// The server creates the payment, the rider pays in Stripe's Payment
/// Sheet, then the server verifies the payment with Stripe and assigns the
/// queue token. The app never sees the Stripe secret key and cannot mark
/// itself as paid.
class PaymentController extends SafeChangeNotifier {
  PaymentController({
    required AuthController auth,
    required RegistrationController registration,
    BackendService? backend,
    StripeService? stripe,
  }) : _auth = auth,
       _registration = registration,
       _backend = backend ?? BackendService(),
       _stripe = stripe ?? StripeService();

  final AuthController _auth;
  final RegistrationController _registration;
  final BackendService _backend;
  final StripeService _stripe;

  bool _isPaying = false;
  String? _error;

  /// A payment Stripe accepted but the server has not confirmed yet, e.g.
  /// because the connection dropped. Retrying confirms this one instead of
  /// charging the rider again.
  String? _unconfirmedPaymentId;

  bool get isPaying => _isPaying;

  /// Why the last attempt failed, shown above the pay button.
  String? get error => _error;

  /// True when the rider has paid but confirmation still has to be retried.
  bool get hasUnconfirmedPayment => _unconfirmedPaymentId != null;

  /// False when the Stripe publishable key is missing from the build.
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
      final paymentId = _unconfirmedPaymentId ?? await _collectPayment();
      _unconfirmedPaymentId = paymentId;
      final token = await _backend.confirmPayment(paymentId);
      _unconfirmedPaymentId = null;
      _registration.recordPayment(token);
      return PaymentOutcome.paid;
    } on BackendException catch (e) {
      if (e.code == 'already-exists') {
        // Paid earlier, e.g. before re-registering the bike: load the
        // token the server assigned then.
        await _registration.loadForUser(uid);
        return PaymentOutcome.paid;
      }
      return _fail(
        hasUnconfirmedPayment
            ? 'Your payment went through but could not be confirmed yet. '
                  'Tap the button to try again; you will not be charged twice.'
            : e.message,
      );
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

  /// Creates the payment on the server and lets the rider pay. Returns the
  /// PaymentIntent id once Stripe has accepted the payment.
  Future<String> _collectPayment() async {
    final session = await _backend.createPaymentIntent();
    await _stripe.presentPaymentSheet(clientSecret: session.clientSecret);
    return session.paymentIntentId;
  }

  PaymentOutcome _fail(String message) {
    _error = message;
    notifyListeners();
    return PaymentOutcome.failed;
  }
}
