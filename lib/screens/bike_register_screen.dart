import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mtag_queue_skipper/models/bike_details.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:mtag_queue_skipper/providers/bike_details_provider.dart';
import 'package:provider/provider.dart';

class BikeRegisterScreen extends StatefulWidget {
  const BikeRegisterScreen({super.key});
  @override
  State<BikeRegisterScreen> createState() => _BikeRegisterScreenState();
}

class _BikeRegisterScreenState extends State<BikeRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _engineCtrl = TextEditingController();
  final _chassisCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  String? _brand, _color;
  bool _accepted = false;
  bool _ownerFieldsPrefilled = false;

  static const int _minYear = 1980;
  static const int _maxYear = 2026;

  static const _brands = [
    'Honda',
    'Yamaha',
    'Suzuki',
    'United',
    'Road Prince',
    'Other',
  ];
  static const _colors = [
    'Black',
    'White',
    'Red',
    'Blue',
    'Grey',
    'Green',
    'Other',
  ];

  void _prefillOwnerFromProfile(AuthProvider auth) {
    if (_ownerFieldsPrefilled) return;
    final user = auth.user;
    if (user == null) return;

    if (_ownerCtrl.text.trim().isEmpty && user.name.trim().isNotEmpty) {
      _ownerCtrl.text = user.name;
    }
    if (_phoneCtrl.text.trim().isEmpty && user.phoneNumber.trim().isNotEmpty) {
      _phoneCtrl.text = user.phoneNumber;
    }
    if (_cnicCtrl.text.trim().isEmpty && user.cnic.trim().isNotEmpty) {
      _cnicCtrl.text = user.cnic;
    }
    _ownerFieldsPrefilled = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefillOwnerFromProfile(context.read<AuthProvider>());
  }

  @override
  void dispose() {
    for (final c in [
      _ownerCtrl,
      _phoneCtrl,
      _cnicCtrl,
      _plateCtrl,
      _engineCtrl,
      _chassisCtrl,
      _yearCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  InputDecoration _dec(String label, {String? hint, Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
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

  Widget _card(String title, List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE0E0E0)),
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

  Widget _row(Widget a, Widget b) => Row(
    children: [
      Expanded(child: a),
      const SizedBox(width: 10),
      Expanded(child: b),
    ],
  );

  Widget _drop(
    String label,
    List<String> items,
    String? val,
    ValueChanged<String?> fn,
  ) => DropdownButtonFormField<String>(
    initialValue: val,
    decoration: _dec(label),
    items: items
        .map(
          (e) => DropdownMenuItem(
            value: e,
            child: Text(e, style: const TextStyle(fontSize: 13)),
          ),
        )
        .toList(),
    onChanged: fn,
    validator: (v) => v == null ? 'Required' : null,
  );

  Future<void> _pickYear() async {
    final currentYear = DateTime.now().year;
    final defaultYear = int.tryParse(_yearCtrl.text) ?? currentYear;
    final sel = defaultYear.clamp(_minYear, _maxYear);
    final y = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Model year'),
        content: SizedBox(
          width: double.maxFinite,
          height: 260,
          child: YearPicker(
            firstDate: DateTime(_minYear),
            lastDate: DateTime(_maxYear),
            selectedDate: DateTime(sel),
            onChanged: (d) => Navigator.pop(ctx, d.year),
          ),
        ),
      ),
    );
    if (y != null && mounted) setState(() => _yearCtrl.text = y.toString());
  }

  void _clear() {
    _formKey.currentState?.reset();
    for (final c in [
      _ownerCtrl,
      _phoneCtrl,
      _cnicCtrl,
      _plateCtrl,
      _engineCtrl,
      _chassisCtrl,
      _yearCtrl,
    ]) {
      c.clear();
    }
    setState(() {
      _brand = _color = null;
      _accepted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bikeDetailsProvider = context.watch<BikeDetailsProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Bike Register',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: _clear,
            child: const Text('Clear', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 32),
          children: [
            _card('Owner Details', [
              TextFormField(
                controller: _ownerCtrl,
                decoration: _dec('Full name'),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              _row(
                TextFormField(
                  controller: _phoneCtrl,
                  decoration: _dec('Phone', hint: '03xx-xxxxxxx'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                      (v == null || v.trim().length < 10) ? 'Invalid' : null,
                ),
                TextFormField(
                  controller: _cnicCtrl,
                  decoration: _dec('CNIC'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
            ]),

            _card('Bike Details', [
              _drop(
                'Brand',
                _brands,
                _brand,
                (v) => setState(() => _brand = v),
              ),
              const SizedBox(height: 10),
              _row(
                _drop(
                  'Color',
                  _colors,
                  _color,
                  (v) => setState(() => _color = v),
                ),
                TextFormField(
                  controller: _yearCtrl,
                  readOnly: true,
                  onTap: _pickYear,
                  decoration: _dec(
                    'Year',
                    suffix: const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                  validator: (v) {
                    final year = int.tryParse(v ?? '');
                    if (year == null) return 'Required';
                    if (year < _minYear || year > _maxYear) {
                      return 'Enter a year between $_minYear and $_maxYear';
                    }
                    return null;
                  },
                ),
              ),
            ]),

            _card('Registration Info', [
              TextFormField(
                controller: _plateCtrl,
                decoration: _dec('Plate number'),
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              _row(
                TextFormField(
                  controller: _engineCtrl,
                  decoration: _dec('Engine no.'),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  controller: _chassisCtrl,
                  decoration: _dec('Chassis no.'),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
            ]),

            Row(
              children: [
                Switch.adaptive(
                  value: _accepted,
                  onChanged: (v) => setState(() => _accepted = v),
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
            ),
            const SizedBox(height: 14),

            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  if (!_accepted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please confirm details first'),
                      ),
                    );
                    return;
                  }
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registration submitted ✓')),
                  );
                  final auth = context.read<AuthProvider>();
                  final ownerName = _ownerCtrl.text.trim();
                  final ownerCnic = _cnicCtrl.text.trim();
                  final ownerPhone = _phoneCtrl.text.trim();

                  final bikeDetails = BikeDetails(
                    plateNumber: _plateCtrl.text.trim(),
                    engineNo: _engineCtrl.text.trim(),
                    chasisNumber: _chassisCtrl.text.trim(),
                    brand: _brand ?? '',
                    color: _color ?? '',
                    year: _yearCtrl.text.trim(),
                  );
                  bikeDetailsProvider.setBikeDetails(bikeDetails);

                  final now = DateTime.now();
                  final tokenNumber =
                      'TKN-${(now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}';

                  bikeDetailsProvider.setTokenData(
                    tokenNumber: tokenNumber,
                    tokenStatus: 'Pending Verification',
                    tokenEstimatedTime: '15-20 minutes',
                    tokenGeneratedAt: now.toIso8601String(),
                  );

                  final user = auth.user;
                  final uid = user?.uid;
                  if (uid != null && user != null) {
                    final saved = await bikeDetailsProvider.saveAllForUser(
                      uid: uid,
                      email: user.email,
                      name: ownerName,
                      cnic: ownerCnic,
                      phoneNumber: ownerPhone,
                    );
                    if (!context.mounted) return;
                    if (!saved) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            bikeDetailsProvider.lastSaveError ??
                                'Cloud sync failed. Check Firestore setup.',
                          ),
                          duration: const Duration(seconds: 6),
                        ),
                      );
                      return;
                    }

                    auth.applyLocalOwnerProfile(
                      name: ownerName,
                      cnic: ownerCnic,
                      phoneNumber: ownerPhone,
                    );
                  }
                  if (!context.mounted) return;

                  Navigator.pushNamed(
                    context,
                    '/face-capture',
                    arguments: {
                      'tokenNumber': tokenNumber,
                      'status': 'Pending Verification',
                      'estimatedTime': '15-20 minutes',
                      'generatedAt': now.toIso8601String(),
                    },
                  );
                },
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
                child: const Text('Submit Registration'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
