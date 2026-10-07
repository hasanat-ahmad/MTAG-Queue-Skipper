import 'package:flutter/foundation.dart';
import 'package:mtag_queue_skipper/core/state/safe_change_notifier.dart';
import 'package:mtag_queue_skipper/core/utils/pakistan_validators.dart';
import 'package:mtag_queue_skipper/data/models/user_profile.dart';
import 'package:mtag_queue_skipper/data/services/firestore_service.dart';
import 'package:mtag_queue_skipper/features/bike_registration/bike_registration_input.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';

/// Submits the bike registration form: owner details plus the bike.
class BikeRegistrationController extends SafeChangeNotifier {
  BikeRegistrationController({
    required AuthController auth,
    required RegistrationController registration,
  }) : _auth = auth,
       _registration = registration;

  final AuthController _auth;
  final RegistrationController _registration;

  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;

  /// Owner details already on file, used to pre-fill the form.
  UserProfile? get savedOwner => _auth.user;

  /// Saves the registration. Returns null on success, otherwise a message
  /// to show the rider.
  Future<String?> submit(BikeRegistrationInput input) async {
    final user = _auth.user;
    if (user == null) return 'Please sign in to register your bike.';

    _isSubmitting = true;
    notifyListeners();
    try {
      final owner = user.copyWith(
        name: input.ownerName.trim(),
        cnic: PakistanValidators.normalizeCnic(input.cnic),
        phoneNumber: PakistanValidators.normalizePhone(input.phone),
      );
      await _registration.saveRegistration(
        owner: owner,
        bike: input.toBikeDetails(),
      );
      _auth.applyLocalOwnerProfile(
        name: owner.name,
        cnic: owner.cnic,
        phoneNumber: owner.phoneNumber,
      );
      return null;
    } on FirestoreException catch (e) {
      debugPrint('Failed to save registration to Firestore: $e');
      return e.message;
    } catch (e) {
      debugPrint('Failed to save registration to Firestore: $e');
      return e.toString();
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
