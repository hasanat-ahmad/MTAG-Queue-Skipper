// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class User {
  String name = "";
  String cnic = "";
  String phoneNumber = "";
  String email = "";
  String password = "";
  User({
    required this.name,
    required this.cnic,
    required this.phoneNumber,
    required this.email,
    required this.password,
  });

  User copyWith({
    String? name,
    String? cnic,
    String? phoneNumber,
    String? email,
    String? password,
  }) {
    return User(
      name: name ?? this.name,
      cnic: cnic ?? this.cnic,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'cnic': cnic,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] as String,
      cnic: map['cnic'] as String,
      phoneNumber: map['phoneNumber'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(name: $name, cnic: $cnic, phoneNumber: $phoneNumber, email: $email, password: $password)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;
  
    return 
      other.name == name &&
      other.cnic == cnic &&
      other.phoneNumber == phoneNumber &&
      other.email == email &&
      other.password == password;
  }

  @override
  int get hashCode {
    return name.hashCode ^
      cnic.hashCode ^
      phoneNumber.hashCode ^
      email.hashCode ^
      password.hashCode;
  }
}
