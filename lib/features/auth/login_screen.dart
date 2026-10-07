import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/core/utils/form_validators.dart';
import 'package:mtag_queue_skipper/features/auth/auth_form_controller.dart';
import 'package:mtag_queue_skipper/features/auth/widgets/auth_layout.dart';
import 'package:mtag_queue_skipper/features/auth/widgets/email_field.dart';
import 'package:mtag_queue_skipper/features/auth/widgets/google_sign_in_button.dart';
import 'package:mtag_queue_skipper/features/auth/widgets/or_divider.dart';
import 'package:mtag_queue_skipper/features/auth/widgets/password_field.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';
import 'package:mtag_queue_skipper/state/auth_controller.dart';
import 'package:provider/provider.dart';

/// Email/password or Google login.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthFormController(
        auth: context.read(),
        registration: context.read(),
      ),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _logInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await context.read<AuthFormController>().signInWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
    _onResult(result);
  }

  Future<void> _logInWithGoogle() async {
    final result = await context
        .read<AuthFormController>()
        .continueWithGoogle();
    _onResult(result);
  }

  void _onResult(AuthResult result) {
    if (!mounted) return;
    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Login failed.')),
      );
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<AuthFormController>();

    return AuthLayout(
      title: 'Welcome back',
      subtitle: 'Log in to skip the queue and manage your MTAG stuff.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EmailField(controller: _emailController),
            const SizedBox(height: 14),
            PasswordField(
              controller: _passwordController,
              isHidden: form.isPasswordHidden,
              onToggleVisibility: form.togglePasswordVisibility,
              validator: FormValidators.existingPassword,
            ),
            const SizedBox(height: 24),
            MtagPrimaryButton(
              label: 'Log in',
              loading: form.isSubmitting,
              onPressed: _logInWithEmail,
            ),
            const OrDivider(),
            GoogleSignInButton(
              label: 'Continue with Google',
              enabled: !form.isSubmitting,
              onPressed: _logInWithGoogle,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: form.isSubmitting
                  ? null
                  : () => Navigator.pushNamed(context, AppRoutes.register),
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
}
