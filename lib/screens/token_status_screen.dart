import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:mtag_queue_skipper/providers/bike_details_provider.dart';
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
    final status =
        args['status'] as String? ??
        bikeDetailsProvider.tokenStatus ??
        'Pending';
    final estimatedTime =
        args['estimatedTime'] as String? ??
        bikeDetailsProvider.tokenEstimatedTime ??
        'N/A';
    final generatedAtRaw =
        args['generatedAt'] as String? ??
        bikeDetailsProvider.tokenGeneratedAt ??
        'N/A';
    final generatedAt = _formatGeneratedAt(generatedAtRaw);

    final bikeDetails = bikeDetailsProvider.bikeDetails;

    if (!hasToken) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),

        appBar: AppBar(
          title: const Text('Token Status'),
          backgroundColor: const Color(0xFFF5F5F5),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.confirmation_number_outlined,
                    size: 68,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No token generated yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Register your bike to get a token and track its status.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/bike-register');
                    },
                    child: const Text('Register Bike'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        title: const Text('Token Status'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF3FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your token is generated',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tokenNumber,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _InfoRow(label: 'Status', value: status),
                    _InfoRow(label: 'Estimated Time', value: estimatedTime),
                    _InfoRow(label: 'Generated At', value: generatedAt),
                    _InfoRow(
                      label: 'Plate Number',
                      value: bikeDetails?.plateNumber ?? 'N/A',
                    ),
                    _InfoRow(
                      label: 'Owner',
                      value: user?.name.trim().isNotEmpty == true
                          ? user!.name
                          : 'N/A',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
