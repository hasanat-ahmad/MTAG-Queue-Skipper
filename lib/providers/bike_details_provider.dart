// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:mtag_queue_skipper/models/bike_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BikeDetailsProvider with ChangeNotifier {
  static const String _bikeDataPrefix = 'bike_data_';
  BikeDetails? bikeDetails;
  String? tokenNumber;
  String? tokenStatus;
  String? tokenEstimatedTime;
  String? tokenGeneratedAt;
  BikeDetailsProvider({
    this.bikeDetails,
    this.tokenNumber,
    this.tokenStatus,
    this.tokenEstimatedTime,
    this.tokenGeneratedAt,
  });

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
    notifyListeners();
  }

  bool get hasToken => tokenNumber != null && tokenNumber!.isNotEmpty;

  String _storageKeyForEmail(String email) =>
      '$_bikeDataPrefix${email.trim().toLowerCase()}';

  Future<bool> saveForUser(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _storageKeyForEmail(email);
      return await prefs.setString(key, toJson());
    } catch (_) {
      return false;
    }
  }

  Future<void> loadForUser(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _storageKeyForEmail(email);
      final raw = prefs.getString(key);
      if (raw == null || raw.trim().isEmpty) {
        bikeDetails = null;
        tokenNumber = null;
        tokenStatus = null;
        tokenEstimatedTime = null;
        tokenGeneratedAt = null;
        notifyListeners();
        return;
      }

      final loaded = BikeDetailsProvider.fromJson(raw);
      bikeDetails = loaded.bikeDetails;
      tokenNumber = loaded.tokenNumber;
      tokenStatus = loaded.tokenStatus;
      tokenEstimatedTime = loaded.tokenEstimatedTime;
      tokenGeneratedAt = loaded.tokenGeneratedAt;
      notifyListeners();
    } catch (_) {
      bikeDetails = null;
      tokenNumber = null;
      tokenStatus = null;
      tokenEstimatedTime = null;
      tokenGeneratedAt = null;
      notifyListeners();
    }
  }

  BikeDetailsProvider copyWith({
    BikeDetails? bikeDetails,
    String? tokenNumber,
    String? tokenStatus,
    String? tokenEstimatedTime,
    String? tokenGeneratedAt,
  }) {
    return BikeDetailsProvider(
      bikeDetails: bikeDetails ?? this.bikeDetails,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      tokenStatus: tokenStatus ?? this.tokenStatus,
      tokenEstimatedTime: tokenEstimatedTime ?? this.tokenEstimatedTime,
      tokenGeneratedAt: tokenGeneratedAt ?? this.tokenGeneratedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bikeDetails': bikeDetails?.toMap(),
      'tokenNumber': tokenNumber,
      'tokenStatus': tokenStatus,
      'tokenEstimatedTime': tokenEstimatedTime,
      'tokenGeneratedAt': tokenGeneratedAt,
    };
  }

  factory BikeDetailsProvider.fromMap(Map<String, dynamic> map) {
    return BikeDetailsProvider(
      bikeDetails: map['bikeDetails'] != null
          ? BikeDetails.fromMap(map['bikeDetails'] as Map<String, dynamic>)
          : null,
      tokenNumber: map['tokenNumber'] != null
          ? map['tokenNumber'] as String
          : null,
      tokenStatus: map['tokenStatus'] != null
          ? map['tokenStatus'] as String
          : null,
      tokenEstimatedTime: map['tokenEstimatedTime'] != null
          ? map['tokenEstimatedTime'] as String
          : null,
      tokenGeneratedAt: map['tokenGeneratedAt'] != null
          ? map['tokenGeneratedAt'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory BikeDetailsProvider.fromJson(String source) =>
      BikeDetailsProvider.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BikeDetailsProvider(bikeDetails: $bikeDetails, tokenNumber: $tokenNumber, tokenStatus: $tokenStatus, tokenEstimatedTime: $tokenEstimatedTime, tokenGeneratedAt: $tokenGeneratedAt)';
  }

  @override
  bool operator ==(covariant BikeDetailsProvider other) {
    if (identical(this, other)) return true;

    return other.bikeDetails == bikeDetails &&
        other.tokenNumber == tokenNumber &&
        other.tokenStatus == tokenStatus &&
        other.tokenEstimatedTime == tokenEstimatedTime &&
        other.tokenGeneratedAt == tokenGeneratedAt;
  }

  @override
  int get hashCode {
    return bikeDetails.hashCode ^
        tokenNumber.hashCode ^
        tokenStatus.hashCode ^
        tokenEstimatedTime.hashCode ^
        tokenGeneratedAt.hashCode;
  }
}
