import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/constants/app_fonts.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final userName = authProvider.user?.name ?? 'User';

    final items = [
      _NavItem(
        title: "Register Bike",
        subtitle: "Easy and clean process",
        icon: Icons.electric_bike_outlined,
        onTap: () => Navigator.pushNamed(context, '/bike-register'),
      ),
      _NavItem(
        title: "My Token",
        subtitle: "View your queue token",
        icon: Icons.confirmation_number_outlined,
        onTap: () {},
      ),
      _NavItem(
        title: "Bike Details",
        subtitle: "Your bike info",
        icon: Icons.two_wheeler_outlined,
        onTap: () => Navigator.pushNamed(context, '/bike-details'),
      ),
      _NavItem(
        title: "Profile",
        subtitle: "Manage your account",
        icon: Icons.person_outline_rounded,
        onTap: () => Navigator.pushNamed(context, '/profile'),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          "MTAG",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.primaryFont,
            color: Colors.black,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, $userName 👋",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    onTap: item.onTap,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    leading: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: Colors.black, size: 22),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.black38,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _NavItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}
