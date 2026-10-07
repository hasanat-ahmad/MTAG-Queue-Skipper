import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Front-camera preview and still capture for the selfie screens
/// (face enrolment and MTAG card collection).
///
/// Call [initialize] once the screen is visible and [dispose] when it
/// closes. The current photo is available as [photo] after [capture].
class CameraCaptureController with ChangeNotifier {
  CameraController? _camera;
  bool _isInitializing = true;
  String? _error;
  XFile? _photo;
  bool _isDisposed = false;

  /// Live camera, once [initialize] has succeeded.
  CameraController? get camera => _camera;

  bool get isInitializing => _isInitializing;

  /// Why the camera could not start, e.g. permission denied.
  String? get error => _error;

  /// The captured still, or null while showing the live preview.
  XFile? get photo => _photo;

  bool get isReady => _camera?.value.isInitialized ?? false;

  /// Asks for camera permission and opens the front camera (or the first
  /// camera if there is no front one). Safe to call again to retry.
  Future<void> initialize() async {
    _isInitializing = true;
    _error = null;
    _notify();

    if (kIsWeb) {
      _fail('Camera capture is not supported on web.');
      return;
    }

    final status = await Permission.camera.request();
    if (_isDisposed) return;
    if (!status.isGranted) {
      _fail('Camera permission is required to verify your identity.');
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No camera found on this device.');
      }
      final description = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      await _camera?.dispose();
      _camera = null;
      final camera = CameraController(
        description,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await camera.initialize();

      if (_isDisposed) {
        await camera.dispose();
        return;
      }
      _camera = camera;
      _isInitializing = false;
      _notify();
    } catch (e) {
      _fail(e.toString());
    }
  }

  /// Takes a still photo. Returns a message to show the rider if the
  /// camera failed, or null on success.
  Future<String?> capture() async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) return null;

    try {
      final photo = await camera.takePicture();
      if (_isDisposed) return null;
      _photo = photo;
      _notify();
      return null;
    } catch (e) {
      return 'Could not capture photo: $e';
    }
  }

  /// Discards the captured photo and returns to the live preview.
  void retake() {
    _photo = null;
    _notify();
  }

  void _fail(String message) {
    if (_isDisposed) return;
    _isInitializing = false;
    _error = message;
    _notify();
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _camera?.dispose();
    super.dispose();
  }
}
