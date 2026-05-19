import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:mtag_queue_skipper/providers/bike_details_provider.dart';
import 'package:mtag_queue_skipper/widgets/mtag_ui.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordHidden = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthResult(AuthResult result) async {
    if (!mounted) return;

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Sign up failed.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final bikeProvider = context.read<BikeDetailsProvider>();
    final uid = auth.user?.uid;
    if (uid != null) {
      await auth.loadUserProfileFromFirestore();
      await bikeProvider.loadForUser(uid);
    }
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final result = await context.read<AuthProvider>().signUpWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (mounted) setState(() => _isSubmitting = false);
    await _handleAuthResult(result);
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isSubmitting = true);
    final result = await context.read<AuthProvider>().signInWithGoogle();
    if (mounted) setState(() => _isSubmitting = false);
    await _handleAuthResult(result);
  }

  @override
  Widget build(BuildContext context) {
    return MtagAuthLayout(
      title: 'Create your account',
      subtitle: 'Sign up with email or jump in with Google — takes a minute.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: MtagUi.inputDecoration(
                label: 'Email',
                hint: 'you@example.com',
                prefixIcon: Icons.email_outlined,
              ),
              validator: _validateEmail,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: _isPasswordHidden,
              autofillHints: const [AutofillHints.newPassword],
              decoration: MtagUi.inputDecoration(
                label: 'Password',
                hint: 'At least 6 characters',
                prefixIcon: Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(
                    _isPasswordHidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordHidden = !_isPasswordHidden),
                ),
              ),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            MtagPrimaryButton(
              label: 'Sign up',
              loading: _isSubmitting,
              onPressed: _signUpWithEmail,
            ),
            const MtagOrDivider(),
            MtagGoogleButton(
              label: 'Sign up with Google',
              enabled: !_isSubmitting,
              onPressed: _signUpWithGoogle,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
              child: const Text(
                'Already have an account? Log in',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@'
      r'((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|'
      r'(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }
}
