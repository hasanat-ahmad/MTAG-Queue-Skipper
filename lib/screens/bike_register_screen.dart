import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/constants/app_fonts.dart';
import 'package:mtag_queue_skipper/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class BikeRegisterScreen extends StatefulWidget {
  const BikeRegisterScreen({super.key});

  @override
  State<BikeRegisterScreen> createState() => _BikeRegisterScreenState();
}

class _BikeRegisterScreenState extends State<BikeRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _modelYearController = TextEditingController();
  final _plateController = TextEditingController();
  final _engineController = TextEditingController();
  final _chassisController = TextEditingController();

  static const Color _bg = Color(0xFFF4F1FA);
  static const Color _card = Color(0xFFFFFFFF);
  static const Color _muted = Color(0xFF6B6B76);
  static const Color _line = Color(0xFFE1E3E4);
  static const Color _fieldFill = Color(0xFFF3F4F5);
  static const Color _ink = Color(0xFF191C1D);

  String? _brand;
  String? _bikeModel;

  static const _brands = [
    'Honda',
    'Yamaha',
    'Suzuki',
    'United',
    'Road Prince',
    'Super Power',
  ];

  /// Popular local and common bike models (single list; user picks brand separately).
  static const _bikeModels = [
    'CD 70',
    'CD 100',
    'CD 125',
    'Pridor',
    'CBR 150R',
    'YBR 125',
    'YZF-R15',
    'GS 150 SE',
    'GR 150',
    'Hayate EP',
    'United 125',
    'Other',
  ];

  @override
  void dispose() {
    _ownerNameController.dispose();
    _modelYearController.dispose();
    _plateController.dispose();
    _engineController.dispose();
    _chassisController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: _muted.withValues(alpha: 0.55),
        fontFamily: AppFonts.primaryFont,
        fontSize: 15,
      ),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: UnderlineInputBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: UnderlineInputBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        borderSide: const BorderSide(color: _line, width: 2),
      ),
      focusedBorder: UnderlineInputBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        borderSide: const BorderSide(color: _ink, width: 2),
      ),
      errorBorder: UnderlineInputBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
      ),
      errorStyle: const TextStyle(
        fontSize: 11,
        fontFamily: AppFonts.primaryFont,
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: AppFonts.primaryFont,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _muted,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _hintLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 6),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.primaryFont,
          fontSize: 11,
          height: 1.35,
          color: _muted.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: _ink,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: _ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Future<void> _pickModelYear() async {
    final now = DateTime.now();
    final maxYear = now.year + 1;
    final parsed = int.tryParse(_modelYearController.text.trim());
    var selectedYear = parsed ?? now.year;
    if (selectedYear < 1980) selectedYear = 1980;
    if (selectedYear > maxYear) selectedYear = maxYear;

    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Model year',
            style: TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(1980),
              lastDate: DateTime(maxYear),
              selectedDate: DateTime(selectedYear),
              onChanged: (DateTime d) {
                Navigator.pop(ctx, d.year);
              },
            ),
          ),
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _modelYearController.text = picked.toString());
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final nav = Navigator.of(context);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Future<void>.delayed(const Duration(milliseconds: 2800), () {
          if (!mounted) return;
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
          if (!mounted) return;
          nav.pushNamedAndRemoveUntil('/home', (route) => false);
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: _card,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _fieldFill,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    size: 40,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Registration received',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your token will be issued soon after we verify your bike details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.primaryFont,
                    fontSize: 14,
                    height: 1.45,
                    color: _muted.withValues(alpha: 0.92),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: _ink.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showWhereToFind({required String title, required String explanation}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.paddingOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 12, 16, 20 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _line,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                        height: 1.25,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: IconButton.styleFrom(
                      foregroundColor: _muted,
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                explanation,
                style: TextStyle(
                  fontFamily: AppFonts.primaryFont,
                  fontSize: 14,
                  height: 1.5,
                  color: _muted.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Tappable info icon (circle with “i”) — opens where-to-find help.
  Widget _locationHintInfoIcon({required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: 'Where to find this',
          child: Icon(Icons.info_outlined, size: 24, color: _ink),
        ),
      ),
    );
  }

  Widget _labelWithHint(String label, VoidCallback onHint) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _muted,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _locationHintInfoIcon(onTap: onHint),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AuthProvider>().user?.name ?? '';
    final initial = userName.trim().isNotEmpty
        ? userName.trim()[0].toUpperCase()
        : '';

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: IconButton.styleFrom(
                          foregroundColor: _ink,
                          backgroundColor: Colors.white.withValues(alpha: 0.6),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      Expanded(
                        child: Text(
                          'Bike Registration',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: _card,
                            child: initial.isEmpty
                                ? Icon(
                                    Icons.person_outline,
                                    color: _muted.withValues(alpha: 0.8),
                                  )
                                : Text(
                                    initial,
                                    style: const TextStyle(
                                      fontFamily: AppFonts.primaryFont,
                                      fontWeight: FontWeight.w800,
                                      color: _ink,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text(
                      'Register your bike',
                      style: TextStyle(
                        fontFamily: AppFonts.primaryFont,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        color: _ink,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _sectionCard(
                      icon: Icons.person_outline_rounded,
                      title: 'OWNER',
                      children: [
                        _label('Full name (as per CNIC)'),
                        TextFormField(
                          controller: _ownerNameController,
                          textCapitalization: TextCapitalization.words,
                          style: const TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontSize: 15,
                            color: _ink,
                          ),
                          decoration: _fieldDecoration('e.g. Ahmad Hassan'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      icon: Icons.two_wheeler_rounded,
                      title: 'BIKE',
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Company'),
                                  DropdownButtonFormField<String>(
                                    // ignore: deprecated_member_use
                                    value: _brand,
                                    hint: Text(
                                      'Select brand',
                                      style: TextStyle(
                                        fontFamily: AppFonts.primaryFont,
                                        color: _muted.withValues(alpha: 0.5),
                                        fontSize: 15,
                                      ),
                                    ),
                                    decoration: _fieldDecoration(''),
                                    items: _brands
                                        .map(
                                          (b) => DropdownMenuItem(
                                            value: b,
                                            child: Text(
                                              b,
                                              style: const TextStyle(
                                                fontFamily:
                                                    AppFonts.primaryFont,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) => setState(() {
                                      _brand = v;
                                      _bikeModel = null;
                                    }),
                                    validator: (v) => v == null || v.isEmpty
                                        ? 'Choose a brand'
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Model year'),
                                  TextFormField(
                                    controller: _modelYearController,
                                    readOnly: true,
                                    onTap: _pickModelYear,
                                    style: const TextStyle(
                                      fontFamily: AppFonts.primaryFont,
                                      fontSize: 15,
                                      color: _ink,
                                    ),
                                    decoration:
                                        _fieldDecoration(
                                          'Tap to pick year',
                                        ).copyWith(
                                          suffixIcon: IconButton(
                                            onPressed: _pickModelYear,
                                            icon: const Icon(
                                              Icons.calendar_today_outlined,
                                              size: 20,
                                            ),
                                            color: _muted,
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Pick a year';
                                      }
                                      final y = int.tryParse(v.trim());
                                      final maxY = DateTime.now().year + 1;
                                      if (y == null || y < 1980 || y > maxY) {
                                        return 'Invalid year';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _label('Model'),
                        DropdownButtonFormField<String>(
                          // ignore: deprecated_member_use
                          value: _bikeModel,
                          hint: Text(
                            'Select model',
                            style: TextStyle(
                              fontFamily: AppFonts.primaryFont,
                              color: _muted.withValues(alpha: 0.5),
                              fontSize: 15,
                            ),
                          ),
                          decoration: _fieldDecoration(''),
                          isExpanded: true,
                          items: _bikeModels
                              .map(
                                (m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(
                                    m,
                                    style: const TextStyle(
                                      fontFamily: AppFonts.primaryFont,
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _bikeModel = v),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Choose a model' : null,
                        ),
                        const SizedBox(height: 18),
                        _label('Number plate'),
                        TextFormField(
                          controller: _plateController,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: _ink,
                          ),
                          decoration: _fieldDecoration('ABC-1234').copyWith(
                            suffix: Padding(
                              padding: const EdgeInsets.only(right: 8, top: 12),
                              child: Text(
                                'Format',
                                style: TextStyle(
                                  fontFamily: AppFonts.primaryFont,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: _muted.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Plate is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      icon: Icons.precision_manufacturing_outlined,
                      title: 'TECHNICAL',
                      children: [
                        _labelWithHint(
                          'Engine number',
                          () => _showWhereToFind(
                            title: 'Where is the engine number?',
                            explanation:
                                'Open the left or right engine cover area and look for a stamped or engraved code on the metal casing—often on the lower crankcase or near the clutch side. Some bikes use a small riveted plate. Wipe off dirt and use good light; the stamp can be shallow.',
                          ),
                        ),
                        TextFormField(
                          controller: _engineController,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontSize: 15,
                            color: _ink,
                            letterSpacing: 0.3,
                          ),
                          decoration: _fieldDecoration(
                            'e.g. JH2KE0400AK123456',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Engine number is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _labelWithHint(
                          'Chassis number (frame / VIN)',
                          () => _showWhereToFind(
                            title: 'Where is the chassis number?',
                            explanation:
                                'Check the steering head—the front of the frame where the handlebar stem meets the frame. The number is usually stamped on the right or left frame tube just below the triple clamp, or on a factory sticker on the frame. It is the same number often listed as “frame no.” on your registration.',
                          ),
                        ),
                        TextFormField(
                          controller: _chassisController,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontSize: 15,
                            color: _ink,
                            letterSpacing: 0.3,
                          ),
                          decoration: _fieldDecoration('e.g. MD626A'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Chassis number is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: _line.withValues(alpha: 0.8)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 28,
                            color: _muted.withValues(alpha: 0.45),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'VERIFICATION',
                                  style: TextStyle(
                                    fontFamily: AppFonts.primaryFont,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.4,
                                    color: _muted.withValues(alpha: 0.75),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'We cross-check with excise records before issuing M-TAG token.',
                                  style: TextStyle(
                                    fontFamily: AppFonts.primaryFont,
                                    fontSize: 13,
                                    height: 1.35,
                                    fontWeight: FontWeight.w600,
                                    color: _ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: _ink,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: AppFonts.primaryFont,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Submit registration'),
                            SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
