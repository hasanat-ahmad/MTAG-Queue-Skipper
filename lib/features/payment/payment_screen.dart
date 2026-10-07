import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/features/payment/payment_controller.dart';
import 'package:mtag_queue_skipper/features/payment/widgets/fee_summary_card.dart';
import 'package:mtag_queue_skipper/features/payment/widgets/payment_notices.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';
import 'package:provider/provider.dart';

/// Registration step 3: pay the fee, then see the queue token.
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          PaymentController(auth: context.read(), registration: context.read()),
      child: const _PaymentView(),
    );
  }
}

class _PaymentView extends StatelessWidget {
  const _PaymentView();

  Future<void> _pay(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await context.read<PaymentController>().pay();
    switch (outcome) {
      case PaymentOutcome.paid:
        navigator.pushReplacementNamed(AppRoutes.tokenStatus);
      case PaymentOutcome.cancelled:
        messenger.showSnackBar(
          const SnackBar(content: Text('Payment cancelled')),
        );
      case PaymentOutcome.failed:
        break; // The controller's error is shown on the page.
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PaymentController>();
    final error = controller.error;

    return MtagScaffold(
      title: 'Payment',
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MtagPageHeader(
                title: 'Almost there',
                subtitle: 'Pay the registration fee to get your queue token.',
                icon: Icons.payments_outlined,
              ),
              FeeSummaryCard(formattedFee: controller.formattedFee),
              const SizedBox(height: 14),
              const TestCardHint(),
              if (!controller.isConfigured) ...[
                const SizedBox(height: 14),
                const StripeSetupWarning(),
              ],
              if (error != null) ...[
                const SizedBox(height: 12),
                InlineErrorText(error),
              ],
              const Spacer(),
              MtagPrimaryButton(
                label: controller.hasUnconfirmedPayment
                    ? 'Confirm payment'
                    : 'Pay with Stripe',
                loading: controller.isPaying,
                onPressed: controller.isConfigured ? () => _pay(context) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
