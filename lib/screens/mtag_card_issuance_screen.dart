import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/constants/app_colors.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:mtag_queue_skipper/providers/bike_details_provider.dart';
import 'package:mtag_queue_skipper/services/face_verification_service.dart';
import 'package:mtag_queue_skipper/services/firestore_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

enum _IssuanceStep { token, verify, success }

class MtagCardIssuanceScreen extends StatefulWidget {
  const MtagCardIssuanceScreen({super.key});

  @override
  State<MtagCardIssuanceScreen> createState() => _MtagCardIssuanceScreenState();
}

class _MtagCardIssuanceScreenState extends State<MtagCardIssuanceScreen> {
  final _tokenController = TextEditingController();
  final _tokenFormKey = GlobalKey<FormState>();

  final _firestoreService = FirestoreService();
  final _faceVerificationService = FaceVerificationService();

  _IssuanceStep _step = _IssuanceStep.token;
  bool _loading = false;
  String? _error;

  MtagTokenValidation? _validation;
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _cameraInitializing = true;
  String? _cameraError;
  XFile? _capturedFile;
  bool _verifying = false;

  bool _tokenPrefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tokenPrefilled) return;
    _tokenPrefilled = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final routeToken = args?['tokenNumber'] as String?;
    if (routeToken != null && routeToken.trim().isNotEmpty) {
      _tokenController.text = routeToken.trim();
      return;
    }

    final provider = context.read<BikeDetailsProvider>();
    final storedToken = provider.tokenNumber;
    if (storedToken != null && storedToken.isNotEmpty) {
      _tokenController.text = storedToken;
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _cameraController?.dispose();
    _faceVerificationService.dispose();
    super.dispose();
  }

  Future<void> _validateToken() async {
    if (!_tokenFormKey.currentState!.validate()) return;

    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) {
      setState(() => _error = 'Please sign in to collect your MTAG card.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _firestoreService.validateTokenForCollection(
        uid: uid,
        tokenNumber: _tokenController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _validation = result;
        _loading = false;
        _step = _IssuanceStep.verify;
      });
      await _initCamera();
    } on FirestoreException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _initCamera() async {
    if (kIsWeb) {
      setState(() {
        _cameraInitializing = false;
        _cameraError = 'Camera is not supported on web.';
      });
      return;
    }

    setState(() {
      _cameraInitializing = true;
      _cameraError = null;
    });

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (!mounted) return;
      setState(() {
        _cameraInitializing = false;
        _cameraError = 'Camera permission is required for face verification.';
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

      await _cameraController?.dispose();
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
        _cameraController = controller;
        _cameraInitializing = false;
        _cameraError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraInitializing = false;
        _cameraError = e.toString();
      });
    }
  }

  Future<void> _capturePhoto() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      setState(() {
        _capturedFile = file;
        _error = null;
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
      _error = null;
    });
  }

  Future<void> _verifyAndIssue() async {
    final validation = _validation;
    final captured = _capturedFile;
    if (validation == null || captured == null) return;

    final bikeProvider = context.read<BikeDetailsProvider>();
    final estimatedTime = bikeProvider.tokenEstimatedTime ?? 'N/A';
    final generatedAt = bikeProvider.tokenGeneratedAt ?? '';

    setState(() {
      _verifying = true;
      _error = null;
    });

    try {
      final verification = await _faceVerificationService.verifyFaces(
        storedImageUrl: validation.facePhotoUrl,
        liveImagePath: captured.path,
      );

      if (!verification.isMatch) {
        if (!mounted) return;
        setState(() {
          _verifying = false;
          _error =
              'Face did not match your registration photo. Please try again with better lighting.';
        });
        return;
      }

      await _firestoreService.issueMtagCard(
        uid: validation.uid,
        tokenNumber: validation.tokenNumber,
      );

      if (!mounted) return;
      bikeProvider.setTokenData(
        tokenNumber: validation.tokenNumber,
        tokenStatus: 'Card Issued',
        tokenEstimatedTime: estimatedTime,
        tokenGeneratedAt: generatedAt,
      );

      if (!mounted) return;
      setState(() {
        _verifying = false;
        _step = _IssuanceStep.success;
      });
    } on FaceVerificationException catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _error = e.message;
      });
    } on FirestoreException catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _error = e.toString();
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
        title: Text(
          _step == _IssuanceStep.success
              ? 'MTAG Card Issued'
              : 'Collect MTAG Card',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: switch (_step) {
            _IssuanceStep.token => _buildTokenStep(),
            _IssuanceStep.verify => _buildVerifyStep(),
            _IssuanceStep.success => _buildSuccessStep(),
          },
        ),
      ),
    );
  }

  Widget _buildTokenStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.credit_card_outlined, size: 56, color: Colors.black87),
        const SizedBox(height: 16),
        const Text(
          'Enter your token number',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'We will verify your identity with a live photo and issue your MTAG card.',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 24),
        Form(
          key: _tokenFormKey,
          child: TextFormField(
            controller: _tokenController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Token number',
              hintText: 'e.g. TKN-1234',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Token number is required';
              }
              return null;
            },
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        const Spacer(),
        FilledButton(
          onPressed: _loading ? null : _validateToken,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _loading
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
      ],
    );
  }

  Widget _buildVerifyStep() {
    final validation = _validation!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF3FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.confirmation_number_outlined, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Token: ${validation.tokenNumber}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Take a live photo for verification',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'ML Kit will compare your face with the photo saved during registration.',
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        Expanded(child: _buildCameraArea()),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 12),
        _buildVerifyActions(),
      ],
    );
  }

  Widget _buildCameraArea() {
    if (_cameraInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    if (_cameraError != null) {
      return _messageCard(
        icon: Icons.no_photography_outlined,
        message: _cameraError!,
        action: TextButton(onPressed: _initCamera, child: const Text('Try again')),
      );
    }

    if (_capturedFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(File(_capturedFile!.path), fit: BoxFit.cover),
      );
    }

    final controller = _cameraController;
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
        ],
      ),
    );
  }

  Widget _buildVerifyActions() {
    if (_cameraInitializing || _cameraError != null) {
      return const SizedBox.shrink();
    }

    if (_capturedFile != null) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _verifying ? null : _retake,
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
              onPressed: _verifying ? null : _verifyAndIssue,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _verifying
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Verify & Issue Card',
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

  Widget _buildSuccessStep() {
    final validation = _validation!;

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
        _MtagCardWidget(
          ownerName: validation.ownerName,
          tokenNumber: validation.tokenNumber,
          plateNumber: validation.plateNumber,
        ),
        const Spacer(),
        FilledButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Done',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
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
}

class _MtagCardWidget extends StatelessWidget {
  const _MtagCardWidget({
    required this.ownerName,
    required this.tokenNumber,
    required this.plateNumber,
  });

  final String ownerName;
  final String tokenNumber;
  final String plateNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF01411C), Color(0xFF027A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'MTAG',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            ownerName.trim().isEmpty ? 'Registered Owner' : ownerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Token: $tokenNumber',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Plate: ${plateNumber.trim().isEmpty ? 'N/A' : plateNumber}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: Colors.white.withValues(alpha: 0.9),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Face verified • Card issued',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
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
