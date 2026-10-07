// Stripe settings the app needs: only the publishable key, which is safe to
// ship. The secret key lives on the server (functions/, Secret Manager) and
// must never be added to the app.
//
// Copy stripe_config.local.dart.example -> stripe_config.local.dart and add
// your publishable key.
// Test card: 4242 4242 4242 4242 · any future expiry · any CVC · any ZIP

import 'stripe_config_stub.dart'
    if (dart.library.io) 'stripe_config.local.dart'
    as stripe_keys;

class StripeConfig {
  StripeConfig._();

  static String get publishableKey =>
      stripe_keys.StripeLocalSecrets.publishableKey;

  /// Registration fee in the smallest currency unit (500 = $5.00), shown on
  /// the payment screen. The amount actually charged is set server-side in
  /// functions/src/config.ts; keep the two in sync.
  static const int amountCents = 500;
  static const String currency = 'usd';

  static bool get isConfigured => publishableKey.trim().isNotEmpty;

  static String get formattedAmount {
    final major = amountCents / 100;
    if (currency.toLowerCase() == 'usd') {
      return '\$${major.toStringAsFixed(2)}';
    }
    return '$major ${currency.toUpperCase()}';
  }
}
