import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/config/stripe_config.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:mtag_queue_skipper/services/firestore_service.dart';
import 'package:mtag_queue_skipper/services/stripe_service.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _stripeService = StripeService();
  final _firestoreService = FirestoreService();

  bool _paying = false;
  String? _error;

  Map<String, dynamic> get _tokenArgs {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args ?? <String, dynamic>{};
  }

  Future<void> _pay() async {
    if (kIsWeb) {
      setState(() {
        _error = 'Stripe Payment Sheet is not supported on web. Use a device.';
      });
      return;
    }

    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) {
      setState(() => _error = 'Please sign in to complete payment.');
      return;
    }

    setState(() {
      _paying = true;
      _error = null;
    });

    try {
      final intent = await _stripeService.createPaymentIntent();
      await _stripeService.presentPaymentSheet(clientSecret: intent.clientSecret);

      await _firestoreService.savePaymentRecord(
        uid: uid,
        paymentIntentId: intent.paymentIntentId,
        amountCents: StripeConfig.amountCents,
        currency: StripeConfig.currency,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/token-status',
        arguments: _tokenArgs,
      );
    } on StripePaymentException catch (e) {
      if (!mounted) return;
      setState(() {
        _paying = false;
        _error = e.code == 'canceled' ? null : e.message;
      });
      if (e.code == 'canceled') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment cancelled')),
        );
      }
    } on FirestoreException catch (e) {
      if (!mounted) return;
      setState(() {
        _paying = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _paying = false;
        _error = e.toString();
      });
    } finally {
      if (mounted && _paying) {
        setState(() => _paying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final configured = StripeConfig.isConfigured;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Registration Payment',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MTAG registration fee',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      StripeConfig.formattedAmount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Test mode · Stripe',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test card (Stripe test mode)',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '4242 4242 4242 4242\n'
                      'Any future expiry · any CVC · any ZIP',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (!configured) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color(0xFFFFCC80)),
                  ),
                  child: const Text(
                    'Copy lib/config/stripe_config.local.dart.example to '
                    'stripe_config.local.dart and add your Stripe test keys.',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: !configured || _paying ? null : _pay,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _paying
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Pay with Stripe',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
