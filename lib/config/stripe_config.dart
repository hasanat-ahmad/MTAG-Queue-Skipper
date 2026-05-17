// Stripe test mode settings (no secrets in this file).
// Copy stripe_config.local.dart.example → stripe_config.local.dart and add keys.
// Test card: 4242 4242 4242 4242 · any future expiry · any CVC · any ZIP

import 'stripe_config_stub.dart'
    if (dart.library.io) 'stripe_config.local.dart' as stripe_secrets;

class StripeConfig {
  StripeConfig._();

  static String get publishableKey =>
      stripe_secrets.StripeLocalSecrets.publishableKey;
  static String get secretKey => stripe_secrets.StripeLocalSecrets.secretKey;

  /// Registration fee in smallest currency unit (e.g. 500 = $5.00 USD).
  static const int amountCents = 500;
  static const String currency = 'usd';

  static bool get isConfigured =>
      publishableKey.trim().isNotEmpty && secretKey.trim().isNotEmpty;

  static String get formattedAmount {
    final major = amountCents / 100;
    if (currency.toLowerCase() == 'usd') {
      return '\$${major.toStringAsFixed(2)}';
    }
    return '$major ${currency.toUpperCase()}';
  }
}
