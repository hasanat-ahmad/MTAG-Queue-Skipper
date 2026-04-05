import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/constants/app_fonts.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget buildCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 5,
        child: SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black,
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 10),
        Expanded(child: right),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "MTAG Portal",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.primaryFont,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Welcome, ${authProvider.user?.name ?? 'User'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 50),

            buildRow(
              buildCard(
                "Register your bike",
                "Easy and clean process",
                Icons.electric_bike_outlined,
                () {
                  Navigator.pushNamed(context, '/bike-register');
                },
              ),
              buildCard(
                "My Token",
                "View your token",
                Icons.confirmation_number,
                () {},
              ),
            ),

            const SizedBox(height: 10),

            buildRow(
              buildCard("Bike Details", "Your bike details", Icons.access_time, () {Navigator.pushNamed(context, '/bike-details');}),
              buildCard("Profile", "Past records", Icons.person, () {
                Navigator.pushNamed(context, '/profile');
              }),
            ),
          ],
        ),
      ),
    );
  }
}
