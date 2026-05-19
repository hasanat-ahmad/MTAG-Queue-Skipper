// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mtag_queue_skipper/models/bike_details.dart';
import 'package:mtag_queue_skipper/services/firestore_service.dart';
import 'package:mtag_queue_skipper/utils/token_display.dart';

class BikeDetailsProvider with ChangeNotifier {
  BikeDetailsProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  BikeDetails? bikeDetails;
  String? tokenNumber;
  String? tokenStatus;
  String? tokenEstimatedTime;
  String? tokenGeneratedAt;
  bool mtagCardIssued = false;
  String? lastSaveError;

  bool get hasToken => tokenNumber != null && tokenNumber!.isNotEmpty;

  bool get isCardCollected => TokenDisplay.isCollected(
        status: tokenStatus,
        mtagCardIssued: mtagCardIssued,
      );

  String get displayTokenStatus => TokenDisplay.statusLabel(
        status: tokenStatus,
        mtagCardIssued: mtagCardIssued,
      );

  String get displayEstimatedTime => TokenDisplay.estimatedTimeLabel(
        estimatedTime: tokenEstimatedTime,
        status: tokenStatus,
        mtagCardIssued: mtagCardIssued,
      );

  void setBikeDetails(BikeDetails bikeDetails) {
    this.bikeDetails = bikeDetails;
    notifyListeners();
  }

  void setTokenData({
    required String tokenNumber,
    required String tokenStatus,
    required String tokenEstimatedTime,
    required String tokenGeneratedAt,
  }) {
    this.tokenNumber = tokenNumber;
    this.tokenStatus = tokenStatus;
    this.tokenEstimatedTime = tokenEstimatedTime;
    this.tokenGeneratedAt = tokenGeneratedAt;
    if (TokenDisplay.isCollected(status: tokenStatus)) {
      mtagCardIssued = true;
      this.tokenStatus = TokenDisplay.collectedStatus;
      this.tokenEstimatedTime = TokenDisplay.collectedEstimatedTime;
    }
    notifyListeners();
  }

  void clear() {
    bikeDetails = null;
    tokenNumber = null;
    tokenStatus = null;
    tokenEstimatedTime = null;
    tokenGeneratedAt = null;
    mtagCardIssued = false;
    lastSaveError = null;
    notifyListeners();
  }

  Future<bool> saveForUser(String uid) async {
    lastSaveError = null;
    if (uid.trim().isEmpty) {
      lastSaveError = 'Missing user id. Please sign in again.';
      return false;
    }
    if (bikeDetails == null) {
      lastSaveError = 'No bike details to save.';
      return false;
    }

    try {
      await _firestoreService.saveBikeRegistration(
        uid: uid,
        data: toMap(),
      );
      return true;
    } on FirestoreException catch (e) {
      lastSaveError = e.message;
      debugPrint('Failed to save bike registration: $e');
      return false;
    } catch (e, stackTrace) {
      lastSaveError = e.toString();
      debugPrint('Failed to save bike registration: $e\n$stackTrace');
      return false;
    }
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
    if (bikeDetails == null) {
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
        bikeRegistration: toMap(),
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
      final data = await _firestoreService.getBikeRegistration(uid);
      if (data == null) {
        clear();
        return;
      }

      final loaded = BikeDetailsProvider.fromMap(data);
      bikeDetails = loaded.bikeDetails;
      tokenNumber = loaded.tokenNumber;
      tokenStatus = loaded.tokenStatus;
      tokenEstimatedTime = loaded.tokenEstimatedTime;
      tokenGeneratedAt = loaded.tokenGeneratedAt;
      mtagCardIssued = loaded.mtagCardIssued;
      _applyCollectedState();
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

  void _applyCollectedState() {
    if (!isCardCollected) return;
    mtagCardIssued = true;
    tokenStatus = TokenDisplay.collectedStatus;
    tokenEstimatedTime = TokenDisplay.collectedEstimatedTime;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bikeDetails': bikeDetails!.toMap(),
      'tokenNumber': tokenNumber ?? '',
      'tokenStatus': displayTokenStatus,
      'tokenEstimatedTime': displayEstimatedTime,
      'tokenGeneratedAt': tokenGeneratedAt ?? '',
    };
  }

  factory BikeDetailsProvider.fromMap(Map<String, dynamic> map) {
    final bikeRaw = map['bikeDetails'];
    return BikeDetailsProvider()
      ..bikeDetails = bikeRaw != null
          ? BikeDetails.fromMap(
              bikeRaw is Map<String, dynamic>
                  ? bikeRaw
                  : Map<String, dynamic>.from(bikeRaw as Map),
            )
          : null
      ..tokenNumber = _asString(map['tokenNumber'])
      ..tokenStatus = _asString(map['tokenStatus'])
      ..tokenEstimatedTime = _asString(map['tokenEstimatedTime'])
      ..tokenGeneratedAt = _asString(map['tokenGeneratedAt'])
      ..mtagCardIssued = map['mtagCardIssued'] == true;
  }

  static String? _asString(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  String toJson() => json.encode(toMap());

  factory BikeDetailsProvider.fromJson(String source) =>
      BikeDetailsProvider.fromMap(json.decode(source) as Map<String, dynamic>);
}
