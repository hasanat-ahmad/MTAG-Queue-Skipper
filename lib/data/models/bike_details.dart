import 'package:flutter/foundation.dart';

/// The motorcycle being registered for an MTAG card.
///
/// Stored in Firestore at `users/{uid}.bikeRegistration.bikeDetails`.
@immutable
class BikeDetails {
  const BikeDetails({
    required this.plateNumber,
    required this.engineNumber,
    required this.chassisNumber,
    this.brand = '',
    this.color = '',
    this.year = '',
  });

  final String plateNumber;

  /// Stored under the legacy key `engineNo`.
  final String engineNumber;

  /// Stored under the legacy (misspelt) key `chasisNumber`; renaming the
  /// key would orphan existing registrations.
  final String chassisNumber;

  final String brand;
  final String color;

  /// Model year as four digits, e.g. `2021`.
  final String year;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'plateNumber': plateNumber,
      'engineNo': engineNumber,
      'chasisNumber': chassisNumber,
      'brand': brand,
      'color': color,
      'year': year,
    };
  }

  factory BikeDetails.fromMap(Map<String, dynamic> map) {
    String read(String key) {
      final value = map[key];
      return value is String ? value : '';
    }

    return BikeDetails(
      plateNumber: read('plateNumber'),
      engineNumber: read('engineNo'),
      chassisNumber: read('chasisNumber'),
      brand: read('brand'),
      color: read('color'),
      year: read('year'),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BikeDetails &&
        other.plateNumber == plateNumber &&
        other.engineNumber == engineNumber &&
        other.chassisNumber == chassisNumber &&
        other.brand == brand &&
        other.color == color &&
        other.year == year;
  }

  @override
  int get hashCode =>
      Object.hash(plateNumber, engineNumber, chassisNumber, brand, color, year);

  @override
  String toString() => 'BikeDetails(plateNumber: $plateNumber, brand: $brand)';
}
