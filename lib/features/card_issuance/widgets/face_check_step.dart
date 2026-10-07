import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/features/card_issuance/card_issuance_controller.dart';
import 'package:mtag_queue_skipper/shared/camera/camera_capture_actions.dart';
import 'package:mtag_queue_skipper/shared/camera/camera_capture_view.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';
import 'package:provider/provider.dart';

/// Step 2: the rider takes a selfie that is matched against the reference
/// photo from registration.
class FaceCheckStep extends StatelessWidget {
  const FaceCheckStep({super.key});

  Future<void> _capture(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final failure = await context.read<CardIssuanceController>().capturePhoto();
    if (failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(failure)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CardIssuanceController>();
    final error = controller.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MtagHighlightBanner(
          label: 'Your token',
          value: controller.ticket?.tokenNumber ?? '',
          icon: Icons.confirmation_number_outlined,
        ),
        const SizedBox(height: 12),
        const MtagPageHeader(
          title: 'Quick face check',
          subtitle:
              'Take a selfie — we compare it to the photo from registration.',
          icon: Icons.face_retouching_natural_outlined,
        ),
        const SizedBox(height: 12),
        Expanded(child: CameraCaptureView(controller: controller.camera)),
        if (error != null) ...[
          const SizedBox(height: 8),
          InlineErrorText(error),
        ],
        const SizedBox(height: 12),
        CameraCaptureActions(
          controller: controller.camera,
          confirmLabel: 'Verify & Issue Card',
          busy: controller.isBusy,
          onCapture: () => _capture(context),
          onRetake: controller.retake,
          onConfirm: controller.verifyAndIssue,
        ),
      ],
    );
  }
}
