import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/features/card_issuance/card_issuance_controller.dart';
import 'package:mtag_queue_skipper/features/card_issuance/widgets/card_issued_step.dart';
import 'package:mtag_queue_skipper/features/card_issuance/widgets/face_check_step.dart';
import 'package:mtag_queue_skipper/features/card_issuance/widgets/token_entry_step.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';
import 'package:provider/provider.dart';

/// MTAG card collection: token, then face check, then the issued card.
class CardIssuanceScreen extends StatelessWidget {
  const CardIssuanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CardIssuanceController(
        auth: context.read(),
        registration: context.read(),
      ),
      child: const _CardIssuanceView(),
    );
  }
}

class _CardIssuanceView extends StatelessWidget {
  const _CardIssuanceView();

  @override
  Widget build(BuildContext context) {
    final step = context.select<CardIssuanceController, CardIssuanceStep>(
      (controller) => controller.step,
    );

    return MtagScaffold(
      title: step == CardIssuanceStep.issued ? 'Card issued' : 'Collect card',
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: switch (step) {
            CardIssuanceStep.enterToken => const TokenEntryStep(),
            CardIssuanceStep.verifyFace => const FaceCheckStep(),
            CardIssuanceStep.issued => const CardIssuedStep(),
          },
        ),
      ),
    );
  }
}
