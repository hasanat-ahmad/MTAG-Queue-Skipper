import 'package:cloud_functions/cloud_functions.dart';
import 'package:mtag_queue_skipper/config/backend_config.dart';
import 'package:mtag_queue_skipper/core/errors/app_exception.dart';
import 'package:mtag_queue_skipper/data/models/queue_token.dart';

/// A Cloud Function rejected the call. [code] is the Functions error code,
/// e.g. `already-exists` or `failed-precondition`.
class BackendException extends AppException {
  const BackendException(super.message, {super.code});
}

/// What the Stripe Payment Sheet needs to take one payment.
class PaymentIntentSession {
  const PaymentIntentSession({
    required this.paymentIntentId,
    required this.clientSecret,
  });

  final String paymentIntentId;
  final String clientSecret;
}

/// A server-signed permission to upload the rider's reference selfie to
/// Cloudinary. Send [params] unchanged together with [apiKey] and
/// [signature].
class FaceUploadAuthorization {
  const FaceUploadAuthorization({
    required this.cloudName,
    required this.apiKey,
    required this.signature,
    required this.params,
  });

  final String cloudName;
  final String apiKey;
  final String signature;
  final Map<String, String> params;
}

/// Typed client for the callable Cloud Functions in functions/src.
///
/// Anything involving money, the queue or card issuance goes through
/// here; Firestore rules stop the app from writing those fields itself.
class BackendService {
  BackendService({FirebaseFunctions? functions})
    : _functions =
          functions ??
          FirebaseFunctions.instanceFor(region: BackendConfig.functionsRegion);

  final FirebaseFunctions _functions;

  /// Starts a registration-fee payment. Fails with code `already-exists`
  /// when the fee has already been paid.
  Future<PaymentIntentSession> createPaymentIntent() async {
    final data = await _call('createPaymentIntent');
    return PaymentIntentSession(
      paymentIntentId: _requireString(data, 'paymentIntentId'),
      clientSecret: _requireString(data, 'clientSecret'),
    );
  }

  /// Has the server verify a completed payment with Stripe; returns the
  /// queue token it assigned.
  Future<QueueToken> confirmPayment(String paymentIntentId) async {
    final data = await _call('confirmPayment', {
      'paymentIntentId': paymentIntentId,
    });
    final token = QueueToken.fromRegistrationMap(data);
    if (token == null) {
      throw const BackendException('The server did not assign a queue token.');
    }
    return token;
  }

  /// Issues the MTAG card for [tokenNumber] after the server re-checks
  /// ownership, payment and that no card was issued before.
  Future<void> issueMtagCard(String tokenNumber) async {
    await _call('issueMtagCard', {'tokenNumber': tokenNumber});
  }

  Future<FaceUploadAuthorization> createFaceUploadSignature() async {
    final data = await _call('createFaceUploadSignature');
    final params = data['params'];
    if (params is! Map) {
      throw const BackendException('The server did not sign the upload.');
    }
    return FaceUploadAuthorization(
      cloudName: _requireString(data, 'cloudName'),
      apiKey: _requireString(data, 'apiKey'),
      signature: _requireString(data, 'signature'),
      params: params.map((key, value) => MapEntry('$key', '$value')),
    );
  }

  Future<Map<String, dynamic>> _call(
    String name, [
    Map<String, dynamic>? data,
  ]) async {
    try {
      final result = await _functions.httpsCallable(name).call<Object?>(data);
      final value = result.data;
      return value is Map ? Map<String, dynamic>.from(value) : {};
    } on FirebaseFunctionsException catch (e) {
      throw BackendException(_messageFor(e), code: e.code);
    }
  }

  /// Functions report expected failures with a message meant for the
  /// rider; unexpected ones only say "INTERNAL".
  static String _messageFor(FirebaseFunctionsException e) {
    final message = e.message?.trim() ?? '';
    if (e.code == 'internal' || message.isEmpty || message == 'INTERNAL') {
      return 'Something went wrong on our side. Please try again.';
    }
    if (e.code == 'unavailable') {
      return 'Cannot reach the server. Check your internet connection.';
    }
    return message;
  }

  static String _requireString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String && value.isNotEmpty) return value;
    throw BackendException('The server response is missing "$key".');
  }
}
