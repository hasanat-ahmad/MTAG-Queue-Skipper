import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/core/theme/app_colors.dart';
import 'package:mtag_queue_skipper/features/profile/widgets/profile_header.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';
import 'package:provider/provider.dart';

/// Account details and sign-out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Signs out and forgets the rider's registration, so the next account
  /// on this device never sees it.
  Future<void> _signOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    final registration = context.read<RegistrationController>();
    await context.read<AuthController>().signOut();
    registration.clear();
    unawaited(navigator.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    if (user == null) {
      return const MtagScaffold(
        title: 'Profile',
        body: Center(child: Text('Not signed in')),
      );
    }

    String orDash(String value) => value.trim().isEmpty ? '—' : value;

    return MtagScaffold(
      title: 'Profile',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ProfileHeader(user: user),
          const SizedBox(height: 24),
          MtagSectionCard(
            title: 'Your details',
            child: Column(
              children: [
                MtagInfoTile(
                  icon: Icons.badge_outlined,
                  label: 'CNIC',
                  value: orDash(user.cnic),
                ),
                const Divider(height: 1, color: AppColors.borderLight),
                MtagInfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: orDash(user.phoneNumber),
                ),
                const Divider(height: 1, color: AppColors.borderLight),
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
            onPressed: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
