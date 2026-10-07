import 'package:flutter_test/flutter_test.dart';
import 'package:mtag_queue_skipper/data/models/registration_record.dart';
import 'package:mtag_queue_skipper/data/services/backend_service.dart';
import 'package:mtag_queue_skipper/data/services/stripe_service.dart';
import 'package:mtag_queue_skipper/features/payment/payment_controller.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeBackendService backend;
  late FakeStripeService stripe;
  late FakeFirestoreService firestore;
  late RegistrationController registration;
  late PaymentController controller;

  setUp(() {
    backend = FakeBackendService();
    stripe = FakeStripeService();
    firestore = FakeFirestoreService();
    registration = RegistrationController(firestoreService: firestore);
    controller = PaymentController(
      auth: signedInAuth(firestore: firestore),
      registration: registration,
      backend: backend,
      stripe: stripe,
    );
  });

  test('pays, has the server confirm, and stores the assigned token', () async {
    expect(await controller.pay(), PaymentOutcome.paid);

    expect(backend.calls, ['createPaymentIntent', 'confirmPayment:pi_123']);
    expect(stripe.presentedSecrets, ['pi_123_secret']);
    expect(registration.token, testToken);
    expect(controller.error, isNull);
    expect(controller.isPaying, isFalse);
  });

  test('closing the Payment Sheet cancels quietly', () async {
    stripe.error = const StripePaymentException(
      'Payment cancelled.',
      code: 'canceled',
    );

    expect(await controller.pay(), PaymentOutcome.cancelled);
    expect(controller.error, isNull);
    expect(backend.calls, ['createPaymentIntent']);
  });

  test('a declined card shows the reason and assigns no token', () async {
    stripe.error = const StripePaymentException(
      'Your card was declined.',
      code: 'Failed',
    );

    expect(await controller.pay(), PaymentOutcome.failed);
    expect(controller.error, 'Your card was declined.');
    expect(registration.hasToken, isFalse);
  });

  test('a rider who already paid gets their existing token', () async {
    backend.createPaymentIntentError = const BackendException(
      'Your registration fee is already paid.',
      code: 'already-exists',
    );
    firestore.registration = const RegistrationRecord(
      bike: testBike,
      token: testToken,
    );

    expect(await controller.pay(), PaymentOutcome.paid);
    expect(stripe.presentedSecrets, isEmpty);
    expect(registration.token, testToken);
  });

  test('retrying after a failed confirmation never charges twice', () async {
    backend.confirmPaymentErrors.add(
      const BackendException('Cannot reach the server.', code: 'unavailable'),
    );

    expect(await controller.pay(), PaymentOutcome.failed);
    expect(controller.hasUnconfirmedPayment, isTrue);
    expect(controller.error, contains('will not be charged twice'));

    expect(await controller.pay(), PaymentOutcome.paid);
    expect(stripe.presentedSecrets, hasLength(1));
    expect(backend.calls, [
      'createPaymentIntent',
      'confirmPayment:pi_123',
      'confirmPayment:pi_123',
    ]);
    expect(controller.hasUnconfirmedPayment, isFalse);
    expect(registration.token, testToken);
  });

  test('signed-out riders cannot start a payment', () async {
    final signedOut = PaymentController(
      auth: AuthController(
        authService: FakeAuthService(),
        firestoreService: firestore,
      ),
      registration: registration,
      backend: backend,
      stripe: stripe,
    );

    expect(await signedOut.pay(), PaymentOutcome.failed);
    expect(signedOut.error, 'Please sign in to complete payment.');
    expect(backend.calls, isEmpty);
  });
}
