import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/features/face_capture/face_enrollment_controller.dart';
import 'package:mtag_queue_skipper/shared/camera/camera_capture_actions.dart';
import 'package:mtag_queue_skipper/shared/camera/camera_capture_view.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';
import 'package:provider/provider.dart';

/// Registration step 2: take the reference selfie, then continue to payment.
class FaceCaptureScreen extends StatelessWidget {
  const FaceCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final controller = FaceEnrollmentController(auth: context.read());
        // Start the camera after the first frame so the page shows at once.
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => controller.startCamera(),
        );
        return controller;
      },
      child: const _FaceCaptureView(),
    );
  }
}

class _FaceCaptureView extends StatelessWidget {
  const _FaceCaptureView();

  Future<void> _capture(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final failure = await context
        .read<FaceEnrollmentController>()
        .capturePhoto();
    if (failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(failure)));
    }
  }

  Future<void> _continue(BuildContext context) async {
    final navigator = Navigator.of(context);
    final saved = await context
        .read<FaceEnrollmentController>()
        .saveReferencePhoto();
    if (saved) unawaited(navigator.pushReplacementNamed(AppRoutes.payment));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FaceEnrollmentController>();
    final error = controller.error;

    return MtagScaffold(
      title: 'Face photo',
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MtagPageHeader(
                title: 'Snap a quick selfie',
                subtitle:
                    'We save this so we can check it is really you when you collect your card.',
                icon: Icons.face_retouching_natural_outlined,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: CameraCaptureView(
                  controller: controller.camera,
                  hint: 'Center your face in the oval',
                  dimCapturedPhoto: true,
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 10),
                InlineErrorText(error),
              ],
              const SizedBox(height: 14),
              CameraCaptureActions(
                controller: controller.camera,
                confirmLabel: 'Continue',
                busy: controller.isSaving,
                onCapture: () => _capture(context),
                onRetake: controller.retake,
                onConfirm: () => _continue(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
