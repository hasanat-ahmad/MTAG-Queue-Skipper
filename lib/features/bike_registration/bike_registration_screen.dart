import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/app/app_routes.dart';
import 'package:mtag_queue_skipper/features/bike_registration/bike_registration_controller.dart';
import 'package:mtag_queue_skipper/features/bike_registration/bike_registration_input.dart';
import 'package:mtag_queue_skipper/features/bike_registration/widgets/bike_form_sections.dart';
import 'package:mtag_queue_skipper/shared/widgets/mtag_widgets.dart';
import 'package:provider/provider.dart';

/// Owner and bike details form; continues to the face photo on success.
class BikeRegistrationScreen extends StatelessWidget {
  const BikeRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BikeRegistrationController(
        auth: context.read(),
        registration: context.read(),
      ),
      child: const _BikeRegistrationView(),
    );
  }
}

class _BikeRegistrationView extends StatefulWidget {
  const _BikeRegistrationView();

  @override
  State<_BikeRegistrationView> createState() => _BikeRegistrationViewState();
}

class _BikeRegistrationViewState extends State<_BikeRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();
  final _plateController = TextEditingController();
  final _engineController = TextEditingController();
  final _chassisController = TextEditingController();
  final _yearController = TextEditingController();
  String? _brand;
  String? _color;
  bool _confirmed = false;

  List<TextEditingController> get _textControllers => [
    _nameController,
    _phoneController,
    _cnicController,
    _plateController,
    _engineController,
    _chassisController,
    _yearController,
  ];

  @override
  void initState() {
    super.initState();
    _prefillOwnerDetails();
  }

  /// Starts the owner fields from what the rider entered last time.
  void _prefillOwnerDetails() {
    final owner = context.read<BikeRegistrationController>().savedOwner;
    if (owner == null) return;
    if (owner.hasName) _nameController.text = owner.name;
    if (owner.phoneNumber.trim().isNotEmpty) {
      _phoneController.text = owner.phoneNumber;
    }
    if (owner.cnic.trim().isNotEmpty) _cnicController.text = owner.cnic;
  }

  @override
  void dispose() {
    for (final controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    for (final controller in _textControllers) {
      controller.clear();
    }
    setState(() {
      _brand = null;
      _color = null;
      _confirmed = false;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    if (!_confirmed) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please confirm details first')),
      );
      return;
    }
    FocusScope.of(context).unfocus();

    final error = await context.read<BikeRegistrationController>().submit(
      BikeRegistrationInput(
        ownerName: _nameController.text,
        phone: _phoneController.text,
        cnic: _cnicController.text,
        brand: _brand ?? '',
        color: _color ?? '',
        year: _yearController.text,
        plateNumber: _plateController.text,
        engineNumber: _engineController.text,
        chassisNumber: _chassisController.text,
      ),
    );
    if (!mounted) return;

    if (error != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(error), duration: const Duration(seconds: 6)),
      );
      return;
    }
    messenger.showSnackBar(
      const SnackBar(content: Text('Registration submitted ✓')),
    );
    Navigator.pushNamed(context, AppRoutes.faceCapture);
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context
        .watch<BikeRegistrationController>()
        .isSubmitting;

    return MtagScaffold(
      title: 'Register Bike',
      actions: [
        TextButton(
          onPressed: _clearForm,
          child: const Text('Clear', style: TextStyle(color: Colors.black54)),
        ),
      ],
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            const MtagPageHeader(
              title: 'Bike registration',
              subtitle:
                  'Fill in your details — we will generate a queue token after payment.',
              icon: Icons.electric_bike_outlined,
            ),
            OwnerDetailsSection(
              nameController: _nameController,
              phoneController: _phoneController,
              cnicController: _cnicController,
            ),
            BikeInfoSection(
              brand: _brand,
              color: _color,
              yearController: _yearController,
              onBrandChanged: (value) => setState(() => _brand = value),
              onColorChanged: (value) => setState(() => _color = value),
            ),
            RegistrationInfoSection(
              plateController: _plateController,
              engineController: _engineController,
              chassisController: _chassisController,
            ),
            ConfirmDetailsSwitch(
              value: _confirmed,
              onChanged: (value) => setState(() => _confirmed = value),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Registration'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
