import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/core/utils/form_validators.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';

/// Email input with autofill and validation.
class EmailField extends StatelessWidget {
  const EmailField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      decoration: mtagInputDecoration(
        label: 'Email',
        hint: 'you@example.com',
        prefixIcon: Icons.email_outlined,
      ),
      validator: FormValidators.email,
    );
  }
}
