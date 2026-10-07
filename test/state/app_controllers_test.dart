import 'package:flutter_test/flutter_test.dart';
import 'package:mtag_queue_skipper/data/models/registration_record.dart';
import 'package:mtag_queue_skipper/data/services/firestore_service.dart';

import '../helpers/fakes.dart';

/// Throws on every load, like Firestore while offline.
class _FailingFirestoreService extends FakeFirestoreService {
  @override
  Future<RegistrationRecord?> fetchRegistration(String uid) async {
    throw const FirestoreException('Firestore is unavailable.');
  }
}

void main() {
  group('AuthController', () {
    test('maps the Firebase user to a profile', () {
      final auth = signedInAuth(uid: 'rider-7');
      expect(auth.isSignedIn, isTrue);
      expect(auth.uid, 'rider-7');
      expect(auth.user!.email, 'rider-7@example.com');
      expect(auth.user!.name, 'Ali Khan');
    });

    test(
      'refreshProfile merges the owner details stored in Firestore',
      () async {
        final firestore = FakeFirestoreService()
          ..storedProfile = {
            'cnic': '3520212345671',
            'phoneNumber': '03001234567',
          };
        final auth = signedInAuth(firestore: firestore);

        await auth.refreshProfile();

        expect(auth.user!.cnic, '3520212345671');
        expect(auth.user!.phoneNumber, '03001234567');
      },
    );

    test('signOut forgets the rider', () async {
      final auth = signedInAuth();
      await auth.signOut();
      expect(auth.isSignedIn, isFalse);
      expect(auth.user, isNull);
    });
  });

  group('RegistrationController', () {
    test('marks the card collected for the token that was issued', () async {
      final registration = await loadedRegistration(
        const RegistrationRecord(bike: testBike, token: testToken),
      );
      expect(registration.isReadyToCollectCard, isTrue);

      registration.markCardCollected(tokenNumber: 'TKN-0001');

      expect(registration.isCardCollected, isTrue);
      expect(registration.isReadyToCollectCard, isFalse);
      expect(registration.token!.generatedAt, testToken.generatedAt);
    });

    test('clear forgets the previous rider', () async {
      final registration = await loadedRegistration(
        const RegistrationRecord(bike: testBike, token: testToken),
      );
      registration.clear();
      expect(registration.bikeDetails, isNull);
      expect(registration.hasToken, isFalse);
    });

    test('a failed load leaves no stale data behind', () async {
      final registration = await loadedRegistration(
        const RegistrationRecord(bike: testBike, token: testToken),
        firestore: _FailingFirestoreService(),
      );
      expect(registration.hasToken, isFalse);
    });
  });
}
