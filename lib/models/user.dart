// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class User {
  final String? uid;
  String name;
  String cnic;
  String phoneNumber;
  String email;
  String password;

  User({
    this.uid,
    this.name = '',
    this.cnic = '',
    this.phoneNumber = '',
    this.email = '',
    this.password = '',
  });

  factory User.fromFirebase(firebase_auth.User firebaseUser) {
    final email = firebaseUser.email ?? '';
    final displayName = firebaseUser.displayName?.trim();
    final fallbackName = email.isNotEmpty ? email.split('@').first : 'User';

    return User(
      uid: firebaseUser.uid,
      name: (displayName != null && displayName.isNotEmpty)
          ? displayName
          : fallbackName,
      email: email,
    );
  }

  User copyWith({
    String? uid,
    String? name,
    String? cnic,
    String? phoneNumber,
    String? email,
    String? password,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      cnic: cnic ?? this.cnic,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (uid != null) 'uid': uid,
      'name': name,
      'cnic': cnic,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] as String?,
      name: map['name'] as String? ?? '',
      cnic: map['cnic'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(uid: $uid, name: $name, cnic: $cnic, phoneNumber: $phoneNumber, email: $email)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.name == name &&
        other.cnic == cnic &&
        other.phoneNumber == phoneNumber &&
        other.email == email;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        cnic.hashCode ^
        phoneNumber.hashCode ^
        email.hashCode;
  }
}
