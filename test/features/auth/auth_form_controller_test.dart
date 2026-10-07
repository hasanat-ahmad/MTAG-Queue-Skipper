import 'package:flutter_test/flutter_test.dart';
import 'package:mtag_queue_skipper/data/models/registration_record.dart';
import 'package:mtag_queue_skipper/data/services/auth_service.dart';
import 'package:mtag_queue_skipper/features/auth/auth_form_controller.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeFirestoreService firestore;
  late FakeAuthService authService;
  late RegistrationController registration;
  late AuthFormController form;

  setUp(() {
    firestore = FakeFirestoreService();
    authService = FakeAuthService();
    final auth = AuthController(
      authService: authService,
      firestoreService: firestore,
    );
    registration = RegistrationController(firestoreService: firestore);
    form = AuthFormController(auth: auth, registration: registration);
  });

  test("a successful sign-in loads the rider's registration", () async {
    authService.nextUser = FakeFirebaseUser(
      uid: 'rider-9',
      email: 'rider9@example.com',
    );
    firestore.registration = const RegistrationRecord(
      bike: testBike,
      token: testToken,
    );

    final result = await form.signInWithEmail(
      email: 'rider9@example.com',
      password: 'secret1',
    );

    expect(result.success, isTrue);
    expect(firestore.fetchedRegistrationFor, ['rider-9']);
    expect(registration.token, testToken);
    expect(form.isSubmitting, isFalse);
  });

  test('a failed sign-in returns the reason and loads nothing', () async {
    authService.nextError = const AuthException('Invalid email or password.');

    final result = await form.signInWithEmail(
      email: 'rider9@example.com',
      password: 'wrong',
    );

    expect(result.success, isFalse);
    expect(result.errorMessage, 'Invalid email or password.');
    expect(firestore.fetchedRegistrationFor, isEmpty);
    expect(form.isSubmitting, isFalse);
  });

  test('keeps the spinner on until the rider data has loaded', () async {
    authService.nextUser = FakeFirebaseUser(uid: 'rider-9');
    final states = <bool>[];
    form.addListener(() => states.add(form.isSubmitting));

    await form.continueWithGoogle();

    expect(states, [true, false]);
  });

  test('toggles password visibility', () {
    expect(form.isPasswordHidden, isTrue);
    form.togglePasswordVisibility();
    expect(form.isPasswordHidden, isFalse);
  });
}
