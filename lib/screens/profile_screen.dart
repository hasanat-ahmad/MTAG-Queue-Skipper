import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:mtag_queue_skipper/providers/bike_details_provider.dart';
import 'package:mtag_queue_skipper/widgets/mtag_ui.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const MtagScreen(
        title: 'Profile',
        body: Center(child: Text('Not signed in')),
      );
    }

    final initials = user.name
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return MtagScreen(
      title: 'Profile',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF01411C), Color(0xFF027A2E)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials.isEmpty ? '?' : initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.name.trim().isEmpty ? 'Rider' : user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          MtagCard(
            title: 'Your details',
            child: Column(
              children: [
                MtagInfoTile(
                  icon: Icons.badge_outlined,
                  label: 'CNIC',
                  value: user.cnic.trim().isEmpty ? '—' : user.cnic,
                ),
                const Divider(height: 1, color: MtagUi.cardBorder),
                MtagInfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value:
                      user.phoneNumber.trim().isEmpty ? '—' : user.phoneNumber,
                ),
                const Divider(height: 1, color: MtagUi.cardBorder),
                MtagInfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user.email,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          MtagOutlinedButton(
            label: 'Log out',
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              context.read<BikeDetailsProvider>().clear();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
