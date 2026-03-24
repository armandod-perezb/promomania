import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Core/Routes/app_routes.dart';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen>
    with TickerProviderStateMixin {
  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);

  int _selectedTab = 0;
  double _zoomLevel = 100;
  int _selectedPromo = 0;

  late final AnimationController _cardController;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;

  // Promos de ejemplo en el mapa
  final List<_MapPromo> _promos = const [
    _MapPromo(
      id: 0,
      label: '-50%',
      color: Color(0xFFE91E8C),
      left: 0.55,
      top: 0.22,
    ),
    _MapPromo(
      id: 1,
      label: '50%',
      color: Color(0xFFFF4D2E),
      left: 0.42,
      top: 0.32,
    ),
    _MapPromo(
      id: 2,
      label: '-40%',
      color: Color(0xFF3B82F6),
      left: 0.63,
      top: 0.52,
    ),
    _MapPromo(
      id: 3,
      label: '-33%',
      color: Color(0xFF10B981),
      left: 0.26,
      top: 0.57,
    ),
    _MapPromo(
      id: 4,
      label: '-33%',
      color: Color(0xFF10B981),
      left: 0.75,
      top: 0.66,
    ),
  ];

  // Detalle de cada promo
  final List<_PromoDetail> _promoDetails = const [
    _PromoDetail(
      category: 'Comida',
      categoryColor: Color(0xFFFF4D2E),
      discount: '-50%',
      title: '2x1 en Hamburguesa',
      store: 'Burger House',
      emoji: '🍔',
    ),
    _PromoDetail(
      category: 'Moda',
      categoryColor: Color(0xFFE91E8C),
      discount: '50%',
      title: 'Descuento en ropa',
      store: 'Fashion Store',
      emoji: '👕',
    ),
    _PromoDetail(
      category: 'Tech',
      categoryColor: Color(0xFF3B82F6),
      discount: '-40%',
      title: 'Accesorios Apple',
      store: 'iZone Store',
      emoji: '📱',
    ),
    _PromoDetail(
      category: 'Salud',
      categoryColor: Color(0xFF10B981),
      discount: '-33%',
      title: 'Vitaminas y suplementos',
      store: 'VitaShop',
      emoji: '💊',
    ),
    _PromoDetail(
      category: 'Salud',
      categoryColor: Color(0xFF10B981),
      discount: '-33%',
      title: 'Consulta médica',
      store: 'Clínica Norte',
      emoji: '🏥',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
        );
    _cardFade = CurvedAnimation(parent: _cardController, curve: Curves.easeOut);
    _cardController.forward();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  void _selectPromo(int id) {
    setState(() => _selectedPromo = id);
    _cardController.forward(from: 0);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // ── Mapa simulado ──
            _buildFakeMap(),

            // ── Pins de promos ──
            ..._buildPromoMarkers(),

            // ── Pin de usuario ──
            _buildUserPin(),

            // ── Barra de búsqueda ──
            _buildSearchBar(),

            // ── Badge de zoom ──
            _buildZoomBadge(),

            // ── Controles de mapa ──
            _buildMapControls(),

            // ── Bottom sheet con promo activa ──
            _buildBottomPromoSheet(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ── Mapa ─────────────────────────────────────────────────────────────────────

  Widget _buildFakeMap() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          // Fondo simulando vista aérea
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB8CBB8), Color(0xFF9DB89D), Color(0xFF8BAD8B)],
          ),
        ),
        child: CustomPaint(painter: _MapPainter()),
      ),
    );
  }

  List<Widget> _buildPromoMarkers() {
    return _promos.map((p) {
      final isSelected = _selectedPromo == p.id;
      return Positioned(
        left: MediaQuery.of(context).size.width * p.left,
        top: MediaQuery.of(context).size.height * p.top,
        child: GestureDetector(
          onTap: () => _selectPromo(p.id),
          child: AnimatedScale(
            scale: isSelected ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: _PromoMarker(
              label: p.label,
              color: p.color,
              isSelected: isSelected,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildUserPin() {
    final size = MediaQuery.of(context).size;
    return Positioned(
      left: size.width * 0.48,
      top: size.height * 0.48,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  // ── Barra de búsqueda ─────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // Campo de búsqueda
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.search_rounded,
                    color: Color(0xFFB0B5CC),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Buscar promociones cerca...',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Botón de filtros
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.layers_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ── Zoom badge ───────────────────────────────────────────────────────────────

  Widget _buildZoomBadge() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 72,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'Zoom: ${_zoomLevel.toInt()}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1F2E),
          ),
        ),
      ),
    );
  }

  // ── Controles de mapa ─────────────────────────────────────────────────────────

  Widget _buildMapControls() {
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).padding.top + 72,
      child: Column(
        children: [
          _mapControlBtn(
            icon: Icons.near_me_outlined,
            onTap: () => HapticFeedback.lightImpact(),
          ),
          const SizedBox(height: 8),
          _mapControlBtn(
            icon: Icons.add_rounded,
            onTap: () =>
                setState(() => _zoomLevel = (_zoomLevel + 10).clamp(50, 200)),
          ),
          const SizedBox(height: 8),
          _mapControlBtn(
            icon: Icons.remove_rounded,
            onTap: () =>
                setState(() => _zoomLevel = (_zoomLevel - 10).clamp(50, 200)),
          ),
        ],
      ),
    );
  }

  Widget _mapControlBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1A1F2E), size: 20),
      ),
    );
  }

  // ── Bottom promo sheet ────────────────────────────────────────────────────────

  Widget _buildBottomPromoSheet() {
    final promo = _promoDetails[_selectedPromo];
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _cardSlide,
        child: FadeTransition(
          opacity: _cardFade,
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Emoji / imagen
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: promo.categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        promo.emoji,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _categoryBadge(promo.category, promo.categoryColor),
                            const SizedBox(width: 8),
                            _discountBadge(promo.discount),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          promo.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1F2E),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFFB0B5CC),
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              promo.store,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF8A8FA8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // FAB - Agregar Promoción
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.addPromotions),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _categoryBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _discountBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    final tabs = [
      _NavTab(icon: Icons.map_rounded, label: 'Inicio'),
      _NavTab(icon: Icons.explore_outlined, label: 'Explorar'),
      _NavTab(icon: Icons.favorite_border_rounded, label: 'Favoritos'),
      _NavTab(icon: Icons.person_outline_rounded, label: 'Perfil'),
    ];
    final routesByTab = [
      AppRoutes.userHome,
      AppRoutes.explore,
      AppRoutes.userFavorites,
      AppRoutes.userProfile,
    ];

    return Container(
      height: 68 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (i) {
          final isActive = _selectedTab == i;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();

              if (_selectedTab != i) {
                setState(() => _selectedTab = i);
              }

              final route = routesByTab[i];
              final currentRoute = ModalRoute.of(context)?.settings.name;

              if (route != currentRoute) {
                Navigator.pushNamed(context, route);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 72,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? _primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      tabs[i].icon,
                      color: isActive ? _primary : const Color(0xFFB0B5CC),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tabs[i].label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? _primary : const Color(0xFFB0B5CC),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Custom Painter para simular mapa ─────────────────────────────────────────

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final buildingPaint = Paint()..color = const Color(0xFFD4DED4);
    final roadPaint = Paint()
      ..color = const Color(0xFFC8D8C8)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    final roadPaint2 = Paint()
      ..color = const Color(0xFFC8D8C8)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // Calles principales
    canvas.drawLine(
      Offset(0, size.height * 0.35),
      Offset(size.width, size.height * 0.35),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.65),
      Offset(size.width, size.height * 0.65),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, 0),
      Offset(size.width * 0.35, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, 0),
      Offset(size.width * 0.65, size.height),
      roadPaint,
    );

    // Calles secundarias
    for (int i = 1; i <= 4; i++) {
      canvas.drawLine(
        Offset(0, size.height * (i * 0.18)),
        Offset(size.width, size.height * (i * 0.18)),
        roadPaint2,
      );
      canvas.drawLine(
        Offset(size.width * (i * 0.22), 0),
        Offset(size.width * (i * 0.22), size.height),
        roadPaint2,
      );
    }

    // Edificios / bloques
    final buildings = [
      Rect.fromLTWH(
        size.width * 0.05,
        size.height * 0.08,
        size.width * 0.28,
        size.height * 0.24,
      ),
      Rect.fromLTWH(
        size.width * 0.38,
        size.height * 0.06,
        size.width * 0.24,
        size.height * 0.26,
      ),
      Rect.fromLTWH(
        size.width * 0.68,
        size.height * 0.10,
        size.width * 0.28,
        size.height * 0.22,
      ),
      Rect.fromLTWH(
        size.width * 0.04,
        size.height * 0.38,
        size.width * 0.28,
        size.height * 0.24,
      ),
      Rect.fromLTWH(
        size.width * 0.38,
        size.height * 0.40,
        size.width * 0.24,
        size.height * 0.22,
      ),
      Rect.fromLTWH(
        size.width * 0.68,
        size.height * 0.38,
        size.width * 0.28,
        size.height * 0.24,
      ),
      Rect.fromLTWH(
        size.width * 0.05,
        size.height * 0.68,
        size.width * 0.26,
        size.height * 0.28,
      ),
      Rect.fromLTWH(
        size.width * 0.35,
        size.height * 0.70,
        size.width * 0.26,
        size.height * 0.26,
      ),
      Rect.fromLTWH(
        size.width * 0.66,
        size.height * 0.68,
        size.width * 0.30,
        size.height * 0.28,
      ),
    ];

    for (final rect in buildings) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        buildingPaint,
      );
    }

    // Zona verde
    final greenPaint = Paint()..color = const Color(0xFF9DC59D);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.38,
          size.height * 0.38,
          size.width * 0.24,
          size.height * 0.22,
        ),
        const Radius.circular(4),
      ),
      greenPaint,
    );
  }

  @override
  bool shouldRepaint(_MapPainter old) => false;
}

