import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/core/theme/app_colors.dart';
import 'package:mtag_queue_skipper/data/services/face_verification_service.dart';
import 'package:mtag_queue_skipper/data/services/firestore_service.dart';
import 'package:mtag_queue_skipper/shared/camera/camera_capture_actions.dart';
import 'package:mtag_queue_skipper/shared/camera/camera_capture_controller.dart';
import 'package:mtag_queue_skipper/shared/camera/camera_capture_view.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:mtag_queue_skipper/state/registration_controller.dart';
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
  final _faceVerificationService = FaceVerificationService.instance;

  _IssuanceStep _step = _IssuanceStep.token;
  bool _loading = false;
  String? _error;

  MtagTokenValidation? _validation;
  final _camera = CameraCaptureController();
  bool _verifying = false;

  bool _tokenPrefilled = false;

  @override
  void initState() {
    super.initState();
    _camera.addListener(_onCameraChanged);
  }

  void _onCameraChanged() => setState(() {});

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tokenPrefilled) return;
    _tokenPrefilled = true;

    final registration = context.read<RegistrationController>();
    final storedToken = registration.token?.number;
    if (storedToken != null) {
      _tokenController.text = storedToken;
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _camera.dispose();
    super.dispose();
  }

  Future<void> _validateToken() async {
    if (!_tokenFormKey.currentState!.validate()) return;

    final uid = context.read<AuthController>().user?.uid;
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
      await _camera.initialize();
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

  Future<void> _capturePhoto() async {
    final error = await _camera.capture();
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _error = null);
  }

  void _retake() {
    _camera.retake();
    setState(() => _error = null);
  }

  Future<void> _verifyAndIssue() async {
    final validation = _validation;
    final captured = _camera.photo;
    if (validation == null || captured == null) return;

    final registration = context.read<RegistrationController>();

    setState(() {
      _verifying = true;
      _error = null;
    });

    try {
      final verification = await _faceVerificationService.verifyFaces(
        uid: validation.uid,
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
      registration.markCardCollected(tokenNumber: validation.tokenNumber);

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
    return MtagScaffold(
      title: _step == _IssuanceStep.success ? 'Card issued' : 'Collect card',
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
        const MtagPageHeader(
          title: 'Got your token?',
          subtitle:
              'Enter it below, then we will match your face to your registration photo.',
          icon: Icons.credit_card_outlined,
        ),
        Form(
          key: _tokenFormKey,
          child: TextFormField(
            controller: _tokenController,
            textCapitalization: TextCapitalization.characters,
            decoration: mtagInputDecoration(
              label: 'Token number',
              hint: 'e.g. TKN-1234',
              prefixIcon: Icons.confirmation_number_outlined,
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
        MtagPrimaryButton(
          label: 'Continue',
          loading: _loading,
          onPressed: _validateToken,
        ),
      ],
    );
  }

  Widget _buildVerifyStep() {
    final validation = _validation!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MtagHighlightBanner(
          label: 'Your token',
          value: validation.tokenNumber,
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
        Expanded(child: CameraCaptureView(controller: _camera)),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 12),
        CameraCaptureActions(
          controller: _camera,
          confirmLabel: 'Verify & Issue Card',
          busy: _verifying,
          onCapture: _capturePhoto,
          onRetake: _retake,
          onConfirm: _verifyAndIssue,
        ),
      ],
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
        MtagPrimaryButton(
          label: 'Done',
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          },
        ),
      ],
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
        gradient: AppGradients.brandDiagonal,
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
