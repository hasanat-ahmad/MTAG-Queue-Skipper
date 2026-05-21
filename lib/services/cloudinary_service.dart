import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:mtag_queue_skipper/config/cloudinary_config.dart';

class CloudinaryException implements Exception {
  CloudinaryException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class CloudinaryService {
  CloudinaryService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  void _ensureConfigured() {
    if (!CloudinaryConfig.isConfigured) {
      throw CloudinaryException(
        'Cloudinary is not configured. Copy lib/config/cloudinary_config.local.dart.example '
        'to cloudinary_config.local.dart and set cloudName and uploadPreset.',
        code: 'not-configured',
      );
    }
  }

  Future<String> uploadFacePhoto({
    required String uid,
    required Uint8List imageBytes,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw CloudinaryException(
        'You must be signed in to upload a photo.',
        code: 'unauthenticated',
      );
    }
    if (user.uid != uid) {
      throw CloudinaryException(
        'Session expired. Please sign in again.',
        code: 'uid-mismatch',
      );
    }

    _ensureConfigured();

    final cloudName = CloudinaryConfig.cloudName.trim();
    final uploadPreset = CloudinaryConfig.uploadPreset.trim();
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = 'mtag/users/$uid'
      ..fields['public_id'] = 'face'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'face.jpg',
        ),
      );

    try {
      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
        throw CloudinaryException(
          _parseErrorMessage(body) ??
              'Cloudinary upload failed (${streamed.statusCode}).',
          code: 'upload-failed',
        );
      }

      final json = jsonDecode(body) as Map<String, dynamic>;
      final url = json['secure_url'] as String? ?? json['url'] as String?;
      if (url == null || url.isEmpty) {
        throw CloudinaryException(
          'Cloudinary did not return an image URL.',
          code: 'missing-url',
        );
      }
      return url;
    } on CloudinaryException {
      rethrow;
    } catch (e) {
      throw CloudinaryException(e.toString());
    }
  }

  String? _parseErrorMessage(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['error']?['message'] as String?;
    } catch (_) {
      return null;
    }
  }
}
