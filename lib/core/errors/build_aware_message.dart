import 'package:flutter/foundation.dart';

/// Picks the message for the current build: setup hints for developers in
/// debug builds, a plain message for riders in release builds. Release
/// builds never reveal configuration details such as signing fingerprints
/// or console steps.
String buildAwareMessage({required String rider, required String developer}) {
  return kDebugMode ? developer : rider;
}
