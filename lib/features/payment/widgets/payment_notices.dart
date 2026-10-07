import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/core/theme/app_colors.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';

/// Stripe's test card details, for test-mode payments.
class TestCardHint extends StatelessWidget {
  const TestCardHint({super.key});

  @override
  Widget build(BuildContext context) {
    return const MtagSectionCard(
      title: 'Test card',
      child: Text(
        '4242 4242 4242 4242\n'
        'Any future expiry · any CVC · any ZIP',
        style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.45),
      ),
    );
  }
}

/// Warning shown when the build has no Stripe keys.
class StripeSetupWarning extends StatelessWidget {
  const StripeSetupWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningBorder),
      ),
      child: const Text(
        'Add your Stripe publishable key in lib/config/stripe_config.local.dart',
        style: TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }
}
