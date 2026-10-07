import 'package:flutter/foundation.dart';
import 'package:mtag_queue_skipper/data/models/bike_details.dart';
import 'package:mtag_queue_skipper/data/models/queue_token.dart';
import 'package:mtag_queue_skipper/data/models/registration_record.dart';
import 'package:mtag_queue_skipper/data/services/firestore_service.dart';

/// App-wide state for the signed-in rider's registration: bike details,
/// queue token and whether the MTAG card has been collected.
///
/// Load it with [loadForUser] after sign-in and [clear] it on sign-out.
class RegistrationController with ChangeNotifier {
  RegistrationController({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  RegistrationRecord _record = RegistrationRecord.empty;
  String? lastSaveError;

  BikeDetails? get bikeDetails => _record.bike;
  QueueToken? get token => _record.token;
  bool get hasToken => _record.hasToken;
  bool get isCardCollected => _record.isCardCollected;

  /// The rider has a token but has not collected the MTAG card yet.
  bool get isReadyToCollectCard => hasToken && !isCardCollected;

  void setBikeDetails(BikeDetails bikeDetails) {
    _record = _record.copyWith(bike: bikeDetails);
    notifyListeners();
  }

  void setToken(QueueToken token) {
    _record = _record.copyWith(token: token);
    notifyListeners();
  }

  /// Marks the MTAG card for [tokenNumber] as handed over.
  void markCardCollected({required String tokenNumber}) {
    final token = QueueToken(
      number: tokenNumber,
      generatedAt: _record.token?.generatedAt ?? '',
    );
    _record = _record.copyWith(token: token.asCollected(), cardIssued: true);
    notifyListeners();
  }

  void clear() {
    _record = RegistrationRecord.empty;
    lastSaveError = null;
    notifyListeners();
  }

  Future<bool> saveAllForUser({
    required String uid,
    required String email,
    required String name,
    required String cnic,
    required String phoneNumber,
  }) async {
    lastSaveError = null;
    if (uid.trim().isEmpty) {
      lastSaveError = 'Missing user id. Please sign in again.';
      return false;
    }
    final bike = _record.bike;
    if (bike == null) {
      lastSaveError = 'No bike details to save.';
      return false;
    }

    try {
      await _firestoreService.saveUserAndBike(
        uid: uid,
        email: email,
        name: name,
        cnic: cnic,
        phoneNumber: phoneNumber,
        bikeRegistration: _bikeRegistrationMap(bike),
      );
      return true;
    } on FirestoreException catch (e) {
      lastSaveError = e.message;
      debugPrint('Failed to save registration to Firestore: $e');
      return false;
    } catch (e, stackTrace) {
      lastSaveError = e.toString();
      debugPrint('Failed to save registration to Firestore: $e\n$stackTrace');
      return false;
    }
  }

  Future<void> loadForUser(String uid) async {
    if (uid.trim().isEmpty) {
      clear();
      return;
    }

    try {
      final record = await _firestoreService.fetchRegistration(uid);
      _record = record ?? RegistrationRecord.empty;
      lastSaveError = null;
      notifyListeners();
    } on FirestoreException catch (e) {
      debugPrint('Failed to load bike registration: $e');
      clear();
    } catch (e, stackTrace) {
      debugPrint('Failed to load bike registration: $e\n$stackTrace');
      clear();
    }
  }

  Map<String, dynamic> _bikeRegistrationMap(BikeDetails bike) {
    final token = _record.token;
    return <String, dynamic>{
      'bikeDetails': bike.toMap(),
      'tokenNumber': token?.number ?? '',
      'tokenStatus': token?.statusLabel ?? 'Pending',
      'tokenEstimatedTime': token?.estimatedWaitLabel ?? 'N/A',
      'tokenGeneratedAt': token?.generatedAt ?? '',
    };
  }
}
