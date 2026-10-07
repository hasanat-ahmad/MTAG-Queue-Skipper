import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';
import 'package:provider/provider.dart';

/// Root widget: provides the app-wide controllers and the route table.
class MtagApp extends StatelessWidget {
  const MtagApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => RegistrationController()),
      ],
      child: MaterialApp(
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.table,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
