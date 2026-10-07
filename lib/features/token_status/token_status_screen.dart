import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/core/theme/app_colors.dart';
import 'package:mtag_queue_skipper/data/models/bike_details.dart';
import 'package:mtag_queue_skipper/data/models/queue_token.dart';
import 'package:mtag_queue_skipper/data/models/user_profile.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';
import 'package:provider/provider.dart';

/// The rider's queue token and its status.
class TokenStatusScreen extends StatelessWidget {
  const TokenStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final registration = context.watch<RegistrationController>();
    final user = context.watch<AuthController>().user;
    final token = registration.token;

    return MtagScaffold(
      title: 'My Token',
      body: token == null
          ? MtagEmptyState(
              icon: Icons.confirmation_number_outlined,
              iconColor: AppColors.accent,
              iconBackground: AppColors.accentSoft,
              title: 'No token yet',
              message:
                  'Register your bike and pay the fee — then your queue token shows up here.',
              actionLabel: 'Register bike',
              onAction: () =>
                  Navigator.pushNamed(context, AppRoutes.bikeRegistration),
            )
          : _TokenDetails(
              token: token,
              bike: registration.bikeDetails,
              owner: user,
              isCollected: registration.isCardCollected,
            ),
    );
  }
}

class _TokenDetails extends StatelessWidget {
  const _TokenDetails({
    required this.token,
    required this.bike,
    required this.owner,
    required this.isCollected,
  });

  final QueueToken token;
  final BikeDetails? bike;
  final UserProfile? owner;
  final bool isCollected;

  void _goHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
              MtagInfoTile(label: 'Plate', value: bike?.plateNumber ?? 'N/A'),
              MtagInfoTile(
                label: 'Owner',
                value: owner?.hasName == true ? owner!.name : 'N/A',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (isCollected)
          MtagPrimaryButton(
            label: 'Back to home',
            onPressed: () => _goHome(context),
          )
        else ...[
          MtagPrimaryButton(
            label: 'Collect MTAG card',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.cardIssuance),
          ),
          const SizedBox(height: 10),
          MtagOutlinedButton(
            label: 'Back to home',
            onPressed: () => _goHome(context),
          ),
        ],
      ],
    );
  }
}
