import 'package:flutter_test/flutter_test.dart';
import 'package:mtag_queue_skipper/core/utils/pakistan_validators.dart';

void main() {
  group('phone numbers', () {
    test('normalise to the 11-digit local format', () {
      expect(PakistanValidators.normalizePhone('0300-1234567'), '03001234567');
      expect(PakistanValidators.normalizePhone('923001234567'), '03001234567');
      expect(
        PakistanValidators.normalizePhone('+92 300 1234567'),
        '03001234567',
      );
    });

    test('accept Pakistani mobile numbers', () {
      expect(PakistanValidators.validatePhone('03001234567'), isNull);
      expect(PakistanValidators.validatePhone('+923001234567'), isNull);
    });

    test('reject anything else', () {
      expect(PakistanValidators.validatePhone(''), 'Phone number is required');
      expect(PakistanValidators.validatePhone('3001234567'), isNotNull);
      expect(PakistanValidators.validatePhone('0421234567'), isNotNull);
      expect(PakistanValidators.validatePhone('030012345678'), isNotNull);
    });

    test('may be optional', () {
      expect(PakistanValidators.validatePhone('', required: false), isNull);
    });
  });

  group('CNIC', () {
    test('normalises to 13 digits without dashes', () {
      expect(
        PakistanValidators.normalizeCnic('35202-1234567-1'),
        '3520212345671',
      );
    });

    test('accepts 13 digits starting with a province code 1-7', () {
      expect(PakistanValidators.validateCnic('35202-1234567-1'), isNull);
      expect(PakistanValidators.validateCnic('1520212345671'), isNull);
    });

    test('rejects wrong lengths and province codes', () {
      expect(PakistanValidators.validateCnic(null), 'CNIC is required');
      expect(PakistanValidators.validateCnic('352021234567'), isNotNull);
      expect(
        PakistanValidators.validateCnic('8520212345671'),
        'Enter a valid Pakistani CNIC',
      );
      expect(PakistanValidators.validateCnic('0520212345671'), isNotNull);
    });
  });
}
