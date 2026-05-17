import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:mtag_queue_skipper/services/firestore_service.dart';
import 'package:mtag_queue_skipper/services/cloudinary_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class FaceCaptureScreen extends StatefulWidget {
  const FaceCaptureScreen({super.key});

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _initializing = true;
  String? _initError;
  XFile? _capturedFile;
  bool _uploading = false;
  String? _uploadError;

  final _cloudinaryService = CloudinaryService();
  final _firestoreService = FirestoreService();

  Map<String, dynamic> get _tokenArgs {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args ?? <String, dynamic>{};
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initCamera());
  }

  Future<void> _initCamera() async {
    if (kIsWeb) {
      setState(() {
        _initializing = false;
        _initError = 'Camera capture is not supported on web.';
      });
      return;
    }

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _initError = 'Camera permission is required to verify your identity.';
      });
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('No camera found on this device.');
      }

      final camera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _initializing = false;
        _initError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _initError = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      setState(() {
        _capturedFile = file;
        _uploadError = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not capture photo: $e')),
      );
    }
  }

  void _retake() {
    setState(() {
      _capturedFile = null;
      _uploadError = null;
    });
  }

  Future<void> _confirmAndContinue() async {
    final file = _capturedFile;
    if (file == null) return;

    final auth = context.read<AuthProvider>();
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

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/payment',
        arguments: _tokenArgs,
      );
    } on CloudinaryException catch (e) {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Face Verification',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Take a clear photo of your face',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'This helps us verify your identity when you arrive at the counter.',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildPreviewArea()),
              if (_uploadError != null) ...[
                const SizedBox(height: 10),
                Text(
                  _uploadError!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 14),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewArea() {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }

    if (_initError != null) {
      return _messageCard(
        icon: Icons.no_photography_outlined,
        message: _initError!,
        action: TextButton(
          onPressed: () {
            setState(() {
              _initializing = true;
              _initError = null;
            });
            _initCamera();
          },
          child: const Text('Try again'),
        ),
      );
    }

    if (_capturedFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(_capturedFile!.path),
              fit: BoxFit.cover,
            ),
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
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return _messageCard(
        icon: Icons.camera_alt_outlined,
        message: 'Camera is not ready.',
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(controller),
          CustomPaint(
            painter: _FaceOvalGuidePainter(),
            child: const SizedBox.expand(),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Center your face in the oval',
                style: TextStyle(
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

  Widget _messageCard({
    required IconData icon,
    required String message,
    Widget? action,
  }) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          if (action != null) ...[const SizedBox(height: 12), action],
        ],
      ),
    );
  }

  Widget _buildActions() {
    if (_initializing || _initError != null) {
      return const SizedBox.shrink();
    }

    if (_capturedFile != null) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _uploading ? null : _retake,
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
              onPressed: _uploading ? null : _confirmAndContinue,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _uploading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Continue',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      );
    }

    return FilledButton(
      onPressed: _capturePhoto,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.black,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'Capture Photo',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _FaceOvalGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final ovalRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.62,
      height: size.height * 0.48,
    );

    final overlay = Paint()..color = Colors.black.withValues(alpha: 0.45);
    final path = Path()
      ..addRect(Offset.zero & size)
      ..addOval(ovalRect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlay);

    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawOval(ovalRect, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
