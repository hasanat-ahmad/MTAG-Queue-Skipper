import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/core/theme/app_colors.dart';

/// Compact field decoration used throughout the bike registration form.
InputDecoration bikeFormFieldDecoration(
  String label, {
  String? hint,
  Widget? suffix,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.black, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
  );
}

/// Titled white card grouping a set of form fields.
class BikeFormSection extends StatelessWidget {
  const BikeFormSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

/// Two fields side by side, sharing the width equally.
class FieldPair extends StatelessWidget {
  const FieldPair({super.key, required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: first),
        const SizedBox(width: 10),
        Expanded(child: second),
      ],
    );
  }
}

/// Required drop-down for a fixed list of [options].
class BikeDropdownField extends StatelessWidget {
  const BikeDropdownField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: bikeFormFieldDecoration(label),
      items: [
        for (final option in options)
          DropdownMenuItem(
            value: option,
            child: Text(option, style: const TextStyle(fontSize: 13)),
          ),
      ],
      onChanged: onChanged,
      validator: (selected) => selected == null ? 'Required' : null,
    );
  }
}

/// Read-only field that opens a year picker between [firstYear] and
/// [lastYear].
class ModelYearField extends StatelessWidget {
  const ModelYearField({
    super.key,
    required this.controller,
    required this.firstYear,
    required this.lastYear,
  });

  final TextEditingController controller;
  final int firstYear;
  final int lastYear;

  Future<void> _pickYear(BuildContext context) async {
    final current = int.tryParse(controller.text) ?? DateTime.now().year;
    final initial = current.clamp(firstYear, lastYear);
    final picked = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Model year'),
        content: SizedBox(
          width: double.maxFinite,
          height: 260,
          child: YearPicker(
            firstDate: DateTime(firstYear),
            lastDate: DateTime(lastYear),
            selectedDate: DateTime(initial),
            onChanged: (date) => Navigator.pop(dialogContext, date.year),
          ),
        ),
      ),
    );
    if (picked != null && context.mounted) {
      controller.text = picked.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _pickYear(context),
      decoration: bikeFormFieldDecoration(
        'Year',
        suffix: const Icon(
          Icons.calendar_today_outlined,
          size: 16,
          color: Colors.grey,
        ),
      ),
      validator: (value) {
        final year = int.tryParse(value ?? '');
        if (year == null) return 'Required';
        if (year < firstYear || year > lastYear) {
          return 'Enter a year between $firstYear and $lastYear';
        }
        return null;
      },
    );
  }
}
