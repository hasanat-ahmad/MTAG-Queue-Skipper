import 'package:flutter/material.dart';

/// Centred red message for an error that belongs to the current step,
/// e.g. a declined payment or a face that did not match.
class InlineErrorText extends StatelessWidget {
  const InlineErrorText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
      textAlign: TextAlign.center,
    );
  }
}
