import 'package:mtag_queue_skipper/core/errors/app_exception.dart';
import 'package:mtag_queue_skipper/core/state/safe_change_notifier.dart';
import 'package:mtag_queue_skipper/data/services/cloudinary_service.dart';
import 'package:mtag_queue_skipper/data/services/face_verification_service.dart';
import 'package:mtag_queue_skipper/data/services/firestore_service.dart';
import 'package:mtag_queue_skipper/shared/camera/camera_capture_controller.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';

/// Captures the rider's reference selfie during registration and stores it
/// so their face can be matched when they collect the MTAG card.
class FaceEnrollmentController extends SafeChangeNotifier {
  FaceEnrollmentController({
    required AuthController auth,
    CameraCaptureController? camera,
    CloudinaryService? cloudinary,
    FirestoreService? firestore,
    FaceVerificationService? faceVerification,
  }) : _auth = auth,
       camera = camera ?? CameraCaptureController(),
       _cloudinary = cloudinary ?? CloudinaryService(),
       _firestore = firestore ?? FirestoreService(),
       _faceVerification =
           faceVerification ?? FaceVerificationService.instance {
    this.camera.addListener(notifyListeners);
  }

  final AuthController _auth;
  final CloudinaryService _cloudinary;
  final FirestoreService _firestore;
  final FaceVerificationService _faceVerification;

  /// Preview and capture state, shown by the screen's camera area.
  final CameraCaptureController camera;

  bool _isSaving = false;
  String? _error;

  bool get isSaving => _isSaving;

  /// Why the last save failed, shown under the camera.
  String? get error => _error;

  Future<void> startCamera() => camera.initialize();

  /// Takes the selfie. Returns a camera failure message, or null.
  Future<String?> capturePhoto() async {
    final failure = await camera.capture();
    if (failure == null) {
      _error = null;
      notifyListeners();
    }
    return failure;
  }

  void retake() {
    camera.retake();
    _error = null;
    notifyListeners();
  }

  /// Enrols the face for on-device matching, uploads the selfie and stores
  /// its URL on the rider's record. Returns true when the rider can move on
  /// to payment; otherwise [error] explains what went wrong.
  Future<bool> saveReferencePhoto() async {
    final photo = camera.photo;
    if (photo == null) return false;

    final uid = _auth.uid;
    if (uid == null) {
      _error = 'Please sign in to save your photo.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Enrol first: it rejects photos without exactly one face before
      // anything is uploaded or stored as the rider's reference.
      await _faceVerification.registerReferenceFace(
        uid: uid,
        imagePath: photo.path,
      );
      final bytes = await photo.readAsBytes();
      final imageUrl = await _cloudinary.uploadFacePhoto(bytes);
      await _firestore.saveFacePhotoUrl(uid: uid, facePhotoUrl: imageUrl);
      return true;
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _isSaving = false;
    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    camera.dispose();
    super.dispose();
  }
}
