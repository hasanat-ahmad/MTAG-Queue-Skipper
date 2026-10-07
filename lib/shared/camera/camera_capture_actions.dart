import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/shared/camera/camera_capture_controller.dart';

/// Buttons under the camera area: "Capture Photo" on the live preview, then
/// "Retake" and [confirmLabel] once a photo has been taken.
///
/// Hidden while the camera is starting or has failed.
class CameraCaptureActions extends StatelessWidget {
  const CameraCaptureActions({
    super.key,
    required this.controller,
    required this.confirmLabel,
    required this.onCapture,
    required this.onRetake,
    required this.onConfirm,
    this.busy = false,
  });

  final CameraCaptureController controller;
  final String confirmLabel;
  final VoidCallback onCapture;
  final VoidCallback onRetake;
  final VoidCallback onConfirm;

  /// Shows a spinner on the confirm button and disables both buttons.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    if (controller.isInitializing || controller.error != null) {
      return const SizedBox.shrink();
    }

    if (controller.photo == null) {
      return FilledButton(
        onPressed: onCapture,
        style: _filledStyle,
        child: const Text(
          'Capture Photo',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: busy ? null : onRetake,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              side: const BorderSide(color: Colors.black),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Retake',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: busy ? null : onConfirm,
            style: _filledStyle,
            child: busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    confirmLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ],
    );
  }

  static final ButtonStyle _filledStyle = FilledButton.styleFrom(
    backgroundColor: Colors.black,
    minimumSize: const Size.fromHeight(50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}
