import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtag_queue_skipper/data/models/registration_record.dart';
import 'package:mtag_queue_skipper/features/home/home_screen.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';
import 'package:provider/provider.dart';

import '../../helpers/fakes.dart';

Future<void> pumpHome(WidgetTester tester, RegistrationRecord record) async {
  final registration = await loadedRegistration(record);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: signedInAuth()),
        ChangeNotifierProvider<RegistrationController>.value(
          value: registration,
        ),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
}

void main() {
  testWidgets('greets the rider and lists the services', (tester) async {
    await pumpHome(tester, RegistrationRecord.empty);

    expect(find.text('Hello, Ali'), findsOneWidget);
    expect(find.text('Register Bike'), findsOneWidget);
    expect(find.text('Collect MTAG Card'), findsOneWidget);
    expect(find.text('Your active token'), findsNothing);
    expect(find.text('READY'), findsNothing);
  });

  testWidgets('shows the active token and points at card collection', (
    tester,
  ) async {
    await pumpHome(
      tester,
      const RegistrationRecord(bike: testBike, token: testToken),
    );

    expect(find.text('Your active token'), findsOneWidget);
    expect(find.text('TKN-0001'), findsOneWidget);
    expect(find.text('Pending Verification'), findsOneWidget);
    expect(find.text('READY'), findsOneWidget);
  });

  testWidgets('drops the READY badge once the card is collected', (
    tester,
  ) async {
    await pumpHome(
      tester,
      RegistrationRecord(
        bike: testBike,
        token: testToken.asCollected(),
        cardIssued: true,
      ),
    );

    expect(find.text('Card Issued'), findsOneWidget);
    expect(find.text('READY'), findsNothing);
  });
}
