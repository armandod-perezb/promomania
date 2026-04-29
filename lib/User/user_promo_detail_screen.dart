import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../models/promocion.dart';
import '../models/promocion_horario.dart';
import '../models/reporte.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS
// ─────────────────────────────────────────────────────────────────────────────

class _Review {
  final String name;
  final String initials;
  final Color avatarColor;
  final double rating;
  final String time;
  final String comment;
  final int useful;

  const _Review({
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.rating,
    required this.time,
    required this.comment,
    required this.useful,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA DE DETALLE
// ─────────────────────────────────────────────────────────────────────────────

class PromoDetailScreen extends StatefulWidget {
  const PromoDetailScreen({super.key});

  @override
  State<PromoDetailScreen> createState() => _PromoDetailScreenState();
}

class _PromoDetailScreenState extends State<PromoDetailScreen>
    with TickerProviderStateMixin {
  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);
  static const Color _green = Color(0xFF10B981);
  static const Color _lightBg = Color(0xFFF5F6FA);
  static const String _heroImageUrl =
      'https://images.unsplash.com/photo-1496747611176-843222e1e57c';
  static const String _storeImageUrl =
      'https://images.unsplash.com/photo-1494438639946-1ebd1d20bf85';

  Promocion? _promo;
  List<PromocionHorario> _horarios = [];
  bool _routeDataResolved = false;

  bool _isFavorite = false;
  bool _descExpanded = false;

  // Countdown: termina 8 mar 2026 → días, horas, minutos, segundos
  int _days = 0, _hours = 23, _minutes = 57, _seconds = 6;
  Timer? _timer;

  // Rating bars data [1★..5★]
  final List<int> _ratingCounts = [2, 3, 9, 21, 32]; // index 0=1★

  final List<_Review> _reviews = const [
    _Review(
      name: 'Paula Jiménez',
      initials: 'PJ',
      avatarColor: Color(0xFF8B5CF6),
      rating: 5,
      time: 'Hace 3 días',
      comment:
          'Las prendas de lino son hermosas. Calidad real, no parecen de oferta para nada. El descuento es un regalo.',
      useful: 22,
    ),
    _Review(
      name: 'Mariana Ospina',
      initials: 'MO',
      avatarColor: Color(0xFFEC4899),
      rating: 4,
      time: 'Hace 6 días',
      comment:
          'Buen diseño, buena calidad. Pedí en línea con el código y funcionó perfecto. Llegó en 2 días.',
      useful: 14,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else if (_minutes > 0) {
          _minutes--;
          _seconds = 59;
        } else if (_hours > 0) {
          _hours--;
          _minutes = 59;
          _seconds = 59;
        } else if (_days > 0) {
          _days--;
          _hours = 23;
          _minutes = 59;
          _seconds = 59;
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeDataResolved) return;
    _routeDataResolved = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    final codigo = args is String ? args : null;

    final promoByCode = codigo != null
        ? promoService.getPromocionByCodigo(codigo)
        : null;
    final fallbackPromo = promoService.getPromocionesAprobadas().isNotEmpty
        ? promoService.getPromocionesAprobadas().first
        : (promoService.getPromociones().isNotEmpty
              ? promoService.getPromociones().first
              : null);

    _promo = promoByCode ?? fallbackPromo;
    if (_promo != null) {
      _horarios = promoService.getPromocionesHorariosByCodigo(_promo!.codigo);
      _isFavorite = promoService.isFavorito(_activeUserId, _promo!.codigo);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _totalReviews => _ratingCounts.fold(0, (a, b) => a + b);
  int get _activeUserId => sessionManager.usuarioActual?.id ?? 1;
  int get _nextReporteId =>
      (promoService.getReportes().isNotEmpty
          ? promoService.getReportes().last.id
          : 0) +
      1;

  String _horarioTexto() {
    if (_horarios.isEmpty) return 'Horario no especificado';
    return _horarios
        .map((h) => '${h.diaSemana}: ${h.horaInicio} - ${h.horaFin}')
        .join(' · ');
  }

  Future<void> _reportarPromocion() async {
    if (_promo == null) return;

    promoService.addReporte(
      Reporte(
        id: _nextReporteId,
        motivo: 'Reporte enviado desde detalle de promoción',
        fecha: DateTime.now().toIso8601String(),
        estado: 'pendiente',
        idUsuario: _activeUserId,
        codigoPromocion: _promo!.codigo,
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte enviado. Será revisado por el admin.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: promoService,
      builder: (context, _) {
        if (_promo == null) {
          return const Scaffold(
            body: Center(child: Text('No se encontró información de la promoción')),
          );
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: _lightBg,
            body: Stack(
              children: [
                // Contenido scrollable
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroImage(),
                      _buildMainInfo(),
                      _buildDivider(),
                      _buildCountdown(),
                      _buildDivider(),
                      _buildStats(),
                      _buildDivider(),
                      _buildDescription(),
                      _buildDivider(),
                      _buildStoreSection(),
                      _buildDivider(),
                      _buildLocationSection(),
                      _buildDivider(),
                      _buildReviewsSection(),
                      _buildViewAllReviews(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                // Bottom bar fijo
                _buildBottomBar(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Hero image ──────────────────────────────────────────────────────────────

  Widget _buildHeroImage() {
    final promoImage = (_promo?.foto != null && _promo!.foto!.isNotEmpty)
        ? _promo!.foto!
        : _heroImageUrl;

    return SizedBox(
      height: 290,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            promoImage,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.24),
                  Colors.black.withValues(alpha: 0.10),
                  Colors.black.withValues(alpha: 0.52),
                ],
              ),
            ),
          ),
          // Botones overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back
                _heroBtn(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    _heroBtn(icon: Icons.share_outlined, onTap: () {}),
                    const SizedBox(width: 10),
                    _heroBtn(
                      icon: _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: _isFavorite ? _primary : Colors.white,
                      onTap: () {
                        promoService.toggleFavorito(_activeUserId, _promo!.codigo);
                        setState(
                          () => _isFavorite = promoService.isFavorito(
                            _activeUserId,
                            _promo!.codigo,
                          ),
                        );
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Badge Moda
          Positioned(
            bottom: 14,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Moda',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroBtn({
    required IconData icon,
    Color iconColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  // ── Info principal ──────────────────────────────────────────────────────────

  Widget _buildMainInfo() {
    final promo = _promo!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(
            children: const [
              Text(
                'Moda',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              SizedBox(width: 8),
              Text('•', style: TextStyle(color: Color(0xFFD1D5DB))),
              SizedBox(width: 8),
              Icon(Icons.check_circle, size: 13, color: Color(0xFF3B82F6)),
              SizedBox(width: 4),
              Text(
                'Moda · Ropa casual',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Título
          Text(
            promo.titulo,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              height: 1.18,
            ),
          ),
          const SizedBox(height: 14),
          // Rating + distancia + tiempo
          Row(
            children: [
              // Estrellas
              Row(
                children: List.generate(5, (i) {
                  if (i < 4) {
                    return const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFBBF24),
                      size: 16,
                    );
                  }
                  return const Icon(
                    Icons.star_half_rounded,
                    color: Color(0xFFFBBF24),
                    size: 16,
                  );
                }),
              ),
              const SizedBox(width: 6),
              const Text(
                '4.4',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const Text(
                ' (67 reseñas)',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF8A8FA8)),
              ),
              const SizedBox(width: 8),
              const Text('•', style: TextStyle(color: Color(0xFFB0B5CC))),
              const SizedBox(width: 8),
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: Color(0xFFB0B5CC),
              ),
              const SizedBox(width: 2),
              const Text(
                '0.9 km',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF8A8FA8)),
              ),
              const SizedBox(width: 8),
              const Text('•', style: TextStyle(color: Color(0xFFB0B5CC))),
              const SizedBox(width: 8),
              const Icon(
                Icons.access_time_rounded,
                size: 13,
                color: Color(0xFFB0B5CC),
              ),
              const SizedBox(width: 2),
              const Text(
                '4 días',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF8A8FA8)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Precio
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${promo.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: _primary,
                          ),
                        ),
                        if ((promo.descuento ?? 0) > 0) ...[
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${promo.descuento}% OFF',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFB0B5CC),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'COP · Precio con descuento',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8A8FA8)),
                    ),
                  ],
                ),
              ),
              // Badge de ahorro
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _green.withValues(alpha: 0.18),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.shopping_bag_outlined, color: _green, size: 18),
                    SizedBox(height: 5),
                    Text(
                      'Ahorras',
                      style: TextStyle(
                        fontSize: 11,
                        color: _green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$52.500 COP',
                      style: TextStyle(
                        fontSize: 12,
                        color: _green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Countdown ───────────────────────────────────────────────────────────────

  Widget _buildCountdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _darkBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'Termina: 8 mar 2026',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _countdownUnit(_days.toString().padLeft(2, '0'), 'D'),
          _countdownSep(),
          _countdownUnit(_hours.toString().padLeft(2, '0'), 'H'),
          _countdownSep(),
          _countdownUnit(_minutes.toString().padLeft(2, '0'), 'M'),
          _countdownSep(),
          _countdownUnit(_seconds.toString().padLeft(2, '0'), 'S'),
        ],
      ),
    );
  }

  Widget _countdownUnit(String val, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _countdownSep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ── Stats ───────────────────────────────────────────────────────────────────

  Widget _buildStats() {
    final promo = _promo!;
    final reportesCount = promoService.getReportesByPromocion(promo.codigo).length;
    final favoritosCount = promoService.favoritos
        .where((f) => f.codigoPromocion == promo.codigo)
        .length;

    final stats = [
      _Stat(
        icon: Icons.visibility_outlined,
        value: '${promo.vistas}',
        label: 'Vistas',
      ),
      _Stat(icon: Icons.thumb_up_outlined, value: '267', label: 'Útil'),
      _Stat(
        icon: Icons.favorite_border_rounded,
        value: '$favoritosCount',
        label: 'Guardados',
      ),
      _Stat(icon: Icons.report_outlined, value: '$reportesCount', label: 'Reportes'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF0F1F5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(s.icon, color: const Color(0xFF9CA3AF), size: 20),
                  const SizedBox(height: 8),
                  Text(
                    s.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s.label,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF8A8FA8),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Descripción ─────────────────────────────────────────────────────────────

  Widget _buildDescription() {
    final fullText =
      _promo?.descripcion?.trim().isNotEmpty == true
      ? _promo!.descripcion!.trim()
      : 'Esta promoción no tiene descripción ampliada.';
    const preview = 150;

    final tags = [
      '#Moda',
      '#Primavera 2026',
      '#Lino',
      '#Algodón orgánico',
      '#35% OFF',
      '#Colección nueva',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sobre esta promo',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1F2E),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _descExpanded || fullText.length <= preview
                ? fullText
                : '${fullText.substring(0, preview)}...',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5A5F72),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => setState(() => _descExpanded = !_descExpanded),
            child: Row(
              children: [
                Text(
                  _descExpanded ? 'Ver menos' : 'Ver más',
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  _descExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: _primary,
                  size: 18,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((t) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
                ),
                child: Text(
                  t,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5A5F72),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          // Útil / No útil
          Row(
            children: [
              _utilBtn(Icons.thumb_up_outlined, '¿Fue útil?'),
              const SizedBox(width: 10),
              _utilBtn(Icons.thumb_down_outlined, null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _utilBtn(IconData icon, String? label) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8EAF0), width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF5A5F72)),
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF5A5F72),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Tienda ──────────────────────────────────────────────────────────────────

  Widget _buildStoreSection() {
    final promo = _promo!;
    final supermercado = promoService.getSupermercado(promo.idSupermercado);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'La tienda',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1F2E),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Logo tienda
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        _storeImageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: _green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            supermercado?.nombre ?? 'Tienda no disponible',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1F2E),
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF3B82F6),
                            size: 15,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${supermercado?.ciudad ?? 'Ciudad no disponible'} · Promoción',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF8A8FA8),
                        ),
                      ),
                      const SizedBox(height: 7),
                      FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < 4
                                      ? Icons.star_rounded
                                      : Icons.star_half_rounded,
                                  color: const Color(0xFFFBBF24),
                                  size: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '4.4',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1F2E),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '(380)',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF8A8FA8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón Ver
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ver',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(width: 1),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 17,
                        color: Color(0xFF8A8FA8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Ubicación ───────────────────────────────────────────────────────────────

  Widget _buildLocationSection() {
    final promo = _promo!;
    final supermercado = promoService.getSupermercado(promo.idSupermercado);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info rows
          _locationRow(
            icon: Icons.location_on_outlined,
            mainText:
                supermercado?.direccion ??
                promo.ubicacion ??
                'Ubicación no especificada',
            subText: supermercado?.ciudad,
          ),
          const SizedBox(height: 10),
          _locationRow(
            icon: Icons.access_time_rounded,
            mainText: _horarioTexto(),
          ),
          const SizedBox(height: 10),
          _locationRow(
            icon: Icons.phone_outlined,
            mainText: '+57 (601) 789-0123',
          ),
          const SizedBox(height: 14),
          // Mapa placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 130,
              width: double.infinity,
              color: const Color(0xFFE8F0FE),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Grid lines
                  CustomPaint(
                    size: const Size(double.infinity, 130),
                    painter: _GridPainter(),
                  ),
                  // Pin
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Cómo llegar
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.near_me_outlined, color: _primary, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Cómo llegar — 0.9 km',
                    style: TextStyle(
                      color: _primary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.open_in_new_rounded, color: _primary, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationRow({
    required IconData icon,
    required String mainText,
    String? subText,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF8A8FA8), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mainText,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF1A1F2E),
                    height: 1.4,
                  ),
                ),
                if (subText != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A8FA8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Reseñas ─────────────────────────────────────────────────────────────────

  Widget _buildReviewsSection() {
    final total = _totalReviews;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reseñas',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1F2E),
                ),
              ),
              Text(
                '67 reseñas',
                style: const TextStyle(fontSize: 13, color: Color(0xFF8A8FA8)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Rating summary
          Row(
            children: [
              // Score grande
              Column(
                children: [
                  const Text(
                    '4.4',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1F2E),
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                        color: const Color(0xFFFBBF24),
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'de 5',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8A8FA8)),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // Barras
              Expanded(
                child: Column(
                  children: List.generate(5, (i) {
                    final star = 5 - i; // 5, 4, 3, 2, 1
                    final count = _ratingCounts[star - 1];
                    final pct = total > 0 ? count / total : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          Text(
                            '$star',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8A8FA8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFBBF24),
                            size: 11,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 6,
                                backgroundColor: const Color(0xFFE8EAF0),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFBBF24),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 20,
                            child: Text(
                              '$count',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8A8FA8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Lista de reseñas
          ..._reviews.map((r) => _buildReviewCard(r)).toList(),
        ],
      ),
    );
  }

  Widget _buildReviewCard(_Review r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: r.avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    r.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1F2E),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < r.rating.toInt()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFFBBF24),
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 64,
                child: Text(
                  r.time,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF8A8FA8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            r.comment,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF5A5F72),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.thumb_up_outlined,
                    size: 14,
                    color: Color(0xFF5A5F72),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Útil (${r.useful})',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF5A5F72),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF0F1F5), thickness: 1),
        ],
      ),
    );
  }

  Widget _buildViewAllReviews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8EAF0), width: 1.5),
          ),
          child: const Center(
            child: Text(
              'Ver todas las reseñas (67)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1F2E),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom bar ──────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Favorito
            GestureDetector(
              onTap: () {
                promoService.toggleFavorito(_activeUserId, _promo!.codigo);
                setState(
                  () => _isFavorite = promoService.isFavorito(
                    _activeUserId,
                    _promo!.codigo,
                  ),
                );
                HapticFeedback.lightImpact();
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _isFavorite
                      ? _primary.withOpacity(0.1)
                      : const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isFavorite
                        ? _primary.withOpacity(0.3)
                        : const Color(0xFFE8EAF0),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  _isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _isFavorite ? _primary : const Color(0xFF8A8FA8),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Activar Promoción
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bolt_rounded, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Activar Promoción',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Mapa
            _bottomIconBtn(icon: Icons.near_me_outlined, onTap: () {}),
            const SizedBox(width: 8),
            // Alerta
            _bottomIconBtn(
              icon: Icons.warning_amber_rounded,
              onTap: _reportarPromocion,
              color: const Color(0xFFF5F6FA),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomIconBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color color = const Color(0xFF1A1F2E),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: color == const Color(0xFF1A1F2E)
              ? Colors.white
              : const Color(0xFF5A5F72),
          size: 22,
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Widget _buildDivider() =>
      const Divider(color: Color(0xFFF0F1F5), thickness: 6, height: 6);
}

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS AUXILIARES
// ─────────────────────────────────────────────────────────────────────────────

class _Stat {
  final IconData icon;
  final String value;
  final String label;
  const _Stat({required this.icon, required this.value, required this.label});
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0DCF8)
      ..strokeWidth = 0.8;
    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
