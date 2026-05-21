// Cloudinary unsigned upload settings (no secrets in this file).
// Copy cloudinary_config.local.dart.example → cloudinary_config.local.dart and add values.

import 'cloudinary_config_stub.dart'
    if (dart.library.io) 'cloudinary_config.local.dart' as cloudinary_secrets;

class CloudinaryConfig {
  CloudinaryConfig._();

  static String get cloudName =>
      cloudinary_secrets.CloudinaryLocalSecrets.cloudName;
  static String get uploadPreset =>
      cloudinary_secrets.CloudinaryLocalSecrets.uploadPreset;

  static bool get isConfigured =>
      cloudName.trim().isNotEmpty && uploadPreset.trim().isNotEmpty;
}
