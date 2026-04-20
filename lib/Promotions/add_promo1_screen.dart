import 'package:flutter/material.dart';

// Modelo de tipo de promoción
class PromoType {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String? imagePath; // asset path opcional

  const PromoType({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.imagePath,
  });
}

class AddPromotion1Screen extends StatefulWidget {
  const AddPromotion1Screen({super.key});

  @override
  State<AddPromotion1Screen> createState() => _AddPromotion1ScreenState();
}

class _AddPromotion1ScreenState extends State<AddPromotion1Screen> {
  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);
  static const Color _lightBg = Color(0xFFF5F6FA);

  String _selectedId = 'descuento'; // seleccionado por defecto

  final List<PromoType> _promoTypes = const [
    PromoType(
      id: 'descuento',
      title: 'Descuento %',
      subtitle: 'Precio reducido con porcentaje visible',
      icon: Icons.percent_rounded,
      iconColor: Color(0xFFFF4D2E),
    ),
    PromoType(
      id: 'combo',
      title: '2×1 / Combos',
      subtitle: 'Lleva 2 y paga 1 o paquetes especiales',
      icon: Icons.layers_rounded,
      iconColor: Color(0xFFFF9800),
    ),
    PromoType(
      id: 'envio',
      title: 'Envío Gratis',
      subtitle: 'Sin costo de domicilio o entrega',
      icon: Icons.local_shipping_outlined,
      iconColor: Color(0xFF4CAF50),
    ),
    PromoType(
      id: 'especial',
      title: 'Precio Especial',
      subtitle: 'Precio único para un grupo o momento',
      icon: Icons.auto_awesome_rounded,
      iconColor: Color(0xFF9C27B0),
    ),
    PromoType(
      id: 'liquidacion',
      title: 'Liquidación',
      subtitle: 'Stock limitado a precio de quema',
      icon: Icons.local_fire_department_rounded,
      iconColor: Color(0xFFF44336),
    ),
  ];

  // Steps del wizard
  final List<_WizardStep> _steps = const [
    _WizardStep(icon: Icons.percent_rounded, label: 'Tipo'),
    _WizardStep(icon: Icons.inventory_2_outlined, label: 'Producto'),
    _WizardStep(icon: Icons.attach_money_rounded, label: 'Precio'),
    _WizardStep(icon: Icons.store_outlined, label: 'Tienda'),
    _WizardStep(icon: Icons.send_outlined, label: 'Publicar'),
  ];

  void _onNext() {
    // Navegar al paso 2 pasando el tipo seleccionado
    // Navigator.push(context, MaterialPageRoute(builder: (_) => AddPromotion2Screen(promoType: _selectedId)));
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
                  const Text(
                    '¿Qué tipo de promo\nvas a publicar?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F2E),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Elige el formato que mejor describe tu oferta',
                    style: TextStyle(fontSize: 13.5, color: Color(0xFF8A8FA8)),
                  ),
                  const SizedBox(height: 24),
                  ..._promoTypes.map((type) => _buildPromoCard(type)).toList(),
                  const SizedBox(height: 100), // espacio para el bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── Top bar con título + stepper ────────────────────────────────────────────

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
          // Título + badge
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
          // Stepper horizontal
          _buildStepper(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_steps.length, (i) {
        final isActive = i == 0;
        final isPast = i < 0; // ninguno pasado aún
        return _buildStep(
          step: _steps[i],
          isActive: isActive,
          isPast: isPast,
          isLast: i == _steps.length - 1,
        );
      }),
    );
  }

  Widget _buildStep({
    required _WizardStep step,
    required bool isActive,
    required bool isPast,
    required bool isLast,
  }) {
    final Color bgColor = isActive
        ? _primary
        : isPast
        ? _primary.withOpacity(0.2)
        : const Color(0xFFF0F1F5);
    final Color iconColor = isActive
        ? Colors.white
        : isPast
        ? _primary
        : const Color(0xFFB0B5CC);
    final Color labelColor = isActive
        ? _primary
        : isPast
        ? _primary
        : const Color(0xFFB0B5CC);

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
                    border: isActive
                        ? Border.all(color: _primary, width: 2)
                        : null,
                  ),
                  child: Icon(step.icon, color: iconColor, size: 18),
                ),
                const SizedBox(height: 5),
                Text(
                  step.label,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: labelColor,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!isLast)
            Container(
              width: 16,
              height: 1.5,
              color: const Color(0xFFE0E2EA),
              margin: const EdgeInsets.only(bottom: 16),
            ),
        ],
      ),
    );
  }

  // ── Tarjeta de tipo de promo ─────────────────────────────────────────────────

  Widget _buildPromoCard(PromoType type) {
    final isSelected = _selectedId == type.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedId = type.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _primary.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Imagen placeholder / color block
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: Container(
                width: 80,
                height: 76,
                color: type.iconColor.withOpacity(0.12),
                child: Icon(type.icon, color: type.iconColor, size: 32),
              ),
            ),
            const SizedBox(width: 14),
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(type.icon, color: type.iconColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        type.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1F2E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF8A8FA8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            // Indicador selección
            Container(
              margin: const EdgeInsets.only(right: 14),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _primary : const Color(0xFFCDD0DB),
                  width: 2,
                ),
                color: isSelected ? _primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
          ],
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
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkBg,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Siguiente',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Paso 1 de 5 — 20% completado',
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

  const _WizardStep({required this.icon, required this.label});
}
