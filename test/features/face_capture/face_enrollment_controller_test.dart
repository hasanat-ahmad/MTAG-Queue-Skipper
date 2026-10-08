import 'package:flutter_test/flutter_test.dart';
import 'package:mtag_queue_skipper/data/services/cloudinary_service.dart';
import 'package:mtag_queue_skipper/features/face_capture/face_enrollment_controller.dart';

import '../../helpers/fakes.dart';

void main() {
  test('opening the camera also starts loading the face model', () async {
    final firestore = FakeFirestoreService();
    final faces = FakeFaceVerificationService();
    final camera = FakeCameraCaptureController();
    final controller = FaceEnrollmentController(
      auth: signedInAuth(firestore: firestore),
      camera: camera,
      cloudinary: CloudinaryService(backend: FakeBackendService()),
      firestore: firestore,
      faceVerification: faces,
    );

    await controller.startCamera();

    expect(camera.initializeCalls, 1);
    expect(faces.warmUpCalls, 1);
  });
}
