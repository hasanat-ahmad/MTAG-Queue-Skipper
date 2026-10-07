import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';

/// Password input with a show/hide toggle.
class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.isHidden,
    required this.onToggleVisibility,
    required this.validator,
    this.isNewPassword = false,
    this.hint,
  });

  final TextEditingController controller;
  final bool isHidden;
  final VoidCallback onToggleVisibility;
  final FormFieldValidator<String> validator;

  /// Lets password managers offer to generate and save a new password.
  final bool isNewPassword;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isHidden,
      autofillHints: [
        isNewPassword ? AutofillHints.newPassword : AutofillHints.password,
      ],
      decoration: mtagInputDecoration(
        label: 'Password',
        hint: hint,
        prefixIcon: Icons.lock_outline,
        suffix: IconButton(
          icon: Icon(
            isHidden
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
      validator: validator,
    );
  }
}
