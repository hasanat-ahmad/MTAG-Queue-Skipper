import 'package:flutter_test/flutter_test.dart';
import 'package:mtag_queue_skipper/data/models/queue_token.dart';
import 'package:mtag_queue_skipper/data/models/registration_record.dart';

void main() {
  final bikeMap = {
    'plateNumber': 'ICT-1234',
    'engineNo': 'E1234567',
    'chasisNumber': 'C7654321',
    'brand': 'Honda',
    'color': 'Black',
    'year': '2021',
  };

  test('parses the bike and token from the user document', () {
    final record = RegistrationRecord.fromUserDocument({
      'name': 'Ali Khan',
      'bikeRegistration': {
        'bikeDetails': bikeMap,
        'tokenNumber': 'TKN-0001',
        'tokenStatus': 'Pending Verification',
      },
    });

    expect(record.bike?.plateNumber, 'ICT-1234');
    expect(record.bike?.chassisNumber, 'C7654321');
    expect(record.token?.number, 'TKN-0001');
    expect(record.hasToken, isTrue);
    expect(record.isCardCollected, isFalse);
  });

  test('an issued card marks the token as collected', () {
    final record = RegistrationRecord.fromUserDocument({
      'bikeRegistration': {
        'bikeDetails': bikeMap,
        'tokenNumber': 'TKN-0001',
        'tokenStatus': 'Pending Verification',
      },
      'mtagCard': {'issued': true},
    });

    expect(record.cardIssued, isTrue);
    expect(record.isCardCollected, isTrue);
    expect(record.token?.statusLabel, QueueToken.collectedStatus);
  });

  test('a registration without a token yet has only the bike', () {
    final record = RegistrationRecord.fromUserDocument({
      'bikeRegistration': {'bikeDetails': bikeMap},
    });
    expect(record.bike, isNotNull);
    expect(record.hasToken, isFalse);
  });

  test('tolerates missing or malformed fields', () {
    expect(RegistrationRecord.fromUserDocument({}), RegistrationRecord.empty);
    final record = RegistrationRecord.fromUserDocument({
      'bikeRegistration': 'not a map',
      'mtagCard': ['also wrong'],
    });
    expect(record.bike, isNull);
    expect(record.token, isNull);
    expect(record.cardIssued, isFalse);
  });
}
