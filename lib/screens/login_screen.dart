import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:mtag_queue_skipper/providers/bike_details_provider.dart';
import 'package:mtag_queue_skipper/widgets/mtag_ui.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
        SnackBar(content: Text(result.errorMessage ?? 'Login failed.')),
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

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final result = await context.read<AuthProvider>().signInWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (mounted) setState(() => _isSubmitting = false);
    await _handleAuthResult(result);
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isSubmitting = true);
    final result = await context.read<AuthProvider>().signInWithGoogle();
    if (mounted) setState(() => _isSubmitting = false);
    await _handleAuthResult(result);
  }

  @override
  Widget build(BuildContext context) {
    return MtagAuthLayout(
      title: 'Welcome back',
      subtitle: 'Log in to skip the queue and manage your MTAG stuff.',
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
              autofillHints: const [AutofillHints.password],
              decoration: MtagUi.inputDecoration(
                label: 'Password',
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
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            MtagPrimaryButton(
              label: 'Log in',
              loading: _isSubmitting,
              onPressed: _loginWithEmail,
            ),
            const MtagOrDivider(),
            MtagGoogleButton(
              label: 'Continue with Google',
              enabled: !_isSubmitting,
              onPressed: _loginWithGoogle,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () => Navigator.pushNamed(context, '/register'),
              child: const Text(
                "Don't have an account? Sign up",
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
