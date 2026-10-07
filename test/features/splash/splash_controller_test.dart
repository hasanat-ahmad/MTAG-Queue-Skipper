import 'package:flutter_test/flutter_test.dart';
import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/data/models/registration_record.dart';
import 'package:mtag_queue_skipper/features/splash/splash_controller.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';

import '../../helpers/fakes.dart';

void main() {
  test('riders who are not signed in go to login', () async {
    final firestore = FakeFirestoreService();
    final controller = SplashController(
      auth: AuthController(
        authService: FakeAuthService(),
        firestoreService: firestore,
      ),
      registration: RegistrationController(firestoreService: firestore),
      minimumDisplayTime: Duration.zero,
    );

    expect(await controller.resolveStartRoute(), AppRoutes.login);
    expect(firestore.fetchedRegistrationFor, isEmpty);
  });

  test('a remembered rider goes home with their registration loaded', () async {
    final firestore = FakeFirestoreService()
      ..registration = const RegistrationRecord(
        bike: testBike,
        token: testToken,
      );
    final registration = RegistrationController(firestoreService: firestore);
    final controller = SplashController(
      auth: signedInAuth(firestore: firestore),
      registration: registration,
      minimumDisplayTime: Duration.zero,
    );

    expect(await controller.resolveStartRoute(), AppRoutes.home);
    expect(registration.token, testToken);
  });
}
