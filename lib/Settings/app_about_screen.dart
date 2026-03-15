import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA ACERCA DE PROMOMANIA
// ─────────────────────────────────────────────────────────────────────────────

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {
  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);
  static const Color _blue = Color(0xFF3B82F6);
  static const Color _green = Color(0xFF10B981);
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _purple = Color(0xFF8B5CF6);
  static const Color _pink = Color(0xFFEC4899);

  late final AnimationController _mapCtrl;
  late final List<Animation<double>> _pinAnims;

  // Pins del mapa simulado
  final List<_MapPin> _pins = const [
    _MapPin(label: '30%', color: Color(0xFFFF4D2E), left: 0.12, top: 0.08),
    _MapPin(label: '50%', color: Color(0xFF10B981), left: 0.24, top: 0.38),
    _MapPin(label: '3×2', color: Color(0xFFEC4899), left: 0.50, top: 0.12),
    _MapPin(label: '2×1', color: Color(0xFF8B5CF6), left: 0.74, top: 0.06),
    _MapPin(label: '15%', color: Color(0xFFF59E0B), left: 0.80, top: 0.32),
  ];

  @override
  void initState() {
    super.initState();
    _mapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pinAnims = List.generate(_pins.length, (i) {
      final start = i * 0.15;
      return CurvedAnimation(
        parent: _mapCtrl,
        curve: Interval(
          start,
          (start + 0.4).clamp(0, 1),
          curve: Curves.elasticOut,
        ),
      );
    });

    _mapCtrl.forward();
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 12),
              _buildBackButton(),
              const SizedBox(height: 8),
              _buildHeroSection(),
              const SizedBox(height: 28),
              _buildStatsRow(),
              const SizedBox(height: 32),
              _buildMissionSection(),
              const SizedBox(height: 32),
              _buildWhyUsSection(),
              const SizedBox(height: 32),
              _buildTeamSection(),
              const SizedBox(height: 32),
              _buildCtaCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Back button ───────────────────────────────────────────────────────────────

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF1A1F2E),
            size: 20,
          ),
        ),
      ),
    );
  }

  // ── Hero con mapa animado ─────────────────────────────────────────────────────

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Mapa con pins animados
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFD0DCF8), width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: Stack(
              children: [
                // Grid del mapa
                CustomPaint(
                  size: const Size(double.infinity, 180),
                  painter: _GridPainter(),
                ),
                // Líneas de calle simuladas
                CustomPaint(
                  size: const Size(double.infinity, 180),
                  painter: _StreetPainter(),
                ),
                // Pins animados
                ..._pins.asMap().entries.map((e) {
                  final i = e.key;
                  final p = e.value;
                  return AnimatedBuilder(
                    animation: _pinAnims[i],
                    builder: (_, __) {
                      final v = _pinAnims[i].value;
                      return Positioned(
                        left: MediaQuery.of(context).size.width * p.left - 30,
                        top: 180 * p.top - 20,
                        child: Transform.scale(
                          scale: v,
                          child: _PinWidget(label: p.label, color: p.color),
                        ),
                      );
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Logo + nombre
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_offer_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Promomania',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1F2E),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Descubre promociones cerca de ti en tiempo real',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF8A8FA8)),
        ),
      ],
    );
  }

  // ── Stats ─────────────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('150K+', 'Usuarios', _primary),
          _statDivider(),
          _statItem('2.5K+', 'Negocios', _blue),
          _statDivider(),
          _statItem('25', 'Ciudades', _green),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8A8FA8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _statDivider() =>
      Container(width: 1, height: 36, color: const Color(0xFFF0F1F5));

  // ── Nuestra misión ────────────────────────────────────────────────────────────

  Widget _buildMissionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Nuestra misión',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1F2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Revolucionar el descubrimiento de promociones en Colombia mediante geolocalización inteligente, conectando negocios locales con consumidores de manera eficiente y transparente.',
              style: TextStyle(
                fontSize: 14.5,
                color: Color(0xFF4A5168),
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Por qué elegirnos ─────────────────────────────────────────────────────────

  Widget _buildWhyUsSection() {
    final reasons = [
      _Reason(
        icon: Icons.bolt_rounded,
        iconColor: _primary,
        iconBg: _primary.withOpacity(0.1),
        title: 'Tiempo real',
        subtitle:
            'Descubre promociones actualizadas al instante según tu ubicación',
      ),
      _Reason(
        icon: Icons.verified_outlined,
        iconColor: _green,
        iconBg: _green.withOpacity(0.1),
        title: '100% verificadas',
        subtitle:
            'Cada promoción es validada por nuestro equipo antes de publicarse',
      ),
      _Reason(
        icon: Icons.people_outline_rounded,
        iconColor: _blue,
        iconBg: _blue.withOpacity(0.1),
        title: 'Comunidad local',
        subtitle:
            'Apoyamos negocios locales y fortalecemos economías regionales',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Por qué elegirnos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1F2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...reasons.map((r) => _buildReasonRow(r)).toList(),
        ],
      ),
    );
  }

  Widget _buildReasonRow(_Reason r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: r.iconBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(r.icon, color: r.iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1F2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  r.subtitle,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF8A8FA8),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Equipo ────────────────────────────────────────────────────────────────────

  Widget _buildTeamSection() {
    final members = [
      _TeamMember(
        initials: 'AC',
        name: 'Ana C.',
        role: 'CEO & Fundadora',
        color: _primary,
      ),
      _TeamMember(initials: 'JP', name: 'Juan P.', role: 'CTO', color: _blue),
      _TeamMember(
        initials: 'MR',
        name: 'María R.',
        role: 'Diseño UX',
        color: _purple,
      ),
      _TeamMember(
        initials: 'LG',
        name: 'Luis G.',
        role: 'Marketing',
        color: _green,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Nuestro equipo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1F2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: members.map((m) => _buildMemberCard(m)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(_TeamMember m) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: m.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: m.color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              m.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          m.name,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F2E),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          m.role,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10.5, color: Color(0xFF8A8FA8)),
        ),
      ],
    );
  }

  // ── CTA Card ──────────────────────────────────────────────────────────────────

  Widget _buildCtaCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE8EAF0), width: 1.2),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                color: _primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '¿Tienes preguntas?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1F2E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Estamos aquí para ayudarte',
              style: TextStyle(fontSize: 13.5, color: Color(0xFF8A8FA8)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _HelpCenterPlaceholder(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Ir a centro de ayuda',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAINTERS
// ─────────────────────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0DCF8).withOpacity(0.5)
      ..strokeWidth = 0.8;
    const spacing = 22.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter o) => false;
}

