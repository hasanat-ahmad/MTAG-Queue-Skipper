import 'package:mtag_queue_skipper/data/models/bike_details.dart';

/// Raw values typed into the bike registration form.
class BikeRegistrationInput {
  const BikeRegistrationInput({
    required this.ownerName,
    required this.phone,
    required this.cnic,
    required this.brand,
    required this.color,
    required this.year,
    required this.plateNumber,
    required this.engineNumber,
    required this.chassisNumber,
  });

  final String ownerName;
  final String phone;
  final String cnic;
  final String brand;
  final String color;
  final String year;
  final String plateNumber;
  final String engineNumber;
  final String chassisNumber;

  BikeDetails toBikeDetails() {
    return BikeDetails(
      plateNumber: plateNumber.trim(),
      engineNumber: engineNumber.trim(),
      chassisNumber: chassisNumber.trim(),
      brand: brand,
      color: color,
      year: year.trim(),
    );
  }
}

/// Choices offered by the bike registration form.
class BikeOptions {
  BikeOptions._();

  static const List<String> brands = [
    'Honda',
    'Yamaha',
    'Suzuki',
    'United',
    'Road Prince',
    'Other',
  ];

  static const List<String> colors = [
    'Black',
    'White',
    'Red',
    'Blue',
    'Grey',
    'Green',
    'Other',
  ];

  static const int minModelYear = 1980;

  /// The current year, so the picker never goes stale.
  static int get maxModelYear => DateTime.now().year;
}

/// Length limits enforced by firestore.rules. The form stops typing at
/// these so a long value never turns into a "permission denied" error.
class FieldLimits {
  FieldLimits._();

  static const int ownerName = 100;
  static const int plateNumber = 20;
  static const int engineNumber = 30;
  static const int chassisNumber = 30;
}
