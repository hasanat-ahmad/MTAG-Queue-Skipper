import 'dart:async';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mtag_queue_skipper/data/models/bike_details.dart';
import 'package:mtag_queue_skipper/data/models/card_collection_ticket.dart';
import 'package:mtag_queue_skipper/data/models/queue_token.dart';
import 'package:mtag_queue_skipper/data/models/registration_record.dart';
import 'package:mtag_queue_skipper/data/models/user_profile.dart';
import 'package:mtag_queue_skipper/data/services/auth_service.dart';
import 'package:mtag_queue_skipper/data/services/backend_service.dart';
import 'package:mtag_queue_skipper/data/services/face_verification_service.dart';
import 'package:mtag_queue_skipper/data/services/firestore_service.dart';
import 'package:mtag_queue_skipper/data/services/stripe_service.dart';
import 'package:mtag_queue_skipper/shared/camera/camera_capture_controller.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';

// In-memory stand-ins for the services, so controllers can be tested
// without Firebase, Stripe, Cloudinary or a camera. Each fake records the
// calls it receives and can be told to fail.

const testBike = BikeDetails(
  plateNumber: 'ICT-1234',
  engineNumber: 'E1234567',
  chassisNumber: 'C7654321',
  brand: 'Honda',
  color: 'Black',
  year: '2021',
);

const testToken = QueueToken(
  number: 'TKN-0001',
  status: 'Pending Verification',
  estimatedWait: '15-20 minutes',
  generatedAt: '2026-10-07T10:00:00.000Z',
);

class FakeFirebaseUser implements firebase_auth.User {
  FakeFirebaseUser({required this.uid, this.email, this.displayName});

  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthService implements AuthService {
  FakeAuthService({firebase_auth.User? currentUser})
    : _currentUser = currentUser;

  firebase_auth.User? _currentUser;
  final _changes = StreamController<firebase_auth.User?>.broadcast();

  /// The user the next successful sign-in returns.
  firebase_auth.User? nextUser;

  /// When set, the next sign-in attempt fails with this error.
  AuthException? nextError;

  @override
  firebase_auth.User? get currentUser => _currentUser;

  @override
  Stream<firebase_auth.User?> authStateChanges() => _changes.stream;

  Future<firebase_auth.User?> _signIn() async {
    final error = nextError;
    if (error != null) throw error;
    _currentUser = nextUser;
    return nextUser;
  }

  @override
  Future<firebase_auth.User?> signInWithEmail({
    required String email,
    required String password,
  }) => _signIn();

  @override
  Future<firebase_auth.User?> signUpWithEmail({
    required String email,
    required String password,
  }) => _signIn();

  @override
  Future<firebase_auth.User?> signInWithGoogle() => _signIn();

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeFirestoreService implements FirestoreService {
  /// Returned by [fetchRegistration].
  RegistrationRecord? registration;

  /// Returned by [getUserProfile].
  Map<String, dynamic>? storedProfile;

  /// Returned by [validateTokenForCollection] when [validationError] is null.
  CardCollectionTicket? ticket;
  FirestoreException? validationError;

  /// When set, saves fail with this error.
  FirestoreException? saveError;

  final List<String> fetchedRegistrationFor = [];
  final List<({UserProfile owner, BikeDetails bike})> savedRegistrations = [];
  final List<String> savedFacePhotoUrls = [];

  @override
  Future<RegistrationRecord?> fetchRegistration(String uid) async {
    fetchedRegistrationFor.add(uid);
    return registration;
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(String uid) async =>
      storedProfile;

  @override
  Future<void> saveOwnerAndBike({
    required UserProfile owner,
    required BikeDetails bike,
  }) async {
    final error = saveError;
    if (error != null) throw error;
    savedRegistrations.add((owner: owner, bike: bike));
  }

  @override
  Future<void> saveFacePhotoUrl({
    required String uid,
    required String facePhotoUrl,
  }) async {
    final error = saveError;
    if (error != null) throw error;
    savedFacePhotoUrls.add(facePhotoUrl);
  }

  @override
  Future<CardCollectionTicket> validateTokenForCollection({
    required String uid,
    required String tokenNumber,
  }) async {
    final error = validationError;
    if (error != null) throw error;
    return ticket!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeBackendService implements BackendService {
  final List<String> calls = [];

  PaymentIntentSession session = const PaymentIntentSession(
    paymentIntentId: 'pi_123',
    clientSecret: 'pi_123_secret',
  );
  QueueToken confirmedToken = testToken;

  BackendException? createPaymentIntentError;

  /// Errors thrown by the next confirmPayment calls, in order.
  final List<BackendException> confirmPaymentErrors = [];
  BackendException? issueCardError;

  @override
  Future<PaymentIntentSession> createPaymentIntent() async {
    calls.add('createPaymentIntent');
    final error = createPaymentIntentError;
    if (error != null) throw error;
    return session;
  }

  @override
  Future<QueueToken> confirmPayment(String paymentIntentId) async {
    calls.add('confirmPayment:$paymentIntentId');
    if (confirmPaymentErrors.isNotEmpty) throw confirmPaymentErrors.removeAt(0);
    return confirmedToken;
  }

  @override
  Future<void> issueMtagCard(String tokenNumber) async {
    calls.add('issueMtagCard:$tokenNumber');
    final error = issueCardError;
    if (error != null) throw error;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeStripeService implements StripeService {
  final List<String> presentedSecrets = [];

  /// When set, the Payment Sheet "fails" with this error.
  StripePaymentException? error;

  @override
  Future<void> presentPaymentSheet({required String clientSecret}) async {
    presentedSecrets.add(clientSecret);
    final failure = error;
    if (failure != null) throw failure;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeFaceVerificationService implements FaceVerificationService {
  bool isMatch = true;
  FaceVerificationException? error;
  final List<String> verifiedPaths = [];

  @override
  Future<FaceVerificationResult> verifyFaces({
    required String uid,
    required String storedImageUrl,
    required String liveImagePath,
  }) async {
    final failure = error;
    if (failure != null) throw failure;
    verifiedPaths.add(liveImagePath);
    return FaceVerificationResult(
      isMatch: isMatch,
      matchedUserId: isMatch ? uid : null,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Camera that "captures" a fixed path without touching any hardware.
class FakeCameraCaptureController extends CameraCaptureController {
  int initializeCalls = 0;
  XFile? _fakePhoto;

  @override
  XFile? get photo => _fakePhoto;

  @override
  Future<void> initialize() async {
    initializeCalls++;
  }

  @override
  Future<String?> capture() async {
    _fakePhoto = XFile('/tmp/test-selfie.jpg');
    notifyListeners();
    return null;
  }

  @override
  void retake() {
    _fakePhoto = null;
    notifyListeners();
  }
}

/// An [AuthController] whose rider [uid] is already signed in.
AuthController signedInAuth({
  String uid = 'rider-1',
  FakeFirestoreService? firestore,
}) {
  return AuthController(
    authService: FakeAuthService(
      currentUser: FakeFirebaseUser(
        uid: uid,
        email: '$uid@example.com',
        displayName: 'Ali Khan',
      ),
    ),
    firestoreService: firestore ?? FakeFirestoreService(),
  );
}

/// A [RegistrationController] loaded with [record] for [uid].
Future<RegistrationController> loadedRegistration(
  RegistrationRecord record, {
  String uid = 'rider-1',
  FakeFirestoreService? firestore,
}) async {
  final service = firestore ?? FakeFirestoreService();
  service.registration = record;
  final controller = RegistrationController(firestoreService: service);
  await controller.loadForUser(uid);
  return controller;
}
