import 'package:flutter/foundation.dart';

/// A token that passed the collection checks (it matches the rider's
/// registration, the fee is paid, a reference photo exists and the card has
/// not been issued yet), plus what the issuance screens need to show.
@immutable
class CardCollectionTicket {
  const CardCollectionTicket({
    required this.uid,
    required this.tokenNumber,
    required this.ownerName,
    required this.plateNumber,
    required this.facePhotoUrl,
  });

  final String uid;
  final String tokenNumber;
  final String ownerName;
  final String plateNumber;

  /// Reference selfie taken during registration.
  final String facePhotoUrl;
}
