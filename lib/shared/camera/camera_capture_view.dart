import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/shared/camera/camera_capture_controller.dart';
import 'package:mtag_queue_skipper/shared/camera/camera_message_card.dart';
import 'package:mtag_queue_skipper/shared/camera/face_oval_overlay.dart';

/// The camera area of a selfie screen. Depending on [controller] it shows a
/// spinner, an error with a retry button, the captured photo, or the live
/// preview with a face oval.
class CameraCaptureView extends StatelessWidget {
  const CameraCaptureView({
    super.key,
    required this.controller,
    this.hint,
    this.dimCapturedPhoto = false,
  });

  final CameraCaptureController controller;

  /// Optional instruction drawn over the bottom of the live preview.
  final String? hint;

  /// Adds a dark gradient to the bottom of the captured photo.
  final bool dimCapturedPhoto;

  @override
  Widget build(BuildContext context) {
    if (controller.isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    final error = controller.error;
    if (error != null) {
      return CameraMessageCard(
        icon: Icons.no_photography_outlined,
        message: error,
        action: TextButton(
          onPressed: controller.initialize,
          child: const Text('Try again'),
        ),
      );
    }

    final photo = controller.photo;
    if (photo != null) {
      return _CapturedPhoto(path: photo.path, dimmed: dimCapturedPhoto);
    }

    final camera = controller.camera;
    if (camera == null || !camera.value.isInitialized) {
      return const CameraMessageCard(
        icon: Icons.camera_alt_outlined,
        message: 'Camera is not ready.',
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(camera),
          const FaceOvalOverlay(),
          if (hint != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  hint!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CapturedPhoto extends StatelessWidget {
  const _CapturedPhoto({required this.path, required this.dimmed});

  final String path;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final image = Image.file(File(path), fit: BoxFit.cover);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: dimmed
          ? Stack(
              fit: StackFit.expand,
              children: [
                image,
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black26],
                    ),
                  ),
                ),
              ],
            )
          : image,
    );
  }
}
