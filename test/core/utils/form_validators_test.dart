import 'package:flutter_test/flutter_test.dart';
import 'package:mtag_queue_skipper/core/utils/form_validators.dart';

void main() {
  test('required rejects empty and whitespace-only input', () {
    expect(FormValidators.required(null), 'Required');
    expect(FormValidators.required('   '), 'Required');
    expect(FormValidators.required('ICT-1234'), isNull);
  });

  test('email accepts real addresses and rejects malformed ones', () {
    expect(FormValidators.email('rider@example.com'), isNull);
    expect(FormValidators.email('  rider@example.com.pk '), isNull);
    expect(FormValidators.email(''), 'Email is required');
    expect(FormValidators.email('rider@'), 'Enter a valid email address');
    expect(FormValidators.email('rider.example.com'), isNotNull);
  });

  test('existing passwords only need to be present', () {
    expect(FormValidators.existingPassword(''), 'Password is required');
    expect(FormValidators.existingPassword('x'), isNull);
  });

  test('new passwords need the Firebase minimum length', () {
    expect(FormValidators.newPassword('12345'), isNotNull);
    expect(FormValidators.newPassword('123456'), isNull);
  });
}
