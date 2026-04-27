import 'package:flutter/material.dart';
import 'add_promo5_screen.dart';

class AddPromotion4Screen extends StatefulWidget {
  final Map<String, dynamic> draftData;

  const AddPromotion4Screen({
    super.key,
    this.draftData = const <String, dynamic>{},
  });

  @override
  State<AddPromotion4Screen> createState() => _AddPromotion4ScreenState();
}

class _AddPromotion4ScreenState extends State<AddPromotion4Screen> {
  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);
  static const Color _lightBg = Color(0xFFF5F6FA);

  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(
    text: 'Barranquilla',
  );
  final TextEditingController _scheduleController = TextEditingController(
    text: 'Lun-Sáb 9-7pm',
  );

  bool _onlineOnly = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final draft = widget.draftData;

    _storeNameController.text = (draft['storeName'] as String?) ?? '';
    _phoneController.text = (draft['phone'] as String?) ?? '';
    _websiteController.text = (draft['website'] as String?) ?? '';
    _addressController.text = (draft['address'] as String?) ?? '';
    _cityController.text = (draft['city'] as String?) ?? _cityController.text;
    _scheduleController.text =
        (draft['schedule'] as String?) ?? _scheduleController.text;
    _onlineOnly = (draft['onlineOnly'] as bool?) ?? false;
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    if (_onlineOnly) return true;
    return _storeNameController.text.isNotEmpty &&
        _addressController.text.isNotEmpty;
  }

  Future<void> _onNext() async {
    setState(() => _isLoading = true);

    final location = _onlineOnly
        ? 'Solo en línea'
        : [
            _addressController.text.trim(),
            _cityController.text.trim(),
          ].where((e) => e.isNotEmpty).join(', ');

    final nextDraft = <String, dynamic>{
      ...widget.draftData,
      'storeName': _storeNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'website': _websiteController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'schedule': _scheduleController.text.trim(),
      'onlineOnly': _onlineOnly,
      'location': location,
    };

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPromotion5Screen(
          draftData: nextDraft,
          promoTitle: nextDraft['title'] as String?,
          location: nextDraft['location'] as String?,
          imageUrl: nextDraft['imageUrl'] as String?,
        ),
      ),
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado
                  const Text(
                    'Tienda y ubicación',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '¿Dónde pueden encontrar esta promoción?',
                    style: TextStyle(fontSize: 13.5, color: Color(0xFF8A8FA8)),
                  ),
                  const SizedBox(height: 20),

                  // Toggle solo en línea
                  _buildOnlineToggle(),
                  const SizedBox(height: 20),

                  // Campos (ocultos si es solo en línea)
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: _onlineOnly
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre de la tienda
                        _buildLabeledField(
                          label: 'Nombre de la tienda',
                          required: true,
                          child: _buildTextField(
                            controller: _storeNameController,
                            hint: 'Ej: Nike Store Andino',
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Teléfono + Sitio web
                        Row(
                          children: [
                            Expanded(
                              child: _buildLabeledField(
                                label: 'Teléfono',
                                child: _buildTextField(
                                  controller: _phoneController,
                                  hint: '300 000 0000',
                                  keyboardType: TextInputType.phone,
                                  prefixIcon: Icons.phone_outlined,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildLabeledField(
                                label: 'Sitio web',
                                child: _buildTextField(
                                  controller: _websiteController,
                                  hint: 'www.tienda.co',
                                  keyboardType: TextInputType.url,
                                  prefixIcon: Icons.language_rounded,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Mapa placeholder
                        _buildMapPlaceholder(),
                        const SizedBox(height: 18),

                        // Dirección exacta
                        _buildLabeledField(
                          label: 'Dirección exacta',
                          required: true,
                          child: _buildTextField(
                            controller: _addressController,
                            hint: 'Cra 11 #82-01, Barranquilla',
                            prefixIcon: Icons.location_on_outlined,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Ciudad + Horario
                        Row(
                          children: [
                            Expanded(
                              child: _buildLabeledField(
                                label: 'Ciudad',
                                child: _buildTextField(
                                  controller: _cityController,
                                  hint: 'Barranquilla',
                                  prefixIcon: Icons.location_city_outlined,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildLabeledField(
                                label: 'Horario',
                                child: _buildTextField(
                                  controller: _scheduleController,
                                  hint: 'Lun-Sáb 9-7pm',
                                  prefixIcon: Icons.access_time_rounded,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    secondChild: _buildOnlineOnlyMessage(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F1F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF1A1F2E),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Nueva Promo',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1F2E),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Descuento %',
                  style: TextStyle(
                    color: _primary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStepper(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    final steps = [
      _WizardStep(icon: Icons.percent_rounded, label: 'Tipo', done: true),
      _WizardStep(
        icon: Icons.inventory_2_outlined,
        label: 'Producto',
        done: true,
      ),
      _WizardStep(
        icon: Icons.attach_money_rounded,
        label: 'Precio',
        done: true,
      ),
      _WizardStep(icon: Icons.store_outlined, label: 'Tienda', active: true),
      _WizardStep(icon: Icons.send_outlined, label: 'Publicar'),
    ];

    return Row(
      children: List.generate(steps.length, (i) {
        final s = steps[i];
        final isLast = i == steps.length - 1;

        Color bgColor;
        Color iconColor;
        Color labelColor;
        Color lineColor;

        if (s.done) {
          bgColor = _primary;
          iconColor = Colors.white;
          labelColor = _primary;
          lineColor = _primary;
        } else if (s.active) {
          bgColor = _darkBg;
          iconColor = Colors.white;
          labelColor = _darkBg;
          lineColor = const Color(0xFFE0E2EA);
        } else {
          bgColor = const Color(0xFFF0F1F5);
          iconColor = const Color(0xFFB0B5CC);
          labelColor = const Color(0xFFB0B5CC);
          lineColor = const Color(0xFFE0E2EA);
        }

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: s.done
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : Icon(s.icon, color: iconColor, size: 18),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      s.label,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: labelColor,
                        fontWeight: s.active || s.done
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 16,
                  height: 2,
                  color: lineColor,
                  margin: const EdgeInsets.only(bottom: 16),
                ),
            ],
          ),
        );
      }),
    );
  }

  // ── Toggle solo en línea ─────────────────────────────────────────────────────

  Widget _buildOnlineToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EAF0), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F1F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.language_rounded,
              color: Color(0xFF8A8FA8),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solo disponible en línea',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1F2E),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Sin ubicación física requerida',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8A8FA8)),
                ),
              ],
            ),
          ),
          Switch(
            value: _onlineOnly,
            onChanged: (v) => setState(() => _onlineOnly = v),
            activeColor: _primary,
            activeTrackColor: _primary.withOpacity(0.3),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE0E2EA),
          ),
        ],
      ),
    );
  }

  // ── Mapa placeholder ─────────────────────────────────────────────────────────

  Widget _buildMapPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubicación en el mapa',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F2E),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD0DCF8), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () {
                  // Abrir selector de mapa
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _darkBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: _primary,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Seleccionar en mapa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Mensaje solo en línea ────────────────────────────────────────────────────

  Widget _buildOnlineOnlyMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _primary.withOpacity(0.2), width: 1.2),
      ),
      child: Row(
        children: const [
          Icon(Icons.check_circle_rounded, color: _primary, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Esta promo estará disponible solo en línea. No se requiere dirección física.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF92300A),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _buildLabeledField({
    required String label,
    bool required = false,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1F2E),
              ),
            ),
            if (required)
              const Text(' *', style: TextStyle(color: _primary, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1F2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCDD0DB), fontSize: 13.5),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: const Color(0xFFB0B5CC), size: 18)
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8EAF0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8EAF0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.8),
        ),
      ),
    );
  }

  // ── Bottom bar ───────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _darkBg,
                      side: const BorderSide(
                        color: Color(0xFFE0E2EA),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_rounded, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Atrás',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _canContinue ? _onNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkBg,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _darkBg.withOpacity(0.4),
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Siguiente',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Paso 4 de 5 — 80% completado',
            style: TextStyle(fontSize: 12, color: Color(0xFFB0B5CC)),
          ),
        ],
      ),
    );
  }
}

// ── Modelo auxiliar ────────────────────────────────────────────────────────────

class _WizardStep {
  final IconData icon;
  final String label;
  final bool done;
  final bool active;

  const _WizardStep({
    required this.icon,
    required this.label,
    this.done = false,
    this.active = false,
  });
}
