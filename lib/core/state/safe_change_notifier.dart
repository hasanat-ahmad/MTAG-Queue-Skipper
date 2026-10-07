import 'package:flutter/foundation.dart';

/// Base class for screen controllers.
///
/// Controllers often finish async work (network calls, the camera) after
/// their screen has been closed. Notifying after [dispose] is ignored
/// instead of throwing, so every await does not need a "still alive?"
/// check.
abstract class SafeChangeNotifier extends ChangeNotifier {
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
