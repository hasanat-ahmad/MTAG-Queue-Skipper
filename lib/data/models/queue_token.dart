import 'package:flutter/foundation.dart';

/// The rider's place in the MTAG card collection queue.
///
/// Stored in Firestore as the `token*` fields of
/// `users/{uid}.bikeRegistration`.
@immutable
class QueueToken {
  const QueueToken({
    required this.number,
    this.status = '',
    this.estimatedWait = '',
    this.generatedAt = '',
  });

  /// Status once the MTAG card has been handed over.
  static const String collectedStatus = 'Card Issued';

  /// Estimated wait once the MTAG card has been handed over.
  static const String collectedEstimatedWait = '—';

  static const Set<String> _collectedStatuses = {
    'card issued',
    'collected',
    'issued',
  };

  /// Human-readable token, e.g. `TKN-0042`.
  final String number;

  /// Raw status as stored, e.g. `Pending Verification`.
  final String status;

  /// Raw estimated wait as stored, e.g. `15-20 minutes`.
  final String estimatedWait;

  /// ISO-8601 timestamp of when the token was generated.
  final String generatedAt;

  bool get isCollected =>
      _collectedStatuses.contains(status.trim().toLowerCase());

  String get statusLabel {
    if (isCollected) return collectedStatus;
    final value = status.trim();
    return value.isEmpty ? 'Pending' : value;
  }

  String get estimatedWaitLabel {
    if (isCollected) return collectedEstimatedWait;
    final value = estimatedWait.trim();
    return value.isEmpty ? 'N/A' : value;
  }

  /// `dd-MM-yyyy HH:mm:ss` in local time. Falls back to the raw value when
  /// it is not a timestamp, or `N/A` when it is missing.
  String get generatedAtLabel {
    final raw = generatedAt.trim();
    if (raw.isEmpty || raw == 'N/A') return 'N/A';

    final parsed = DateTime.tryParse(raw)?.toLocal();
    if (parsed == null) return raw;

    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(parsed.day)}-${twoDigits(parsed.month)}-${parsed.year} '
        '${twoDigits(parsed.hour)}:${twoDigits(parsed.minute)}:'
        '${twoDigits(parsed.second)}';
  }

  /// Copy of this token after the card has been handed over.
  QueueToken asCollected() {
    return QueueToken(
      number: number,
      status: collectedStatus,
      estimatedWait: collectedEstimatedWait,
      generatedAt: generatedAt,
    );
  }

  /// Parses the `bikeRegistration` map; returns null when no token number
  /// has been assigned yet.
  static QueueToken? fromRegistrationMap(Map<String, dynamic> map) {
    String read(String key) => map[key]?.toString() ?? '';

    final number = read('tokenNumber');
    if (number.isEmpty) return null;
    return QueueToken(
      number: number,
      status: read('tokenStatus'),
      estimatedWait: read('tokenEstimatedTime'),
      generatedAt: read('tokenGeneratedAt'),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is QueueToken &&
        other.number == number &&
        other.status == status &&
        other.estimatedWait == estimatedWait &&
        other.generatedAt == generatedAt;
  }

  @override
  int get hashCode => Object.hash(number, status, estimatedWait, generatedAt);

  @override
  String toString() => 'QueueToken($number, $status)';
}
