import 'dart:async';
import 'dart:io';

import 'package:face_verification/face_verification.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mtag_queue_skipper/core/errors/app_exception.dart';
import 'package:mtag_queue_skipper/core/errors/build_aware_message.dart';

class FaceVerificationException extends AppException {
  const FaceVerificationException(super.message);
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

  /// The model load in progress or done; null until first needed, and
  /// again after a load fails so the next call retries.
  Future<void>? _loading;

  /// Loads the FaceNet model (about 94 MB) the first time it is needed.
  /// Callers that arrive while it is loading wait for the same load
  /// instead of starting another one.
  Future<void> ensureInitialized() async {
    final loading = _loading ??= _loadModel();
    try {
      await loading;
    } catch (_) {
      if (identical(_loading, loading)) _loading = null;
      rethrow;
    }
  }

  /// Starts loading the model in the background, e.g. while the camera
  /// opens, so it is ready by the time the rider has taken a selfie.
  /// Failures are only logged here; the next [ensureInitialized] retries
  /// and reports them.
  void warmUp() {
    if (kIsWeb) return;
    unawaited(
      ensureInitialized().catchError((Object error) {
        debugPrint('Face model warm-up failed: $error');
      }),
    );
  }

  Future<void> _loadModel() async {
    if (kIsWeb) {
      throw const FaceVerificationException(
        'Face verification is not supported on web. Use a mobile device.',
      );
    }
    await FaceVerification.instance.init();
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
      throw _explain(
        e,
        fallback: 'Could not save your face photo for verification.',
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

      final matchedId = await FaceVerification.instance
          .verifyFromImagePathIsolate(
            imagePath: liveImagePath,
            threshold: _matchThreshold,
            staffId: uid,
          );

      if (kDebugMode) {
        debugPrint(
          'Face verify uid=$uid matchedId=$matchedId threshold=$_matchThreshold',
        );
      }

      return FaceVerificationResult(
        isMatch: matchedId == uid,
        matchedUserId: matchedId,
      );
    } catch (e) {
      if (e is FaceVerificationException) rethrow;
      throw _explain(
        e,
        fallback: 'Face verification failed. Please try again.',
      );
    }
  }

  /// Turns a face plugin error into a message for the rider. Raw plugin
  /// details are only included in debug builds.
  FaceVerificationException _explain(Object error, {required String fallback}) {
    final message = error.toString().toLowerCase();
    if (message.contains('multiple faces')) {
      return const FaceVerificationException(
        'Multiple faces detected. Only your face should be in the photo.',
      );
    }
    if (message.contains('no face')) {
      return const FaceVerificationException(
        'No face detected. Center your face in the oval and try again.',
      );
    }
    return FaceVerificationException(
      buildAwareMessage(rider: fallback, developer: '$fallback $error'),
    );
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
