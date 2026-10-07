import 'package:flutter/foundation.dart';

/// The signed-in rider: Firebase account plus the owner details captured
/// during bike registration.
///
/// Stored in Firestore at `users/{uid}`. Passwords are never part of the
/// profile; Firebase Auth owns credentials.
@immutable
class UserProfile {
  const UserProfile({
    required this.uid,
    this.email = '',
    this.name = '',
    this.cnic = '',
    this.phoneNumber = '',
  });

  final String uid;
  final String email;
  final String name;

  /// 13 digits without dashes, e.g. `3520212345671`.
  final String cnic;

  /// Local mobile format, e.g. `03001234567`.
  final String phoneNumber;

  bool get hasName => name.trim().isNotEmpty;

  /// First word of the name, or `User` when no name is known yet.
  String get firstName => hasName ? name.trim().split(' ').first : 'User';

  /// Up to two upper-case initials for the avatar, or `?` without a name.
  String get initials {
    final letters = name
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();
    return letters.isEmpty ? '?' : letters;
  }

  UserProfile copyWith({
    String? email,
    String? name,
    String? cnic,
    String? phoneNumber,
  }) {
    return UserProfile(
      uid: uid,
      email: email ?? this.email,
      name: name ?? this.name,
      cnic: cnic ?? this.cnic,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  /// Returns a copy updated with the owner fields stored in the rider's
  /// Firestore document. A blank stored name keeps the current name.
  ///
  /// The e-mail always comes from Firebase Auth, never from Firestore:
  /// firestore.rules only accept the address in the rider's auth token,
  /// so a stale stored copy must not overwrite it.
  UserProfile mergeStoredProfile(Map<String, dynamic> data) {
    final storedName = _stringOrNull(data['name']);
    return copyWith(
      name: storedName != null && storedName.trim().isNotEmpty
          ? storedName
          : null,
      cnic: _stringOrNull(data['cnic']),
      phoneNumber: _stringOrNull(data['phoneNumber']),
    );
  }

  static String? _stringOrNull(Object? value) => value is String ? value : null;

  @override
  bool operator ==(Object other) {
    return other is UserProfile &&
        other.uid == uid &&
        other.email == email &&
        other.name == name &&
        other.cnic == cnic &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode => Object.hash(uid, email, name, cnic, phoneNumber);

  @override
  String toString() => 'UserProfile(uid: $uid, email: $email, name: $name)';
}
