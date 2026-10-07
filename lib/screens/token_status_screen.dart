import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/core/theme/app_colors.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';
import 'package:provider/provider.dart';

class TokenStatusScreen extends StatelessWidget {
  const TokenStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final registration = context.watch<RegistrationController>();
    final user = context.watch<AuthController>().user;

    final token = registration.token;
    final isCollected = registration.isCardCollected;
    final bikeDetails = registration.bikeDetails;

    if (token == null) {
      return MtagScaffold(
        title: 'My Token',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    size: 36,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No token yet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Register your bike first — then your queue token shows up here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 24),
                MtagPrimaryButton(
                  label: 'Register bike',
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.bikeRegistration),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MtagScaffold(
      title: 'My Token',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          MtagHighlightBanner(
            label: 'Your queue token',
            value: token.number,
            icon: Icons.confirmation_number_outlined,
          ),
          const SizedBox(height: 14),
          MtagSectionCard(
            title: 'Status details',
            child: Column(
              children: [
                MtagInfoTile(label: 'Status', value: token.statusLabel),
                MtagInfoTile(
                  label: 'Estimated wait',
                  value: token.estimatedWaitLabel,
                ),
                MtagInfoTile(
                  label: 'Generated at',
                  value: token.generatedAtLabel,
                ),
                MtagInfoTile(
                  label: 'Plate',
                  value: bikeDetails?.plateNumber ?? 'N/A',
                ),
                MtagInfoTile(
                  label: 'Owner',
                  value: user?.hasName == true ? user!.name : 'N/A',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!isCollected)
            MtagPrimaryButton(
              label: 'Collect MTAG card',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.cardIssuance);
              },
            ),
          if (!isCollected) const SizedBox(height: 10),
          if (isCollected)
            MtagPrimaryButton(
              label: 'Back to home',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                );
              },
            )
          else
            MtagOutlinedButton(
              label: 'Back to home',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                );
              },
            ),
        ],
      ),
    );
  }
}
