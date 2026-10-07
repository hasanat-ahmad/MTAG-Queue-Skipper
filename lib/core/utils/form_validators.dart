/// Validators for the login and sign-up forms. Each returns an error
/// message, or null when the value is valid, as [FormField.validator]
/// expects.
class FormValidators {
  FormValidators._();

  static final RegExp _email = RegExp(
    r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@'
    r'((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|'
    r'(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  );

  /// Firebase Auth rejects shorter passwords.
  static const int minPasswordLength = 6;

  /// Rejects empty or whitespace-only input.
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_email.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// For signing in: any non-empty password; Firebase checks it.
  static String? existingPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  /// For signing up: enforces the minimum length up front.
  static String? newPassword(String? value) {
    if (value == null || value.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }
    return null;
  }
}
