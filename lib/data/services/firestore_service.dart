import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mtag_queue_skipper/core/errors/app_exception.dart';
import 'package:mtag_queue_skipper/data/models/bike_details.dart';
import 'package:mtag_queue_skipper/data/models/card_collection_ticket.dart';
import 'package:mtag_queue_skipper/data/models/registration_record.dart';
import 'package:mtag_queue_skipper/data/models/user_profile.dart';

class FirestoreException extends AppException {
  const FirestoreException(super.message, {super.code});
}

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _users.doc(uid);

  /// Guards against reading or writing another rider's document. Security
  /// rules enforce the same thing server-side; this gives a clearer error.
  String _requireMatchingUid(String uid) {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirestoreException(
        'You must be signed in to save data.',
        code: 'unauthenticated',
      );
    }

    if (user.uid != uid) {
      throw FirestoreException(
        'Session expired. Please sign in again.',
        code: 'uid-mismatch',
      );
    }

    return user.uid;
  }

  Never _rethrowAsFirestoreException(Object error) {
    if (error is FirestoreException) {
      throw error;
    }
    if (error is FirebaseException) {
      throw FirestoreException(_friendlyMessage(error), code: error.code);
    }
    throw FirestoreException(error.toString());
  }

  String _friendlyMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Firestore permission denied. Enable Firestore in Firebase Console '
            'and publish security rules that allow signed-in users to write their '
            'own document at users/{uid}.';
      case 'unavailable':
        return 'Firestore is unavailable. Check your internet connection.';
      case 'not-found':
        return 'Firestore database not found. Create a Firestore database in '
            'Firebase Console.';
      default:
        return error.message ?? 'Firestore error: ${error.code}';
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      _requireMatchingUid(uid);
      final snapshot = await _userDoc(uid).get();
      if (!snapshot.exists) return null;
      return snapshot.data();
    } on FirestoreException {
      rethrow;
    } catch (e) {
      _rethrowAsFirestoreException(e);
    }
  }

  /// Saves the owner details and the bike in one write.
  ///
  /// `bikeRegistration.bikeDetails` is replaced as a whole (`mergeFields`),
  /// which also drops owner fields that older app versions stored inside
  /// it. Queue token, payment and card fields belong to the Cloud Functions
  /// and are never written from the app (see firestore.rules).
  Future<void> saveOwnerAndBike({
    required UserProfile owner,
    required BikeDetails bike,
  }) async {
    try {
      final verifiedUid = _requireMatchingUid(owner.uid);
      await _userDoc(verifiedUid).set(
        {
          'email': owner.email,
          'name': owner.name,
          'cnic': owner.cnic,
          'phoneNumber': owner.phoneNumber,
          'bikeRegistration': {'bikeDetails': bike.toMap()},
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(
          mergeFields: [
            'email',
            'name',
            'cnic',
            'phoneNumber',
            'updatedAt',
            'bikeRegistration.bikeDetails',
          ],
        ),
      );
    } catch (e) {
      _rethrowAsFirestoreException(e);
    }
  }

  Future<void> saveFacePhotoUrl({
    required String uid,
    required String facePhotoUrl,
  }) async {
    try {
      final verifiedUid = _requireMatchingUid(uid);
      await _userDoc(verifiedUid).set({
        'facePhotoUrl': facePhotoUrl,
        'facePhotoCapturedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      _rethrowAsFirestoreException(e);
    }
  }

  /// Validates [tokenNumber] for the signed-in user and returns profile data
  /// needed for MTAG card collection.
  Future<CardCollectionTicket> validateTokenForCollection({
    required String uid,
    required String tokenNumber,
  }) async {
    try {
      final verifiedUid = _requireMatchingUid(uid);
      final normalizedToken = tokenNumber.trim();
      if (normalizedToken.isEmpty) {
        throw FirestoreException('Please enter your token number.');
      }

      final snapshot = await _userDoc(verifiedUid).get();
      if (!snapshot.exists) {
        throw FirestoreException('No registration found for your account.');
      }

      final data = snapshot.data() ?? <String, dynamic>{};
      final bikeReg = data['bikeRegistration'];
      final bikeMap = bikeReg is Map<String, dynamic>
          ? bikeReg
          : bikeReg is Map
          ? Map<String, dynamic>.from(bikeReg)
          : <String, dynamic>{};

      final storedToken = (bikeMap['tokenNumber'] as String? ?? '').trim();
      if (storedToken.isEmpty) {
        throw FirestoreException(
          'No token found on your account. Complete registration first.',
        );
      }
      if (storedToken != normalizedToken) {
        throw FirestoreException(
          'Token number does not match your registration.',
        );
      }

      final payment = data['payment'];
      final paymentMap = payment is Map<String, dynamic>
          ? payment
          : payment is Map
          ? Map<String, dynamic>.from(payment)
          : <String, dynamic>{};
      final paymentStatus = paymentMap['status'] as String? ?? '';
      if (paymentStatus != 'paid') {
        throw FirestoreException(
          'Payment is required before collecting your MTAG card.',
        );
      }

      final mtagCard = data['mtagCard'];
      final mtagMap = mtagCard is Map<String, dynamic>
          ? mtagCard
          : mtagCard is Map
          ? Map<String, dynamic>.from(mtagCard)
          : <String, dynamic>{};
      if (mtagMap['issued'] == true) {
        throw FirestoreException('Your MTAG card has already been issued.');
      }

      final facePhotoUrl = data['facePhotoUrl'] as String? ?? '';
      if (facePhotoUrl.trim().isEmpty) {
        throw FirestoreException(
          'No registration photo on file. Complete face verification first.',
        );
      }

      final bikeDetailsRaw = bikeMap['bikeDetails'];
      final bikeDetails = bikeDetailsRaw is Map<String, dynamic>
          ? bikeDetailsRaw
          : bikeDetailsRaw is Map
          ? Map<String, dynamic>.from(bikeDetailsRaw)
          : <String, dynamic>{};

      return CardCollectionTicket(
        uid: verifiedUid,
        tokenNumber: storedToken,
        ownerName: data['name'] as String? ?? '',
        plateNumber: bikeDetails['plateNumber'] as String? ?? '',
        facePhotoUrl: facePhotoUrl,
      );
    } catch (e) {
      _rethrowAsFirestoreException(e);
    }
  }

  Future<void> issueMtagCard({
    required String uid,
    required String tokenNumber,
  }) async {
    try {
      final verifiedUid = _requireMatchingUid(uid);
      await _userDoc(verifiedUid).set({
        'mtagCard': {
          'issued': true,
          'tokenNumber': tokenNumber.trim(),
          'issuedAt': FieldValue.serverTimestamp(),
        },
        'bikeRegistration.tokenStatus': 'Card Issued',
        'bikeRegistration.tokenEstimatedTime': '—',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      _rethrowAsFirestoreException(e);
    }
  }

  /// Loads the rider's bike, queue token and card status.
  Future<RegistrationRecord?> fetchRegistration(String uid) async {
    try {
      _requireMatchingUid(uid);
      final snapshot = await _userDoc(uid).get();
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return RegistrationRecord.fromUserDocument(data);
    } on FirestoreException {
      rethrow;
    } catch (e) {
      _rethrowAsFirestoreException(e);
    }
  }
}
