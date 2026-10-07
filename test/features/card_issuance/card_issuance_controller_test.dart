import 'package:flutter_test/flutter_test.dart';
import 'package:mtag_queue_skipper/data/models/card_collection_ticket.dart';
import 'package:mtag_queue_skipper/data/models/registration_record.dart';
import 'package:mtag_queue_skipper/data/services/backend_service.dart';
import 'package:mtag_queue_skipper/data/services/firestore_service.dart';
import 'package:mtag_queue_skipper/features/card_issuance/card_issuance_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';

import '../../helpers/fakes.dart';

void main() {
  const ticket = CardCollectionTicket(
    uid: 'rider-1',
    tokenNumber: 'TKN-0001',
    ownerName: 'Ali Khan',
    plateNumber: 'ICT-1234',
    facePhotoUrl:
        'https://res.cloudinary.com/demo/image/upload/mtag/users/rider-1/face.jpg',
  );

  late FakeFirestoreService firestore;
  late FakeBackendService backend;
  late FakeFaceVerificationService faces;
  late FakeCameraCaptureController camera;
  late RegistrationController registration;
  late CardIssuanceController controller;

  setUp(() async {
    firestore = FakeFirestoreService()..ticket = ticket;
    backend = FakeBackendService();
    faces = FakeFaceVerificationService();
    camera = FakeCameraCaptureController();
    registration = await loadedRegistration(
      const RegistrationRecord(bike: testBike, token: testToken),
      firestore: firestore,
    );
    controller = CardIssuanceController(
      auth: signedInAuth(firestore: firestore),
      registration: registration,
      camera: camera,
      backend: backend,
      firestore: firestore,
      faceVerification: faces,
    );
  });

  Future<void> reachFaceCheckWithPhoto() async {
    await controller.submitToken('TKN-0001');
    await controller.capturePhoto();
  }

  test("suggests the rider's own token", () {
    expect(controller.suggestedToken, 'TKN-0001');
    expect(controller.step, CardIssuanceStep.enterToken);
  });

  test(
    'a valid token moves on to the face check and opens the camera',
    () async {
      await controller.submitToken(' TKN-0001 ');

      expect(controller.step, CardIssuanceStep.verifyFace);
      expect(controller.ticket, ticket);
      expect(camera.initializeCalls, 1);
    },
  );

  test('a rejected token stays on the first step with the reason', () async {
    firestore.validationError = const FirestoreException(
      'Token number does not match your registration.',
    );

    await controller.submitToken('TKN-9999');

    expect(controller.step, CardIssuanceStep.enterToken);
    expect(controller.error, 'Token number does not match your registration.');
    expect(camera.initializeCalls, 0);
  });

  test('a matching face has the server issue the card', () async {
    await reachFaceCheckWithPhoto();
    await controller.verifyAndIssue();

    expect(faces.verifiedPaths, ['/tmp/test-selfie.jpg']);
    expect(backend.calls, ['issueMtagCard:TKN-0001']);
    expect(controller.step, CardIssuanceStep.issued);
    expect(registration.isCardCollected, isTrue);
  });

  test('a face that does not match never reaches the server', () async {
    faces.isMatch = false;

    await reachFaceCheckWithPhoto();
    await controller.verifyAndIssue();

    expect(backend.calls, isEmpty);
    expect(controller.step, CardIssuanceStep.verifyFace);
    expect(controller.error, contains('did not match'));
    expect(registration.isCardCollected, isFalse);
  });

  test('a server refusal is shown and nothing is marked collected', () async {
    backend.issueCardError = const BackendException(
      'Your MTAG card has already been issued.',
      code: 'already-exists',
    );

    await reachFaceCheckWithPhoto();
    await controller.verifyAndIssue();

    expect(controller.error, 'Your MTAG card has already been issued.');
    expect(controller.step, CardIssuanceStep.verifyFace);
    expect(controller.isBusy, isFalse);
    expect(registration.isCardCollected, isFalse);
  });

  test('retaking the selfie clears the previous error', () async {
    faces.isMatch = false;
    await reachFaceCheckWithPhoto();
    await controller.verifyAndIssue();
    expect(controller.error, isNotNull);

    controller.retake();

    expect(controller.error, isNull);
    expect(camera.photo, isNull);
  });
}
