/// Base class for failures the app expects and can explain to the rider,
/// such as a declined payment or a face that did not match.
///
/// [message] is safe to show in the UI; [code] identifies the failure for
/// logic (e.g. `canceled`).
abstract class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}
