import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
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
    required this.similarityScore,
  });

  final bool isMatch;
  final double similarityScore;
}

/// Compares two face photos using ML Kit face detection and landmark geometry.
class FaceVerificationService {
  FaceVerificationService({FaceDetector? detector})
      : _detector = detector ??
            FaceDetector(
              options: FaceDetectorOptions(
                enableLandmarks: true,
                enableContours: false,
                enableClassification: false,
                performanceMode: FaceDetectorMode.accurate,
                minFaceSize: 0.15,
              ),
            );

  final FaceDetector _detector;

  /// Minimum cosine similarity (0–1) to treat faces as a match.
  static const double matchThreshold = 0.72;

  Future<FaceVerificationResult> verifyFaces({
    required String storedImageUrl,
    required String liveImagePath,
  }) async {
    if (kIsWeb) {
      throw FaceVerificationException(
        'Face verification is not supported on web. Use a mobile device.',
      );
    }

    final storedPath = await _downloadToTempFile(storedImageUrl);
    try {
      final storedFeatures = await _extractFeaturesFromPath(storedPath);
      final liveFeatures = await _extractFeaturesFromPath(liveImagePath);

      final score = _cosineSimilarity(storedFeatures, liveFeatures);
      return FaceVerificationResult(
        isMatch: score >= matchThreshold,
        similarityScore: score,
      );
    } finally {
      final storedFile = File(storedPath);
      if (await storedFile.exists()) {
        await storedFile.delete();
      }
    }
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
      '${Directory.systemTemp.path}/mtag_stored_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  Future<List<double>> _extractFeaturesFromPath(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    return _extractFeatures(inputImage);
  }

  Future<List<double>> _extractFeatures(InputImage inputImage) async {
    final faces = await _detector.processImage(inputImage);
    if (faces.isEmpty) {
      throw FaceVerificationException(
        'No face detected. Use a clear, front-facing photo.',
      );
    }

    final face = _largestFace(faces);
    return _landmarkFeatureVector(face);
  }

  Face _largestFace(List<Face> faces) {
    faces.sort((a, b) {
      final aArea = a.boundingBox.width * a.boundingBox.height;
      final bArea = b.boundingBox.width * b.boundingBox.height;
      return bArea.compareTo(aArea);
    });
    return faces.first;
  }

  List<double> _landmarkFeatureVector(Face face) {
    final leftEye = face.landmarks[FaceLandmarkType.leftEye]?.position;
    final rightEye = face.landmarks[FaceLandmarkType.rightEye]?.position;
    final nose = face.landmarks[FaceLandmarkType.noseBase]?.position;

    if (leftEye == null || rightEye == null || nose == null) {
      throw FaceVerificationException(
        'Face landmarks were incomplete. Ensure your full face is visible.',
      );
    }

    final eyeMidX = (leftEye.x + rightEye.x) / 2;
    final eyeMidY = (leftEye.y + rightEye.y) / 2;
    final eyeDistance = math.sqrt(
      math.pow(rightEye.x - leftEye.x, 2) + math.pow(rightEye.y - leftEye.y, 2),
    );
    if (eyeDistance < 1) {
      throw FaceVerificationException('Face is too small in the image.');
    }

    final types = [
      FaceLandmarkType.leftEye,
      FaceLandmarkType.rightEye,
      FaceLandmarkType.noseBase,
      FaceLandmarkType.leftMouth,
      FaceLandmarkType.rightMouth,
      FaceLandmarkType.bottomMouth,
      FaceLandmarkType.leftCheek,
      FaceLandmarkType.rightCheek,
    ];

    final features = <double>[];
    for (final type in types) {
      final point = face.landmarks[type]?.position;
      if (point == null) continue;
      features.addAll([
        (point.x - eyeMidX) / eyeDistance,
        (point.y - eyeMidY) / eyeDistance,
      ]);
    }

    if (features.length < 8) {
      throw FaceVerificationException(
        'Not enough facial landmarks detected. Improve lighting and retry.',
      );
    }

    return features;
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    final length = math.min(a.length, b.length);
    if (length == 0) return 0;

    var dot = 0.0;
    var normA = 0.0;
    var normB = 0.0;
    for (var i = 0; i < length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0 || normB == 0) return 0;
    return dot / (math.sqrt(normA) * math.sqrt(normB));
  }

  Future<void> dispose() => _detector.close();
}
