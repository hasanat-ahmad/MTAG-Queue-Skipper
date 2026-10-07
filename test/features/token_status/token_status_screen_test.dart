import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtag_queue_skipper/data/models/registration_record.dart';
import 'package:mtag_queue_skipper/features/token_status/token_status_screen.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';
import 'package:provider/provider.dart';

import '../../helpers/fakes.dart';

Future<void> pumpTokenStatus(
  WidgetTester tester,
  RegistrationRecord record,
) async {
  final registration = await loadedRegistration(record);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: signedInAuth()),
        ChangeNotifierProvider<RegistrationController>.value(
          value: registration,
        ),
      ],
      child: const MaterialApp(home: TokenStatusScreen()),
    ),
  );
}

void main() {
  testWidgets('explains how to get a token when there is none', (tester) async {
    await pumpTokenStatus(tester, const RegistrationRecord(bike: testBike));

    expect(find.text('No token yet'), findsOneWidget);
    expect(find.text('Register bike'), findsOneWidget);
  });

  testWidgets('shows the token with a way to collect the card', (tester) async {
    await pumpTokenStatus(
      tester,
      const RegistrationRecord(bike: testBike, token: testToken),
    );

    expect(find.text('TKN-0001'), findsOneWidget);
    expect(find.text('ICT-1234'), findsOneWidget);
    expect(find.text('Ali Khan'), findsOneWidget);
    expect(find.text('Collect MTAG card'), findsOneWidget);
    expect(find.text('Back to home'), findsOneWidget);
  });

  testWidgets('offers only "Back to home" after collection', (tester) async {
    await pumpTokenStatus(
      tester,
      RegistrationRecord(
        bike: testBike,
        token: testToken.asCollected(),
        cardIssued: true,
      ),
    );

    expect(find.text('Card Issued'), findsOneWidget);
    expect(find.text('Collect MTAG card'), findsNothing);
    expect(find.text('Back to home'), findsOneWidget);
  });
}
