import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/constants/app_colors.dart';
import 'package:mtag_queue_skipper/constants/app_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("MTAG Protal", style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.primaryFont,
          )),
        ),
        centerTitle: false,
      ),
    );
  }
}