class _StreetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = const Color(0xFFC8D8F8)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.45),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.4, 0),
      Offset(size.width * 0.4, size.height),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, 0),
      Offset(size.width * 0.72, size.height),
      road,
    );

    final road2 = Paint()
      ..color = const Color(0xFFD8E8F8)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, size.height * 0.22),
      Offset(size.width, size.height * 0.22),
      road2,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.72),
      Offset(size.width, size.height * 0.72),
      road2,
    );
  }

  @override
  bool shouldRepaint(_StreetPainter o) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// PIN WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _PinWidget extends StatelessWidget {
  final String label;
  final Color color;

  const _PinWidget({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(10, 6),
          painter: _PinTipPainter(color: color),
        ),
      ],
    );
  }
}

class _PinTipPainter extends CustomPainter {
  final Color color;
  const _PinTipPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PinTipPainter o) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS
// ─────────────────────────────────────────────────────────────────────────────

class _MapPin {
  final String label;
  final Color color;
  final double left;
  final double top;
  const _MapPin({
    required this.label,
    required this.color,
    required this.left,
    required this.top,
  });
}

class _Reason {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  const _Reason({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });
}

class _TeamMember {
  final String initials;
  final String name;
  final String role;
  final Color color;
  const _TeamMember({
    required this.initials,
    required this.name,
    required this.role,
    required this.color,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PLACEHOLDER para navegar al help center
// ─────────────────────────────────────────────────────────────────────────────

class _HelpCenterPlaceholder extends StatelessWidget {
  const _HelpCenterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Centro de ayuda')),
      body: const Center(child: Text('HelpCenterScreen aquí')),
    );
  }
}
