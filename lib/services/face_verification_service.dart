import 'dart:io';

import 'package:face_verification/face_verification.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FaceVerificationException implements Exception {
  FaceVerificationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FaceVerificationResult {
  const FaceVerificationResult({
    required this.isMatch,
    required this.matchedUserId,
  });

  final bool isMatch;
  final String? matchedUserId;
}

/// On-device face identity checks using FaceNet-style embeddings (TFLite).
class FaceVerificationService {
  FaceVerificationService._();

  static final FaceVerificationService instance = FaceVerificationService._();

  static const String _referenceImageId = 'registration';

  /// Stricter than the plugin default (0.70).
  static const double _matchThreshold = 0.80;

  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (kIsWeb) {
      throw FaceVerificationException(
        'Face verification is not supported on web. Use a mobile device.',
      );
    }
    await FaceVerification.instance.init();
    _initialized = true;
  }

  Future<bool> _isReferenceEnrolled(String uid) async {
    return FaceVerification.instance.isFaceRegisteredWithImageId(
      uid,
      _referenceImageId,
    );
  }

  /// Enrolls or replaces the reference face for [uid].
  Future<void> registerReferenceFace({
    required String uid,
    required String imagePath,
  }) async {
    await ensureInitialized();
    final file = File(imagePath);
    if (!await file.exists()) {
      throw FaceVerificationException('Reference photo file was not found.');
    }

    try {
      await _enrollReferenceFace(uid: uid, imagePath: imagePath);
    } catch (e) {
      final message = e.toString();
      if (message.toLowerCase().contains('multiple faces')) {
        throw FaceVerificationException(
          'Multiple faces detected. Use a photo with only your face visible.',
        );
      }
      throw FaceVerificationException(
        'Could not save your face photo for verification. $message',
      );
    }
  }

  /// Compares [liveImagePath] to the reference enrolled at registration.
  /// Re-downloads from [storedImageUrl] only if this device has no enrollment yet.
  Future<FaceVerificationResult> verifyFaces({
    required String uid,
    required String storedImageUrl,
    required String liveImagePath,
  }) async {
    await ensureInitialized();

    final liveFile = File(liveImagePath);
    if (!await liveFile.exists()) {
      throw FaceVerificationException('Live photo file was not found.');
    }

    try {
      final enrolled = await _isReferenceEnrolled(uid);
      if (!enrolled) {
        final storedPath = await _downloadToTempFile(storedImageUrl);
        try {
          await _enrollReferenceFace(uid: uid, imagePath: storedPath);
        } finally {
          final storedFile = File(storedPath);
          if (await storedFile.exists()) {
            await storedFile.delete();
          }
        }
      }

      final matchedId =
          await FaceVerification.instance.verifyFromImagePathIsolate(
        imagePath: liveImagePath,
        threshold: _matchThreshold,
        staffId: uid,
      );

      debugPrint(
        'Face verify uid=$uid matchedId=$matchedId threshold=$_matchThreshold',
      );

      return FaceVerificationResult(
        isMatch: matchedId == uid,
        matchedUserId: matchedId,
      );
    } catch (e) {
      if (e is FaceVerificationException) rethrow;
      final message = e.toString();
      if (message.toLowerCase().contains('multiple faces')) {
        throw FaceVerificationException(
          'Multiple faces detected. Only one person should be in the frame.',
        );
      }
      if (message.toLowerCase().contains('no face')) {
        throw FaceVerificationException(
          'No face detected. Center your face and try again.',
        );
      }
      throw FaceVerificationException('Face verification failed. $message');
    }
  }

  /// Plugin throws if (id, imageId) exists even when replace=true — delete first.
  Future<void> _enrollReferenceFace({
    required String uid,
    required String imagePath,
  }) async {
    final exists = await _isReferenceEnrolled(uid);
    if (exists) {
      await FaceVerification.instance.deleteFaceRecord(uid, _referenceImageId);
    }

    await FaceVerification.instance.registerFromImagePath(
      id: uid,
      imagePath: imagePath,
      imageId: _referenceImageId,
      replace: true,
    );
  }

  Future<String> _downloadToTempFile(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FaceVerificationException(
        'Could not download your stored photo. Please try again.',
      );
    }
    if (response.bodyBytes.isEmpty) {
      throw FaceVerificationException('Stored photo is empty or invalid.');
    }

    final file = File(
      '${Directory.systemTemp.path}/mtag_ref_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }
}
