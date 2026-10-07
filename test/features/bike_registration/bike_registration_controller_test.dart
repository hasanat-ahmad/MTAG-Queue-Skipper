import 'package:flutter_test/flutter_test.dart';
import 'package:mtag_queue_skipper/data/services/firestore_service.dart';
import 'package:mtag_queue_skipper/features/bike_registration/bike_registration_controller.dart';
import 'package:mtag_queue_skipper/features/bike_registration/bike_registration_input.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';

import '../../helpers/fakes.dart';

void main() {
  const input = BikeRegistrationInput(
    ownerName: '  Ali Khan ',
    phone: '0300-1234567',
    cnic: '35202-1234567-1',
    brand: 'Honda',
    color: 'Black',
    year: '2021',
    plateNumber: ' ICT-1234 ',
    engineNumber: 'E1234567',
    chassisNumber: 'C7654321',
  );

  late FakeFirestoreService firestore;
  late AuthController auth;
  late RegistrationController registration;
  late BikeRegistrationController controller;

  setUp(() {
    firestore = FakeFirestoreService();
    auth = signedInAuth(firestore: firestore);
    registration = RegistrationController(firestoreService: firestore);
    controller = BikeRegistrationController(
      auth: auth,
      registration: registration,
    );
  });

  test('saves normalised owner details together with the bike', () async {
    expect(await controller.submit(input), isNull);

    final saved = firestore.savedRegistrations.single;
    expect(saved.owner.uid, 'rider-1');
    expect(saved.owner.name, 'Ali Khan');
    expect(saved.owner.cnic, '3520212345671');
    expect(saved.owner.phoneNumber, '03001234567');
    expect(saved.bike.plateNumber, 'ICT-1234');
    expect(registration.bikeDetails, saved.bike);
    expect(auth.user!.cnic, '3520212345671');
  });

  test(
    'does not invent a queue token; the server assigns it after payment',
    () async {
      await controller.submit(input);
      expect(registration.hasToken, isFalse);
    },
  );

  test('a failed save returns the reason and changes nothing', () async {
    firestore.saveError = const FirestoreException('Cannot reach Firestore.');

    expect(await controller.submit(input), 'Cannot reach Firestore.');
    expect(registration.bikeDetails, isNull);
    expect(auth.user!.cnic, isEmpty);
    expect(controller.isSubmitting, isFalse);
  });

  test('asks signed-out riders to sign in', () async {
    final signedOut = BikeRegistrationController(
      auth: AuthController(
        authService: FakeAuthService(),
        firestoreService: firestore,
      ),
      registration: registration,
    );

    expect(
      await signedOut.submit(input),
      'Please sign in to register your bike.',
    );
    expect(firestore.savedRegistrations, isEmpty);
  });

  test('reports isSubmitting while saving', () async {
    final states = <bool>[];
    controller.addListener(() => states.add(controller.isSubmitting));

    await controller.submit(input);

    expect(states, [true, false]);
  });

  test('pre-fills from the owner details on file', () {
    expect(controller.savedOwner?.name, 'Ali Khan');
  });
}
