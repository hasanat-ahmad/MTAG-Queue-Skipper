import 'package:flutter/foundation.dart';
import 'package:mtag_queue_skipper/data/models/bike_details.dart';
import 'package:mtag_queue_skipper/data/models/queue_token.dart';
import 'package:mtag_queue_skipper/data/models/registration_record.dart';
import 'package:mtag_queue_skipper/data/models/user_profile.dart';
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

  BikeDetails? get bikeDetails => _record.bike;
  QueueToken? get token => _record.token;
  bool get hasToken => _record.hasToken;
  bool get isCardCollected => _record.isCardCollected;

  /// The rider has a token but has not collected the MTAG card yet.
  bool get isReadyToCollectCard => hasToken && !isCardCollected;

  /// Saves [owner]'s details together with [bike] and [token].
  ///
  /// Local state changes only after Firestore accepted the write, so a
  /// failed save never leaves a token on screen that was not stored.
  /// Throws [FirestoreException] on failure.
  Future<void> saveRegistration({
    required UserProfile owner,
    required BikeDetails bike,
    required QueueToken token,
  }) async {
    await _firestoreService.saveUserAndBike(
      uid: owner.uid,
      email: owner.email,
      name: owner.name,
      cnic: owner.cnic,
      phoneNumber: owner.phoneNumber,
      bikeRegistration: <String, dynamic>{
        'bikeDetails': bike.toMap(),
        'tokenNumber': token.number,
        'tokenStatus': token.statusLabel,
        'tokenEstimatedTime': token.estimatedWaitLabel,
        'tokenGeneratedAt': token.generatedAt,
      },
    );
    _record = _record.copyWith(bike: bike, token: token);
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
    notifyListeners();
  }

  Future<void> loadForUser(String uid) async {
    if (uid.trim().isEmpty) {
      clear();
      return;
    }

    try {
      final record = await _firestoreService.fetchRegistration(uid);
      _record = record ?? RegistrationRecord.empty;
      notifyListeners();
    } on FirestoreException catch (e) {
      debugPrint('Failed to load bike registration: $e');
      clear();
    } catch (e, stackTrace) {
      debugPrint('Failed to load bike registration: $e\n$stackTrace');
      clear();
    }
  }
}
