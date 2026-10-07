/// Where the app's Cloud Functions (functions/) are deployed.
class BackendConfig {
  BackendConfig._();

  /// Must match `REGION` in functions/src/config.ts.
  static const String functionsRegion = 'us-central1';
}
