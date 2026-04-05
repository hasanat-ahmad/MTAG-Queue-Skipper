// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BikeDetails {
  String fullName = "";
  String cnic = "";
  String phoneNo = "";
  String plateNumber = "";
  String engineNo = "";
  String chasisNumber = "";
  BikeDetails({
    required this.fullName,
    required this.cnic,
    required this.phoneNo,
    required this.plateNumber,
    required this.engineNo,
    required this.chasisNumber,
  });
  

  BikeDetails copyWith({
    String? fullName,
    String? cnic,
    String? phoneNo,
    String? plateNumber,
    String? engineNo,
    String? chasisNumber,
  }) {
    return BikeDetails(
      fullName: fullName ?? this.fullName,
      cnic: cnic ?? this.cnic,
      phoneNo: phoneNo ?? this.phoneNo,
      plateNumber: plateNumber ?? this.plateNumber,
      engineNo: engineNo ?? this.engineNo,
      chasisNumber: chasisNumber ?? this.chasisNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fullName': fullName,
      'cnic': cnic,
      'phoneNo': phoneNo,
      'plateNumber': plateNumber,
      'engineNo': engineNo,
      'chasisNumber': chasisNumber,
    };
  }

  factory BikeDetails.fromMap(Map<String, dynamic> map) {
    return BikeDetails(
      fullName: map['fullName'] as String,
      cnic: map['cnic'] as String,
      phoneNo: map['phoneNo'] as String,
      plateNumber: map['plateNumber'] as String,
      engineNo: map['engineNo'] as String,
      chasisNumber: map['chasisNumber'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory BikeDetails.fromJson(String source) => BikeDetails.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BikeDetails(fullName: $fullName, cnic: $cnic, phoneNo: $phoneNo, plateNumber: $plateNumber, engineNo: $engineNo, chasisNumber: $chasisNumber)';
  }

  @override
  bool operator ==(covariant BikeDetails other) {
    if (identical(this, other)) return true;
  
    return 
      other.fullName == fullName &&
      other.cnic == cnic &&
      other.phoneNo == phoneNo &&
      other.plateNumber == plateNumber &&
      other.engineNo == engineNo &&
      other.chasisNumber == chasisNumber;
  }

  @override
  int get hashCode {
    return fullName.hashCode ^
      cnic.hashCode ^
      phoneNo.hashCode ^
      plateNumber.hashCode ^
      engineNo.hashCode ^
      chasisNumber.hashCode;
  }
}

