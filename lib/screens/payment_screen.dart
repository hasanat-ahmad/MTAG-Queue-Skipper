import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/config/stripe_config.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:mtag_queue_skipper/services/firestore_service.dart';
import 'package:mtag_queue_skipper/services/stripe_service.dart';
import 'package:mtag_queue_skipper/widgets/mtag_ui.dart';
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

    return MtagScreen(
      title: 'Payment',
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MtagPageHeader(
                title: 'Almost there',
                subtitle: 'Pay the registration fee to get your queue token.',
                icon: Icons.payments_outlined,
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF01411C), Color(0xFF027A2E)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registration fee',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      StripeConfig.formattedAmount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Test mode · Stripe',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const MtagCard(
                title: 'Test card',
                child: Text(
                  '4242 4242 4242 4242\n'
                  'Any future expiry · any CVC · any ZIP',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.45,
                  ),
                ),
              ),
              if (!configured) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFFFE082)),
                  ),
                  child: const Text(
                    'Add Stripe test keys in lib/config/stripe_config.local.dart',
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
              MtagPrimaryButton(
                label: 'Pay with Stripe',
                loading: _paying,
                onPressed: !configured || _paying ? null : _pay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
