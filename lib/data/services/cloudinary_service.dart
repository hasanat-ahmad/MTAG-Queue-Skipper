import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:mtag_queue_skipper/core/errors/app_exception.dart';
import 'package:mtag_queue_skipper/data/services/backend_service.dart';

class CloudinaryException extends AppException {
  const CloudinaryException(super.message, {super.code});
}

/// Uploads the rider's reference selfie to Cloudinary.
///
/// Every upload is signed by the server (createFaceUploadSignature) and
/// restricted to the rider's own `mtag/users/{uid}/face` image, so the app
/// holds no Cloudinary secret and no unsigned upload preset is needed.
class CloudinaryService {
  CloudinaryService({BackendService? backend})
    : _backend = backend ?? BackendService();

  final BackendService _backend;

  /// Uploads [imageBytes] and returns its HTTPS delivery URL.
  Future<String> uploadFacePhoto(Uint8List imageBytes) async {
    final upload = await _backend.createFaceUploadSignature();
    final request =
        http.MultipartRequest(
            'POST',
            Uri.https(
              'api.cloudinary.com',
              '/v1_1/${upload.cloudName}/image/upload',
            ),
          )
          ..fields.addAll(upload.params)
          ..fields['api_key'] = upload.apiKey
          ..fields['signature'] = upload.signature
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
      final url = json['secure_url'] as String?;
      if (url == null || url.isEmpty) {
        throw const CloudinaryException(
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
