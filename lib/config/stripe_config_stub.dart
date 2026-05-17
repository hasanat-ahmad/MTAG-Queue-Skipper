/// Default empty Stripe secrets (used when [stripe_config.local.dart] is absent).
class StripeLocalSecrets {
  StripeLocalSecrets._();

  static const String publishableKey = '';
  static const String secretKey = '';
}
