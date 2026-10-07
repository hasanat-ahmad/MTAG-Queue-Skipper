import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mtag_queue_skipper/core/utils/form_validators.dart';
import 'package:mtag_queue_skipper/core/utils/pakistan_validators.dart';
import 'package:mtag_queue_skipper/features/bike_registration/bike_registration_input.dart';
import 'package:mtag_queue_skipper/features/bike_registration/widgets/bike_form_fields.dart';

/// Owner name, phone and CNIC.
class OwnerDetailsSection extends StatelessWidget {
  const OwnerDetailsSection({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.cnicController,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController cnicController;

  @override
  Widget build(BuildContext context) {
    return BikeFormSection(
      title: 'Owner Details',
      children: [
        TextFormField(
          controller: nameController,
          decoration: bikeFormFieldDecoration('Full name'),
          textInputAction: TextInputAction.next,
          inputFormatters: [
            LengthLimitingTextInputFormatter(FieldLimits.ownerName),
          ],
          validator: FormValidators.required,
        ),
        const SizedBox(height: 10),
        FieldPair(
          first: TextFormField(
            controller: phoneController,
            decoration: bikeFormFieldDecoration('Phone', hint: '03xx-xxxxxxx'),
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: PakistanValidators.validatePhone,
          ),
          second: TextFormField(
            controller: cnicController,
            decoration: bikeFormFieldDecoration(
              'CNIC',
              hint: '35202-1234567-1',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: PakistanValidators.validateCnic,
          ),
        ),
      ],
    );
  }
}

/// Brand, colour and model year.
class BikeInfoSection extends StatelessWidget {
  const BikeInfoSection({
    super.key,
    required this.brand,
    required this.color,
    required this.yearController,
    required this.onBrandChanged,
    required this.onColorChanged,
  });

  final String? brand;
  final String? color;
  final TextEditingController yearController;
  final ValueChanged<String?> onBrandChanged;
  final ValueChanged<String?> onColorChanged;

  @override
  Widget build(BuildContext context) {
    return BikeFormSection(
      title: 'Bike Details',
      children: [
        BikeDropdownField(
          label: 'Brand',
          options: BikeOptions.brands,
          value: brand,
          onChanged: onBrandChanged,
        ),
        const SizedBox(height: 10),
        FieldPair(
          first: BikeDropdownField(
            label: 'Color',
            options: BikeOptions.colors,
            value: color,
            onChanged: onColorChanged,
          ),
          second: ModelYearField(
            controller: yearController,
            firstYear: BikeOptions.minModelYear,
            lastYear: BikeOptions.maxModelYear,
          ),
        ),
      ],
    );
  }
}

/// Plate, engine and chassis numbers.
class RegistrationInfoSection extends StatelessWidget {
  const RegistrationInfoSection({
    super.key,
    required this.plateController,
    required this.engineController,
    required this.chassisController,
  });

  final TextEditingController plateController;
  final TextEditingController engineController;
  final TextEditingController chassisController;

  @override
  Widget build(BuildContext context) {
    return BikeFormSection(
      title: 'Registration Info',
      children: [
        TextFormField(
          controller: plateController,
          decoration: bikeFormFieldDecoration('Plate number'),
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            LengthLimitingTextInputFormatter(FieldLimits.plateNumber),
          ],
          validator: FormValidators.required,
        ),
        const SizedBox(height: 10),
        FieldPair(
          first: TextFormField(
            controller: engineController,
            decoration: bikeFormFieldDecoration('Engine no.'),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              LengthLimitingTextInputFormatter(FieldLimits.engineNumber),
            ],
            validator: FormValidators.required,
          ),
          second: TextFormField(
            controller: chassisController,
            decoration: bikeFormFieldDecoration('Chassis no.'),
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              LengthLimitingTextInputFormatter(FieldLimits.chassisNumber),
            ],
            validator: FormValidators.required,
          ),
        ),
      ],
    );
  }
}

/// "I confirm these details are accurate" switch.
class ConfirmDetailsSwitch extends StatelessWidget {
  const ConfirmDetailsSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.black,
        ),
        const SizedBox(width: 6),
        const Expanded(
          child: Text(
            'I confirm these details are accurate',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
