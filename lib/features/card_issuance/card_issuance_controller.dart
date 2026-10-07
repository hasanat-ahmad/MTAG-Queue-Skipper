import 'package:mtag_queue_skipper/core/errors/app_exception.dart';
import 'package:mtag_queue_skipper/core/state/safe_change_notifier.dart';
import 'package:mtag_queue_skipper/data/models/card_collection_ticket.dart';
import 'package:mtag_queue_skipper/data/services/backend_service.dart';
import 'package:mtag_queue_skipper/data/services/face_verification_service.dart';
import 'package:mtag_queue_skipper/data/services/firestore_service.dart';
import 'package:mtag_queue_skipper/shared/camera/camera_capture_controller.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';

/// The three steps of collecting an MTAG card.
enum CardIssuanceStep {
  /// The rider types their queue token.
  enterToken,

  /// The rider takes a selfie that is matched against the reference photo.
  verifyFace,

  /// The card has been issued.
  issued,
}

/// Drives MTAG card collection: check the token, match the rider's face
/// against their registration photo, then issue the card.
class CardIssuanceController extends SafeChangeNotifier {
  CardIssuanceController({
    required AuthController auth,
    required RegistrationController registration,
    CameraCaptureController? camera,
    BackendService? backend,
    FirestoreService? firestore,
    FaceVerificationService? faceVerification,
  }) : _auth = auth,
       _registration = registration,
       camera = camera ?? CameraCaptureController(),
       _backend = backend ?? BackendService(),
       _firestore = firestore ?? FirestoreService(),
       _faceVerification =
           faceVerification ?? FaceVerificationService.instance {
    this.camera.addListener(notifyListeners);
  }

  final AuthController _auth;
  final RegistrationController _registration;
  final BackendService _backend;
  final FirestoreService _firestore;
  final FaceVerificationService _faceVerification;

  /// Selfie preview and capture for [CardIssuanceStep.verifyFace].
  final CameraCaptureController camera;

  CardIssuanceStep _step = CardIssuanceStep.enterToken;
  CardCollectionTicket? _ticket;
  bool _isBusy = false;
  String? _error;

  CardIssuanceStep get step => _step;

  /// Set once the token has been accepted.
  CardCollectionTicket? get ticket => _ticket;

  /// True while checking the token or verifying the face.
  bool get isBusy => _isBusy;

  /// Why the current step failed, shown on the page.
  String? get error => _error;

  /// The rider's own token, used to pre-fill the token field.
  String? get suggestedToken => _registration.token?.number;

  /// Step 1: checks [tokenNumber] against the rider's registration and, if
  /// it is valid, opens the camera for the face check. The server repeats
  /// these checks when issuing the card; doing them here first saves the
  /// rider a selfie that would be rejected anyway.
  Future<void> submitToken(String tokenNumber) async {
    final uid = _auth.uid;
    if (uid == null) {
      _fail('Please sign in to collect your MTAG card.');
      return;
    }

    _isBusy = true;
    _error = null;
    notifyListeners();

    try {
      _ticket = await _firestore.validateTokenForCollection(
        uid: uid,
        tokenNumber: tokenNumber.trim(),
      );
      _step = CardIssuanceStep.verifyFace;
      _isBusy = false;
      notifyListeners();
      await camera.initialize();
    } on AppException catch (e) {
      _fail(e.message);
    } catch (e) {
      _fail(e.toString());
    }
  }

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

  /// Step 2: matches the selfie against the registration photo on the
  /// device and, on a match, asks the server to issue the card.
  Future<void> verifyAndIssue() async {
    final ticket = _ticket;
    final photo = camera.photo;
    if (ticket == null || photo == null) return;

    _isBusy = true;
    _error = null;
    notifyListeners();

    try {
      final verification = await _faceVerification.verifyFaces(
        uid: ticket.uid,
        storedImageUrl: ticket.facePhotoUrl,
        liveImagePath: photo.path,
      );
      if (!verification.isMatch) {
        _fail(
          'Face did not match your registration photo. Please try again with better lighting.',
        );
        return;
      }

      await _backend.issueMtagCard(ticket.tokenNumber);
      _registration.markCardCollected(tokenNumber: ticket.tokenNumber);
      _step = CardIssuanceStep.issued;
      _isBusy = false;
      notifyListeners();
    } on AppException catch (e) {
      _fail(e.message);
    } catch (e) {
      _fail(e.toString());
    }
  }

  void _fail(String message) {
    _isBusy = false;
    _error = message;
    notifyListeners();
  }

  @override
  void dispose() {
    camera.dispose();
    super.dispose();
  }
}
