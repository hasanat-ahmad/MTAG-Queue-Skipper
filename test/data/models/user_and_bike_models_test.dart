import 'package:flutter_test/flutter_test.dart';
import 'package:mtag_queue_skipper/data/models/bike_details.dart';
import 'package:mtag_queue_skipper/data/models/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('derives first name and initials from the name', () {
      const profile = UserProfile(uid: 'u1', name: '  Ali   Raza Khan ');
      expect(profile.hasName, isTrue);
      expect(profile.firstName, 'Ali');
      expect(profile.initials, 'AR');
    });

    test('has sensible fallbacks without a name', () {
      const profile = UserProfile(uid: 'u1');
      expect(profile.firstName, 'User');
      expect(profile.initials, '?');
    });

    test(
      'merges stored owner details, keeping the name when blank and the auth e-mail',
      () {
        const profile = UserProfile(uid: 'u1', name: 'Ali', email: 'a@b.co');
        final merged = profile.mergeStoredProfile({
          'name': '   ',
          'cnic': '3520212345671',
          'phoneNumber': '03001234567',
          'email': 'stale@example.com',
        });
        expect(merged.name, 'Ali');
        expect(merged.cnic, '3520212345671');
        expect(merged.phoneNumber, '03001234567');
        expect(merged.email, 'a@b.co');
      },
    );

    test('toString leaves out CNIC and phone number', () {
      const profile = UserProfile(
        uid: 'u1',
        cnic: '3520212345671',
        phoneNumber: '03001234567',
      );
      expect(profile.toString(), isNot(contains('3520212345671')));
      expect(profile.toString(), isNot(contains('03001234567')));
    });
  });

  group('BikeDetails', () {
    const bike = BikeDetails(
      plateNumber: 'ICT-1234',
      engineNumber: 'E1',
      chassisNumber: 'C1',
      brand: 'Honda',
      color: 'Black',
      year: '2021',
    );

    test('stores engine and chassis under their legacy keys', () {
      final map = bike.toMap();
      expect(map['engineNo'], 'E1');
      expect(map['chasisNumber'], 'C1');
      expect(BikeDetails.fromMap(map), bike);
    });

    test('ignores values of the wrong type', () {
      final parsed = BikeDetails.fromMap({'plateNumber': 7, 'year': 2021});
      expect(parsed.plateNumber, '');
      expect(parsed.year, '');
    });
  });
}
