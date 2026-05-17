// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BikeDetails {
  String fullName;
  String cnic;
  String phoneNo;
  String plateNumber;
  String engineNo;
  String chasisNumber;
  String brand;
  String color;
  String year;

  BikeDetails({
    required this.fullName,
    required this.cnic,
    required this.phoneNo,
    required this.plateNumber,
    required this.engineNo,
    required this.chasisNumber,
    this.brand = '',
    this.color = '',
    this.year = '',
  });

  BikeDetails copyWith({
    String? fullName,
    String? cnic,
    String? phoneNo,
    String? plateNumber,
    String? engineNo,
    String? chasisNumber,
    String? brand,
    String? color,
    String? year,
  }) {
    return BikeDetails(
      fullName: fullName ?? this.fullName,
      cnic: cnic ?? this.cnic,
      phoneNo: phoneNo ?? this.phoneNo,
      plateNumber: plateNumber ?? this.plateNumber,
      engineNo: engineNo ?? this.engineNo,
      chasisNumber: chasisNumber ?? this.chasisNumber,
      brand: brand ?? this.brand,
      color: color ?? this.color,
      year: year ?? this.year,
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
      'brand': brand,
      'color': color,
      'year': year,
    };
  }

  factory BikeDetails.fromMap(Map<String, dynamic> map) {
    return BikeDetails(
      fullName: map['fullName'] as String? ?? '',
      cnic: map['cnic'] as String? ?? '',
      phoneNo: map['phoneNo'] as String? ?? '',
      plateNumber: map['plateNumber'] as String? ?? '',
      engineNo: map['engineNo'] as String? ?? '',
      chasisNumber: map['chasisNumber'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      color: map['color'] as String? ?? '',
      year: map['year'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory BikeDetails.fromJson(String source) =>
      BikeDetails.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BikeDetails(fullName: $fullName, cnic: $cnic, phoneNo: $phoneNo, plateNumber: $plateNumber, engineNo: $engineNo, chasisNumber: $chasisNumber, brand: $brand, color: $color, year: $year)';
  }

  @override
  bool operator ==(covariant BikeDetails other) {
    if (identical(this, other)) return true;

    return other.fullName == fullName &&
        other.cnic == cnic &&
        other.phoneNo == phoneNo &&
        other.plateNumber == plateNumber &&
        other.engineNo == engineNo &&
        other.chasisNumber == chasisNumber &&
        other.brand == brand &&
        other.color == color &&
        other.year == year;
  }

  @override
  int get hashCode {
    return fullName.hashCode ^
        cnic.hashCode ^
        phoneNo.hashCode ^
        plateNumber.hashCode ^
        engineNo.hashCode ^
        chasisNumber.hashCode ^
        brand.hashCode ^
        color.hashCode ^
        year.hashCode;
  }
}
