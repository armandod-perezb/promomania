import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'add_promo4_screen.dart';

/// Pantalla paso 3 del wizard de creación de promociones: Precio y Vigencia.
///
/// Responsabilidades principales:
/// - Recoger el precio y el descuento de la promoción.
/// - Permitir elegir si la promo es permanente o por fechas y seleccionar
///   las fechas de inicio y fin cuando aplica.
/// - Validar los campos necesarios antes de permitir avanzar al siguiente paso.
/// - Pasar los datos recogidos al siguiente paso mediante `draftData`.

class AddPromotion3Screen extends StatefulWidget {
  final Map<String, dynamic> draftData;

  const AddPromotion3Screen({
    super.key,
    this.draftData = const <String, dynamic>{},
  });

  @override
  State<AddPromotion3Screen> createState() => _AddPromotion3ScreenState();
}

/// Estado interno de `AddPromotion3Screen`; coordina datos, eventos y reconstrucciones de la pantalla.
class _AddPromotion3ScreenState extends State<AddPromotion3Screen> {
  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);
  static const Color _lightBg = Color(0xFFF5F6FA);

  final TextEditingController _priceController = TextEditingController(
    text: '0',
  );
  final TextEditingController _discountController = TextEditingController();

  String _vigenciaType = 'fechas'; // 'fechas' | 'permanente'
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final draft = widget.draftData;

    final draftPrice = draft['price'];
    if (draftPrice is num && draftPrice > 0) {
      _priceController.text = draftPrice.toString();
    }

    final draftDiscount = draft['discount'];
    if (draftDiscount is num && draftDiscount >= 0) {
      _discountController.text = draftDiscount.toInt().toString();
    }

    final draftVigencia = draft['vigenciaType'] as String?;
    if (draftVigencia == 'fechas' || draftVigencia == 'permanente') {
      _vigenciaType = draftVigencia!;
    }

    final fechaInicio = _parseIsoDate(draft['fechaInicio'] as String?);
    final fechaFin = _parseIsoDate(draft['fechaFin'] as String?);
    _fechaInicio = fechaInicio;
    _fechaFin = fechaFin;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    final price = double.tryParse(_priceController.text) ?? 0;
    final discount =
        double.tryParse(_discountController.text.replaceAll('%', '')) ?? -1;
    if (price <= 0 || discount < 0 || discount > 100) return false;
    if (_vigenciaType == 'fechas') {
      return _fechaInicio != null && _fechaFin != null;
    }
    return true;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_fechaInicio ?? now)
          : (_fechaFin ?? (_fechaInicio ?? now).add(const Duration(days: 7))),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _primary)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _fechaInicio = picked;
          if (_fechaFin != null && _fechaFin!.isBefore(picked)) {
            _fechaFin = null;
          }
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  DateTime? _parseIsoDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String? _toIsoDate(DateTime? date) {
    if (date == null) return null;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String().split('T').first;
  }

  Future<void> _onNext() async {
    setState(() => _isLoading = true);

    final nextDraft = <String, dynamic>{
      ...widget.draftData,
      'price': double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0,
      'discount': int.tryParse(_discountController.text.replaceAll('%', '')),
      'vigenciaType': _vigenciaType,
      'fechaInicio': _vigenciaType == 'fechas'
          ? _toIsoDate(_fechaInicio)
          : null,
      'fechaFin': _vigenciaType == 'fechas' ? _toIsoDate(_fechaFin) : null,
    };

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPromotion4Screen(draftData: nextDraft),
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
                    'Precio y vigencia',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Define el valor real de tu oferta en COP',
                    style: TextStyle(fontSize: 13.5, color: Color(0xFF8A8FA8)),
                  ),
                  const SizedBox(height: 24),

                  // Precio original + Descuento
                  Row(
                    children: [
                      Expanded(
                        child: _buildLabeledWidget(
                          label: 'Precio original',
                          required: true,
                          child: _buildPriceField(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildLabeledWidget(
                          label: 'Descuento',
                          required: true,
                          child: _buildDiscountField(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tipo de vigencia
                  _buildVigenciaSelector(),
                  const SizedBox(height: 20),

                  // Fechas (solo si tipo = 'fechas')
                  if (_vigenciaType == 'fechas') ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildLabeledWidget(
                            label: 'Fecha inicio',
                            child: _buildDateField(
                              value: _formatDate(_fechaInicio),
                              onTap: () => _pickDate(isStart: true),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildLabeledWidget(
                            label: 'Fecha fin',
                            child: _buildDateField(
                              value: _formatDate(_fechaFin),
                              onTap: () => _pickDate(isStart: false),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Aviso de precios verídicos
                  _buildWarningBanner(),
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
        active: true,
      ),
      _WizardStep(icon: Icons.store_outlined, label: 'Tienda'),
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

  // ── Campos de precio y descuento ─────────────────────────────────────────────

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => setState(() {}),
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1F2E),
      ),
      decoration: InputDecoration(
        prefixText: '\$ ',
        prefixStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1F2E),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
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

  Widget _buildDiscountField() {
    final hasValue = _discountController.text.isNotEmpty;
    return TextFormField(
      controller: _discountController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => setState(() {}),
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: hasValue ? _primary : const Color(0xFFCDD0DB),
      ),
      decoration: InputDecoration(
        hintText: '0%',
        hintStyle: const TextStyle(
          color: _primary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        suffixText: hasValue ? '%' : '',
        suffixStyle: const TextStyle(
          color: _primary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 1.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
      ),
    );
  }

  // ── Tipo de vigencia ─────────────────────────────────────────────────────────

  Widget _buildVigenciaSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de vigencia',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F2E),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _vigenciaChip(
              id: 'fechas',
              label: 'Por fechas',
              icon: Icons.calendar_month_rounded,
            ),
            const SizedBox(width: 12),
            _vigenciaChip(
              id: 'permanente',
              label: 'Permanente',
              icon: Icons.check_circle_outline_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _vigenciaChip({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _vigenciaType == id;
    return GestureDetector(
      onTap: () => setState(() => _vigenciaType = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _primary : const Color(0xFFE8EAF0),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF8A8FA8),
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF1A1F2E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Campo de fecha ───────────────────────────────────────────────────────────

  Widget _buildDateField({required String value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8EAF0), width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFFB0B5CC),
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              value.isEmpty ? '' : value,
              style: TextStyle(
                fontSize: 14,
                color: value.isEmpty
                    ? const Color(0xFFCDD0DB)
                    : const Color(0xFF1A1F2E),
                fontWeight: value.isEmpty ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Banner de aviso ──────────────────────────────────────────────────────────

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE082), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Los precios deben ser verídicos. Promos con información falsa serán eliminadas y la cuenta suspendida.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF92651A),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper widgets ───────────────────────────────────────────────────────────

  Widget _buildLabeledWidget({
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
            'Paso 3 de 5 — 60% completado',
            style: TextStyle(fontSize: 12, color: Color(0xFFB0B5CC)),
          ),
        ],
      ),
    );
  }
}

// ── Modelo auxiliar ────────────────────────────────────────────────────────────

/// Tipo auxiliar interno usado por promociones para mantener la pantalla organizada.
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
