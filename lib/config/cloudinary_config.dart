/// Cloudinary unsigned upload settings.
///
/// Fill in your values below, then run the app normally (`flutter run`).
///
/// In [Cloudinary Dashboard](https://console.cloudinary.com):
/// 1. Copy **Cloud name** from the dashboard home page.
/// 2. Settings → Upload → Upload presets → Add preset → **Signing: Unsigned**.
/// 3. Paste the preset name into [uploadPreset].
class CloudinaryConfig {
  CloudinaryConfig._();

  static const String cloudName = 'dkccflpej';
  static const String uploadPreset = 'dkccflpej';

  static bool get isConfigured =>
      cloudName.trim().isNotEmpty && uploadPreset.trim().isNotEmpty;
}
