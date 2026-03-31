import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/constants/app_colors.dart';
import 'package:mtag_queue_skipper/constants/app_fonts.dart';
import 'package:mtag_queue_skipper/providers/user_provider.dart';
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
        elevation: 3,
        child: SizedBox(
          height: 140, // ✅ Equal height
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${userProvider.name}",
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),

            // ✅ Grid starts here
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1, // ✅ keeps width & height balanced
                children: [
                  buildCard(
                    "Register your bike",
                    "Easy and clean process",
                    Icons.electric_bike_outlined,
                    () {},
                  ),
                  buildCard(
                    "My Token",
                    "View your token",
                    Icons.confirmation_number,
                    () {},
                  ),
                  buildCard(
                    "Status",
                    "Track queue",
                    Icons.access_time,
                    () {},
                  ),
                  buildCard(
                    "History",
                    "Past records",
                    Icons.history,
                    () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}