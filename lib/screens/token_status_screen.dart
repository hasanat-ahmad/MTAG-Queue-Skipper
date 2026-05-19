import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/constants/app_colors.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:mtag_queue_skipper/providers/bike_details_provider.dart';
import 'package:mtag_queue_skipper/utils/token_display.dart';
import 'package:mtag_queue_skipper/widgets/mtag_ui.dart';
import 'package:provider/provider.dart';

class TokenStatusScreen extends StatelessWidget {
  const TokenStatusScreen({super.key});

  String _formatGeneratedAt(String raw) {
    if (raw.trim().isEmpty || raw == 'N/A') {
      return 'N/A';
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }

    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final year = parsed.year.toString();
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');
    final second = parsed.second.toString().padLeft(2, '0');

    return '$day-$month-$year $hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    final bikeDetailsProvider = context.watch<BikeDetailsProvider>();
    final user = context.watch<AuthProvider>().user;

    final args =
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ??
        <String, dynamic>{};

    final routeToken = args['tokenNumber'] as String?;
    final hasTokenFromRoute =
        routeToken != null && routeToken.trim().isNotEmpty;
    final hasToken = hasTokenFromRoute || bikeDetailsProvider.hasToken;

    final tokenNumber =
        routeToken ?? bikeDetailsProvider.tokenNumber ?? 'TKN-0000';
    final rawStatus =
        args['status'] as String? ?? bikeDetailsProvider.tokenStatus;
    final rawEstimatedTime =
        args['estimatedTime'] as String? ??
        bikeDetailsProvider.tokenEstimatedTime;
    final status = TokenDisplay.statusLabel(
      status: rawStatus,
      mtagCardIssued: bikeDetailsProvider.mtagCardIssued,
    );
    final estimatedTime = TokenDisplay.estimatedTimeLabel(
      estimatedTime: rawEstimatedTime,
      status: rawStatus,
      mtagCardIssued: bikeDetailsProvider.mtagCardIssued,
    );
    final isCollected =
        bikeDetailsProvider.isCardCollected ||
        TokenDisplay.isCollected(status: rawStatus);
    final generatedAtRaw =
        args['generatedAt'] as String? ??
        bikeDetailsProvider.tokenGeneratedAt ??
        'N/A';
    final generatedAt = _formatGeneratedAt(generatedAtRaw);
    final bikeDetails = bikeDetailsProvider.bikeDetails;

    if (!hasToken) {
      return MtagScreen(
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
                    color: MtagUi.highlightBg,
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
                      Navigator.pushNamed(context, '/bike-register'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MtagScreen(
      title: 'My Token',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          MtagHighlightBanner(
            label: 'Your queue token',
            value: tokenNumber,
            icon: Icons.confirmation_number_outlined,
          ),
          const SizedBox(height: 14),
          MtagCard(
            title: 'Status details',
            child: Column(
              children: [
                MtagInfoTile(label: 'Status', value: status),
                MtagInfoTile(label: 'Estimated wait', value: estimatedTime),
                MtagInfoTile(label: 'Generated at', value: generatedAt),
                MtagInfoTile(
                  label: 'Plate',
                  value: bikeDetails?.plateNumber ?? 'N/A',
                ),
                MtagInfoTile(
                  label: 'Owner',
                  value: user?.name.trim().isNotEmpty == true
                      ? user!.name
                      : 'N/A',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!isCollected)
            MtagPrimaryButton(
              label: 'Collect MTAG card',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/mtag-card',
                  arguments: {'tokenNumber': tokenNumber},
                );
              },
            ),
          if (!isCollected) const SizedBox(height: 10),
          if (isCollected)
            MtagPrimaryButton(
              label: 'Back to home',
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
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
                  '/home',
                  (route) => false,
                );
              },
            ),
        ],
      ),
    );
  }
}
