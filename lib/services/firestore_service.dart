import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreException implements Exception {
  FirestoreException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class FirestoreService {
  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _users.doc(uid);

  Future<String> _requireMatchingUid(String uid) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirestoreException(
        'You must be signed in to save data.',
        code: 'unauthenticated',
      );
    }

    try {
      await user.getIdToken(true);
    } catch (e) {
      debugPrint('Failed to refresh auth token: $e');
    }

    if (user.uid != uid) {
      throw FirestoreException(
        'Session expired. Please sign in again.',
        code: 'uid-mismatch',
      );
    }

    return user.uid;
  }

  Map<String, dynamic> _sanitizeMap(Map<String, dynamic> input) {
    final output = <String, dynamic>{};
    input.forEach((key, value) {
      if (value == null) return;
      if (value is Map) {
        output[key] = _sanitizeMap(Map<String, dynamic>.from(value));
      } else if (value is List) {
        output[key] = value.where((item) => item != null).toList();
      } else {
        output[key] = value;
      }
    });
    return output;
  }

  Never _rethrowAsFirestoreException(Object error) {
    if (error is FirestoreException) {
      throw error;
    }
    if (error is FirebaseException) {
      throw FirestoreException(
        _friendlyMessage(error),
        code: error.code,
      );
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

  Future<void> saveUserProfile({
    required String uid,
    required String email,
    required String name,
    required String cnic,
    required String phoneNumber,
  }) async {
    try {
      final verifiedUid = await _requireMatchingUid(uid);
      await _userDoc(verifiedUid).set(
        _sanitizeMap({
          'email': email,
          'name': name,
          'cnic': cnic,
          'phoneNumber': phoneNumber,
          'updatedAt': FieldValue.serverTimestamp(),
        }),
        SetOptions(merge: true),
      );
    } catch (e) {
      _rethrowAsFirestoreException(e);
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      await _requireMatchingUid(uid);
      final snapshot = await _userDoc(uid).get();
      if (!snapshot.exists) return null;
      return snapshot.data();
    } on FirestoreException {
      rethrow;
    } catch (e) {
      _rethrowAsFirestoreException(e);
    }
  }

  Future<void> saveBikeRegistration({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      final verifiedUid = await _requireMatchingUid(uid);
      await _userDoc(verifiedUid).set(
        _sanitizeMap({
          'bikeRegistration': _sanitizeMap(data),
          'updatedAt': FieldValue.serverTimestamp(),
        }),
        SetOptions(merge: true),
      );
    } catch (e) {
      _rethrowAsFirestoreException(e);
    }
  }

  Future<void> saveUserAndBike({
    required String uid,
    required String email,
    required String name,
    required String cnic,
    required String phoneNumber,
    required Map<String, dynamic> bikeRegistration,
  }) async {
    try {
      final verifiedUid = await _requireMatchingUid(uid);
      await _userDoc(verifiedUid).set(
        _sanitizeMap({
          'email': email,
          'name': name,
          'cnic': cnic,
          'phoneNumber': phoneNumber,
          'bikeRegistration': _sanitizeMap(bikeRegistration),
          'updatedAt': FieldValue.serverTimestamp(),
        }),
        SetOptions(merge: true),
      );
    } catch (e) {
      _rethrowAsFirestoreException(e);
    }
  }

  Future<Map<String, dynamic>?> getBikeRegistration(String uid) async {
    try {
      await _requireMatchingUid(uid);
      final snapshot = await _userDoc(uid).get();
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      final bike = data?['bikeRegistration'];
      if (bike is Map<String, dynamic>) return bike;
      if (bike is Map) {
        return Map<String, dynamic>.from(bike);
      }
      return null;
    } on FirestoreException {
      rethrow;
    } catch (e) {
      _rethrowAsFirestoreException(e);
    }
  }
}
