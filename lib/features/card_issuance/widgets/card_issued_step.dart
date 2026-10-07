import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/core/theme/app_colors.dart';
import 'package:mtag_queue_skipper/features/card_issuance/card_issuance_controller.dart';
import 'package:mtag_queue_skipper/features/card_issuance/widgets/mtag_card_preview.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';
import 'package:provider/provider.dart';

/// Step 3: confirmation with a preview of the issued card.
class CardIssuedStep extends StatelessWidget {
  const CardIssuedStep({super.key});

  @override
  Widget build(BuildContext context) {
    final ticket = context.watch<CardIssuanceController>().ticket!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle, size: 64, color: AppColors.success),
        const SizedBox(height: 12),
        const Text(
          'Your MTAG card is ready',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Identity verified. Your registration is complete.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 20),
        MtagCardPreview(
          ownerName: ticket.ownerName,
          tokenNumber: ticket.tokenNumber,
          plateNumber: ticket.plateNumber,
        ),
        const Spacer(),
        MtagPrimaryButton(
          label: 'Done',
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (_) => false,
          ),
        ),
      ],
    );
  }
}