// ── Modelos auxiliares ────────────────────────────────────────────────────────

class _MapPromo {
  final int id;
  final String label;
  final Color color;
  final double left;
  final double top;

  const _MapPromo({
    required this.id,
    required this.label,
    required this.color,
    required this.left,
    required this.top,
  });
}

class _PromoDetail {
  final String category;
  final Color categoryColor;
  final String discount;
  final String title;
  final String store;
  final String emoji;

  const _PromoDetail({
    required this.category,
    required this.categoryColor,
    required this.discount,
    required this.title,
    required this.store,
    required this.emoji,
  });
}

class _NavTab {
  final IconData icon;
  final String label;

  const _NavTab({required this.icon, required this.label});
}

// ── Marker widget ─────────────────────────────────────────────────────────────

class _PromoMarker extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;

  const _PromoMarker({
    required this.label,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: isSelected ? 0 : 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(isSelected ? 0.4 : 0.2),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        // Punta del marcador
        CustomPaint(
          size: const Size(10, 6),
          painter: _MarkerTipPainter(
            color: isSelected ? color : Colors.white,
            borderColor: isSelected ? color : color,
          ),
        ),
      ],
    );
  }
}

class _MarkerTipPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  const _MarkerTipPainter({required this.color, required this.borderColor});

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
  bool shouldRepaint(_MarkerTipPainter old) => false;
}
