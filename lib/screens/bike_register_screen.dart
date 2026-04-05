import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  String? _brand, _model, _color;
  bool _accepted = false;

  static const _brands = [
    'Honda',
    'Yamaha',
    'Suzuki',
    'United',
    'Road Prince',
    'Other',
  ];
  static const _models = [
    'CD 70',
    'CD 100',
    'CD 125',
    'Pridor',
    'YBR 125',
    'GS 150',
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
    ])
      c.dispose();
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
    final now = DateTime.now().year;
    final sel = (int.tryParse(_yearCtrl.text) ?? now).clamp(1980, now + 1);
    final y = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Model year'),
        content: SizedBox(
          width: double.maxFinite,
          height: 260,
          child: YearPicker(
            firstDate: DateTime(1980),
            lastDate: DateTime(now + 1),
            selectedDate: DateTime(sel),
            onChanged: (d) => Navigator.pop(ctx, d.year),
          ),
        ),
      ),
    );
    if (y != null && mounted) setState(() => _yearCtrl.text = y.toString());
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_accepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please confirm details first')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Registration submitted ✓')));
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
    ])
      c.clear();
    setState(() {
      _brand = _model = _color = null;
      _accepted = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
            _row(
              _drop(
                'Brand',
                _brands,
                _brand,
                (v) => setState(() => _brand = v),
              ),
              _drop(
                'Model',
                _models,
                _model,
                (v) => setState(() => _model = v),
              ),
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
                validator: (v) =>
                    int.tryParse(v ?? '') == null ? 'Required' : null,
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
                activeColor: Colors.black,
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
              onPressed: _submit,
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
