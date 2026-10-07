/// Empty Stripe key for builds without dart:io (web); mobile builds import
/// stripe_config.local.dart instead.
class StripeLocalSecrets {
  StripeLocalSecrets._();

  static const String publishableKey = '';
}
