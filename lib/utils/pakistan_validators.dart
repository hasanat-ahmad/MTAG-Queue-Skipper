/// Validators for Pakistani CNIC and mobile numbers.
class PakistanValidators {
  PakistanValidators._();

  static final RegExp _cnicDigits = RegExp(r'^\d{13}$');
  static final RegExp _mobileLocal = RegExp(r'^03\d{9}$');

  static String digitsOnly(String value) =>
      value.replaceAll(RegExp(r'\D'), '');

  /// Normalizes to 11-digit local mobile: `03XXXXXXXXX`.
  static String normalizePhone(String value) {
    var digits = digitsOnly(value);
    if (digits.startsWith('92') && digits.length == 12) {
      digits = '0${digits.substring(2)}';
    }
    return digits;
  }

  /// Normalizes to 13-digit CNIC without dashes.
  static String normalizeCnic(String value) => digitsOnly(value);

  static String? validateCnic(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'CNIC is required' : null;
    }

    final digits = normalizeCnic(value);
    if (!_cnicDigits.hasMatch(digits)) {
      return 'CNIC must be 13 digits (e.g. 35202-1234567-1)';
    }

    // First digit is province / area code (1–7).
    final first = int.tryParse(digits[0]);
    if (first == null || first < 1 || first > 7) {
      return 'Enter a valid Pakistani CNIC';
    }

    return null;
  }

  static String? validatePhone(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Phone number is required' : null;
    }

    final normalized = normalizePhone(value);
    if (!_mobileLocal.hasMatch(normalized)) {
      return 'Use a Pakistani mobile number (e.g. 03001234567)';
    }

    return null;
  }
}
