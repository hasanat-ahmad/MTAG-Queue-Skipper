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

/// Account creation with email/password or Google.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthFormController(
        auth: context.read(),
        registration: context.read(),
      ),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await context.read<AuthFormController>().signUpWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
    _onResult(result);
  }

  Future<void> _signUpWithGoogle() async {
    final result = await context
        .read<AuthFormController>()
        .continueWithGoogle();
    _onResult(result);
  }

  void _onResult(AuthResult result) {
    if (!mounted) return;
    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Sign up failed.')),
      );
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<AuthFormController>();

    return AuthLayout(
      title: 'Create your account',
      subtitle: 'Sign up with email or jump in with Google — takes a minute.',
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
              validator: FormValidators.newPassword,
              isNewPassword: true,
              hint: 'At least ${FormValidators.minPasswordLength} characters',
            ),
            const SizedBox(height: 24),
            MtagPrimaryButton(
              label: 'Sign up',
              loading: form.isSubmitting,
              onPressed: _signUpWithEmail,
            ),
            const OrDivider(),
            GoogleSignInButton(
              label: 'Sign up with Google',
              enabled: !form.isSubmitting,
              onPressed: _signUpWithGoogle,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: form.isSubmitting
                  ? null
                  : () => Navigator.pop(context),
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
}
