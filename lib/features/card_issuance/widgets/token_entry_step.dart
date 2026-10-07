import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/features/card_issuance/card_issuance_controller.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';
import 'package:provider/provider.dart';

/// Step 1: the rider enters their queue token (pre-filled when known).
class TokenEntryStep extends StatefulWidget {
  const TokenEntryStep({super.key});

  @override
  State<TokenEntryStep> createState() => _TokenEntryStepState();
}

class _TokenEntryStepState extends State<TokenEntryStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tokenController;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(
      text: context.read<CardIssuanceController>().suggestedToken,
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CardIssuanceController>().submitToken(_tokenController.text);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CardIssuanceController>();
    final error = controller.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MtagPageHeader(
          title: 'Got your token?',
          subtitle:
              'Enter it below, then we will match your face to your registration photo.',
          icon: Icons.credit_card_outlined,
        ),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _tokenController,
            textCapitalization: TextCapitalization.characters,
            decoration: mtagInputDecoration(
              label: 'Token number',
              hint: 'e.g. TKN-1234',
              prefixIcon: Icons.confirmation_number_outlined,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Token number is required';
              }
              return null;
            },
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 12),
          InlineErrorText(error),
        ],
        const Spacer(),
        MtagPrimaryButton(
          label: 'Continue',
          loading: controller.isBusy,
          onPressed: _submit,
        ),
      ],
    );
  }
}
