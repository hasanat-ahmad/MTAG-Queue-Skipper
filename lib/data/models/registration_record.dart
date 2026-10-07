import 'package:flutter/foundation.dart';
import 'package:mtag_queue_skipper/data/models/bike_details.dart';
import 'package:mtag_queue_skipper/data/models/queue_token.dart';

/// What the app knows about the rider's registration: the bike, the queue
/// token and whether the MTAG card has been handed over.
@immutable
class RegistrationRecord {
  const RegistrationRecord({this.bike, this.token, this.cardIssued = false});

  /// Nothing registered yet.
  static const RegistrationRecord empty = RegistrationRecord();

  final BikeDetails? bike;
  final QueueToken? token;

  /// True once `users/{uid}.mtagCard.issued` is set.
  final bool cardIssued;

  bool get hasToken => token != null;

  bool get isCardCollected => cardIssued || (token?.isCollected ?? false);

  RegistrationRecord copyWith({
    BikeDetails? bike,
    QueueToken? token,
    bool? cardIssued,
  }) {
    return RegistrationRecord(
      bike: bike ?? this.bike,
      token: token ?? this.token,
      cardIssued: cardIssued ?? this.cardIssued,
    );
  }

  /// Parses the rider's `users/{uid}` Firestore document.
  ///
  /// When the card has been issued the token is reported as collected,
  /// whatever status string is stored.
  factory RegistrationRecord.fromUserDocument(Map<String, dynamic> data) {
    final registration = _asMap(data['bikeRegistration']);
    final bikeMap = registration['bikeDetails'];
    final cardIssued = _asMap(data['mtagCard'])['issued'] == true;
    final token = QueueToken.fromRegistrationMap(registration);

    return RegistrationRecord(
      bike: bikeMap is Map
          ? BikeDetails.fromMap(Map<String, dynamic>.from(bikeMap))
          : null,
      token: cardIssued ? token?.asCollected() : token,
      cardIssued: cardIssued,
    );
  }

  static Map<String, dynamic> _asMap(Object? value) {
    return value is Map ? Map<String, dynamic>.from(value) : const {};
  }

  @override
  bool operator ==(Object other) {
    return other is RegistrationRecord &&
        other.bike == bike &&
        other.token == token &&
        other.cardIssued == cardIssued;
  }

  @override
  int get hashCode => Object.hash(bike, token, cardIssued);
}
