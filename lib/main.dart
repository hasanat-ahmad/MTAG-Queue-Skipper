import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:mtag_queue_skipper/providers/user_provider.dart';
import 'package:mtag_queue_skipper/screens/home_screen.dart';
import 'package:mtag_queue_skipper/screens/login_screen.dart';
import 'package:mtag_queue_skipper/screens/profile.dart';
import 'package:mtag_queue_skipper/screens/register_screen.dart';
import 'package:mtag_queue_skipper/screens/splash_screen.dart';
import 'package:provider/provider.dart';

void main(List<String> args) {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create:  (_) => AuthProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => Profile(),
      },
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
