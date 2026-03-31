import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/constants/app_colors.dart';
import 'package:mtag_queue_skipper/constants/app_fonts.dart';
import 'package:mtag_queue_skipper/providers/user_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "MTAG Protal",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.primaryFont,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text("Welcome, ${userProvider.name}"),
            SizedBox(height: 50),
            InkWell(
              onTap: () {

              },
              child: Card(
                child: Column(
                  children: [
                    ListTile(leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text("Register your bike"),
                    subtitle: Text("Easy and clean process", style: TextStyle(fontSize: 12))
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Card(
              child: Column(
                children: [
                  ListTile(leading: CircleAvatar(child: Icon(Icons.usb_rounded)),
                  title: Text("Your Profile"),
                  subtitle: Text("Check your profile", style: TextStyle(fontSize: 12))
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Card(
              child: Column(
                children: [
                  ListTile(leading: CircleAvatar(child: Icon(Icons.token)),
                  title: Text("Check token status"),
                  subtitle: Text("Easy and clean process", style: TextStyle(fontSize: 12))
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Card(
              child: Column(
                children: [
                  ListTile(leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text("Register your bike"),
                  subtitle: Text("Easy and clean process", style: TextStyle(fontSize: 12))
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
