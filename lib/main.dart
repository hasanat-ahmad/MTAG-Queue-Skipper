import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/providers/user_provider.dart';
import 'package:mtag_queue_skipper/screens/home_screen.dart';
import 'package:mtag_queue_skipper/screens/login_screen.dart';
import 'package:mtag_queue_skipper/screens/register_screen.dart';
import 'package:mtag_queue_skipper/screens/splash_screen.dart';
import 'package:provider/provider.dart';

void main(List<String> args) {
  runApp(ChangeNotifierProvider(create: (_) => UserProvider(), child: MyApp()));
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
      },
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
