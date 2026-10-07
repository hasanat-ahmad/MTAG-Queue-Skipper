import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/data/services/cloudinary_service.dart';
import 'package:mtag_queue_skipper/data/services/face_verification_service.dart';
import 'package:mtag_queue_skipper/data/services/firestore_service.dart';
import 'package:mtag_queue_skipper/shared/camera/camera_capture_actions.dart';
import 'package:mtag_queue_skipper/shared/camera/camera_capture_controller.dart';
import 'package:mtag_queue_skipper/shared/camera/camera_capture_view.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:provider/provider.dart';

class FaceCaptureScreen extends StatefulWidget {
  const FaceCaptureScreen({super.key});

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  final _camera = CameraCaptureController();
  bool _uploading = false;
  String? _uploadError;

  final _cloudinaryService = CloudinaryService();
  final _firestoreService = FirestoreService();
  final _faceVerificationService = FaceVerificationService.instance;

  @override
  void initState() {
    super.initState();
    _camera.addListener(_onCameraChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _camera.initialize());
  }

  void _onCameraChanged() => setState(() {});

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    final error = await _camera.capture();
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _uploadError = null);
  }

  void _retake() {
    _camera.retake();
    setState(() => _uploadError = null);
  }

  Future<void> _confirmAndContinue() async {
    final file = _camera.photo;
    if (file == null) return;

    final auth = context.read<AuthController>();
    final uid = auth.user?.uid;
    if (uid == null) {
      setState(() {
        _uploadError = 'Please sign in to save your photo.';
      });
      return;
    }

    setState(() {
      _uploading = true;
      _uploadError = null;
    });

    try {
      final bytes = await file.readAsBytes();
      final imageUrl = await _cloudinaryService.uploadFacePhoto(
        uid: uid,
        imageBytes: bytes,
      );
      await _firestoreService.saveFacePhotoUrl(
        uid: uid,
        facePhotoUrl: imageUrl,
      );
      await _faceVerificationService.registerReferenceFace(
        uid: uid,
        imagePath: file.path,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.payment);
    } on CloudinaryException catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _uploadError = e.message;
      });
    } on FaceVerificationException catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _uploadError = e.message;
      });
    } on FirestoreException catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _uploadError = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _uploadError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  controller: _camera,
                  hint: 'Center your face in the oval',
                  dimCapturedPhoto: true,
                ),
              ),
              if (_uploadError != null) ...[
                const SizedBox(height: 10),
                Text(
                  _uploadError!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 14),
              CameraCaptureActions(
                controller: _camera,
                confirmLabel: 'Continue',
                busy: _uploading,
                onCapture: _capturePhoto,
                onRetake: _retake,
                onConfirm: _confirmAndContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
