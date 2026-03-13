import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/screens/login_screen.dart';
import 'package:mtag_queue_skipper/screens/register_screen.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterScreen(),
    );
  }
}