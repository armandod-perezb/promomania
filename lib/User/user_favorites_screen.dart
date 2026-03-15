import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS
// ─────────────────────────────────────────────────────────────────────────────

enum _PromoUrgency { today, thisWeek, noRush }

class _FavoritePromo {
  final String id;
  final String title;
  final String store;
  final String category;
  final Color categoryColor;
  final String price;
  final String originalPrice;
  final String discount;
  final String rating;
  final String distance;
  final String timeLeft;
  final String savings;
  final String emoji;
  final _PromoUrgency urgency;
  final String urgencyLabel;

  const _FavoritePromo({
    required this.id,
    required this.title,
    required this.store,
    required this.category,
    required this.categoryColor,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.rating,
    required this.distance,
    required this.timeLeft,
    required this.savings,
    required this.emoji,
    required this.urgency,
    required this.urgencyLabel,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA MIS FAVORITOS
// ─────────────────────────────────────────────────────────────────────────────

class MisFavoritosScreen extends StatefulWidget {
  const MisFavoritosScreen({super.key});

  @override
  State<MisFavoritosScreen> createState() => _MisFavoritosScreenState();
}

class _MisFavoritosScreenState extends State<MisFavoritosScreen>
    with TickerProviderStateMixin {
  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);
  static const Color _green = Color(0xFF10B981);
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _lightBg = Color(0xFFF5F6FA);

  int _selectedTab = 0; // 0=Todas 1=Por vencer 2=Categorías 3=Usados
  int _selectedNavTab = 2; // Favoritos activo
  bool _showBanner = true;

  final List<_FavoritePromo> _allPromos = const [
    _FavoritePromo(
      id: '1',
      title: 'Café + Pastel al precio de 1',
      store: 'Coffee Lab',
      category: 'COMIDA',
      categoryColor: Color(0xFFFF4D2E),
      price: '\$18.000',
      originalPrice: '\$27.000 COP',
      discount: '-33%',
      rating: '4.9',
      distance: '0.3 km',
      timeLeft: '1 día',
      savings: '\$9.000 COP',
      emoji: '☕',
      urgency: _PromoUrgency.today,
      urgencyLabel: 'VENCE HOY',
    ),
    _FavoritePromo(
      id: '2',
      title: '2x1 Hamburguesas Gourmet',
      store: 'Burger House',
      category: 'COMIDA',
      categoryColor: Color(0xFFFF4D2E),
      price: '\$28.000',
      originalPrice: '\$56.000 COP',
      discount: '-50%',
      rating: '4.8',
      distance: '0.1 km',
      timeLeft: '2 días',
      savings: '\$28.000 COP',
      emoji: '🍔',
      urgency: _PromoUrgency.thisWeek,
      urgencyLabel: 'ESTA SEMANA',
    ),
    _FavoritePromo(
      id: '3',
      title: 'Kit Skincare 50% OFF',
      store: 'Beauty Store',
      category: 'BELLEZA',
      categoryColor: Color(0xFFEC4899),
      price: '\$65.000',
      originalPrice: '\$130.000 COP',
      discount: '-50%',
      rating: '4.7',
      distance: '2.1 km',
      timeLeft: '3 días',
      savings: '\$65.000 COP',
      emoji: '💄',
      urgency: _PromoUrgency.thisWeek,
      urgencyLabel: 'ESTA SEMANA',
    ),
    _FavoritePromo(
      id: '4',
      title: 'Colección Primavera 25% OFF',
      store: 'Trend Studio',
      category: 'MODA',
      categoryColor: Color(0xFF8B5CF6),
      price: '\$97.500',
      originalPrice: '\$130.000 COP',
      discount: '-25%',
      rating: '4.4',
      distance: '0.9 km',
      timeLeft: '4 días',
      savings: '\$52.500 COP',
      emoji: '👗',
      urgency: _PromoUrgency.thisWeek,
      urgencyLabel: 'ESTA SEMANA',
    ),
    _FavoritePromo(
      id: '5',
      title: 'iPhone 15 Pro + AirPods',
      store: 'Tech Zone',
      category: 'TECNOLOGÍA',
      categoryColor: Color(0xFF6366F1),
      price: '\$3.654.000',
      originalPrice: '\$4.299.000 COP',
      discount: '-15%',
      rating: '4.6',
      distance: '1.8 km',
      timeLeft: '1 año',
      savings: '\$645.000 COP',
      emoji: '📱',
      urgency: _PromoUrgency.noRush,
      urgencyLabel: 'SIN PRISA',
    ),
  ];

  late List<_FavoritePromo> _visiblePromos;
  final Set<String> _dismissed = {};

  @override
  void initState() {
    super.initState();
    _visiblePromos = List.from(_allPromos);
  }

  void _dismiss(String id) {
    setState(() {
      _dismissed.add(id);
      _visiblePromos.removeWhere((p) => p.id == id);
    });
    HapticFeedback.mediumImpact();
  }

  List<_FavoritePromo> get _filtered {
    switch (_selectedTab) {
      case 1:
        return _visiblePromos
            .where((p) => p.urgency == _PromoUrgency.today)
            .toList();
      case 3:
        return [];
      default:
        return _visiblePromos;
    }
  }

  // Estadísticas del header
  double get _totalSavings {
    double total = 0;
    for (final p in _visiblePromos) {
      final raw = p.savings
          .replaceAll('\$', '')
          .replaceAll(' COP', '')
          .replaceAll('.', '')
          .trim();
      total += double.tryParse(raw) ?? 0;
    }
    return total;
  }

  String _formatCurrency(double v) {
    final s = v.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '\$${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _lightBg,
        body: Column(
          children: [
            // Header fijo blanco
            _buildTopHeader(),
            // Contenido scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSavingsCard(),
                    if (_showBanner) _buildInfoBanner(),
                    _buildTabBar(),
                    _buildPromoGroups(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildTopHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Tu colección',
                style: TextStyle(fontSize: 12, color: Color(0xFF8A8FA8)),
              ),
              Text(
                'Mis Favoritos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A1F2E),
                ),
              ),
            ],
          ),
          // Badge de contador
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _primary.withOpacity(0.25), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite_rounded, color: _primary, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${_visiblePromos.length}',
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Savings card ─────────────────────────────────────────────────────────────

  Widget _buildSavingsCard() {
    final total = _totalSavings;
    final used = 1;
    final urgent = _visiblePromos
        .where((p) => p.urgency == _PromoUrgency.today)
        .length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _darkBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _darkBg.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.savings_outlined, color: Colors.white, size: 13),
                    SizedBox(width: 4),
                    Text(
                      'AHORROS DISPONIBLES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Donut chart simulado
              SizedBox(
                width: 54,
                height: 54,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: used / _visiblePromos.length.clamp(1, 100),
                      strokeWidth: 5,
                      backgroundColor: Colors.white.withOpacity(0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(_primary),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${((used / _visiblePromos.length.clamp(1, 100)) * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'Usados',
                          style: TextStyle(
                            color: Color(0xFF8A8FA8),
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _formatCurrency(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const Text(
            'COP',
            style: TextStyle(color: Color(0xFF8A8FA8), fontSize: 12),
          ),
          const SizedBox(height: 14),
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: used / _visiblePromos.length.clamp(1, 100),
              minHeight: 5,
              backgroundColor: Colors.white.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(_primary),
            ),
          ),
          const SizedBox(height: 12),
          // Stats row
          Row(
            children: [
              _miniStat('${_visiblePromos.length}', 'guardadas'),
              _statDivider(),
              _miniStat('$used', 'Usadas'),
              _statDivider(),
              _miniStat('$urgent', 'Urgentes'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String val, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8A8FA8), fontSize: 11),
        ),
      ],
    );
  }

  Widget _statDivider() => Container(
    width: 1,
    height: 28,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    color: Colors.white.withOpacity(0.1),
  );

  // ── Info banner ──────────────────────────────────────────────────────────────

  Widget _buildInfoBanner() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082), width: 1),
      ),
      child: Row(
        children: const [
          Icon(Icons.swipe_left_outlined, color: Color(0xFFF59E0B), size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Desliza una promo a la izquierda para eliminarla',
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF92651A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 8),
          // Close
        ],
      ),
    );
  }

  // ── Tab bar ──────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    final tabs = [
      _TabItem(icon: Icons.grid_view_rounded, label: 'Todas', badge: null),
      _TabItem(
        icon: Icons.schedule_rounded,
        label: 'Por vencer',
        badge: _allPromos
            .where((p) => p.urgency == _PromoUrgency.today)
            .length
            .toString(),
      ),
      _TabItem(icon: Icons.category_outlined, label: 'Categorías', badge: null),
      _TabItem(
        icon: Icons.check_circle_outline_rounded,
        label: 'Usados',
        badge: '1',
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTab = i);
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isActive ? _darkBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          tabs[i].icon,
                          size: 20,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFFB0B5CC),
                        ),
                        if (tabs[i].badge != null)
                          Positioned(
                            top: -5,
                            right: -8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: _primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tabs[i].badge!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tabs[i].label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFFB0B5CC),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Grupos de promos ─────────────────────────────────────────────────────────

  Widget _buildPromoGroups() {
    final promos = _filtered;

    if (promos.isEmpty) {
      return _buildEmptyState();
    }

    final today = promos
        .where((p) => p.urgency == _PromoUrgency.today)
        .toList();
    final thisWeek = promos
        .where((p) => p.urgency == _PromoUrgency.thisWeek)
        .toList();
    final noRush = promos
        .where((p) => p.urgency == _PromoUrgency.noRush)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (today.isNotEmpty) ...[
          _buildGroupHeader(
            '🔴 Vencen hoy — ¡Actúa ya!',
            const Color(0xFFFF4D2E),
          ),
          ...today.map((p) => _buildSwipeCard(p)).toList(),
        ],
        if (thisWeek.isNotEmpty) ...[
          _buildGroupHeader('🟡 Esta semana', const Color(0xFFF59E0B)),
          ...thisWeek.map((p) => _buildSwipeCard(p)).toList(),
        ],
        if (noRush.isNotEmpty) ...[
          _buildGroupHeader('🟢 Sin prisa', const Color(0xFF10B981)),
          ...noRush.map((p) => _buildSwipeCard(p)).toList(),
        ],
      ],
    );
  }

  Widget _buildGroupHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1F2E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeCard(_FavoritePromo promo) {
    return Dismissible(
      key: Key(promo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _dismiss(promo.id),
      background: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        decoration: BoxDecoration(
          color: _primary,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      child: _buildPromoCard(promo),
    );
  }

  Widget _buildPromoCard(_FavoritePromo p) {
    Color urgencyColor;
    switch (p.urgency) {
      case _PromoUrgency.today:
        urgencyColor = _primary;
        break;
      case _PromoUrgency.thisWeek:
        urgencyColor = _amber;
        break;
      case _PromoUrgency.noRush:
        urgencyColor = _green;
        break;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Fila principal
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Imagen / Emoji
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: p.categoryColor.withOpacity(0.1),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            p.emoji,
                            style: const TextStyle(fontSize: 34),
                          ),
                        ),
                        // Badge de descuento
                        Positioned(
                          top: 5,
                          left: 5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: p.categoryColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.discount,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store + badge urgencia
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              p.store,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF8A8FA8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: urgencyColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.urgencyLabel,
                              style: TextStyle(
                                color: urgencyColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        p.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1F2E),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Precio
                      Row(
                        children: [
                          Text(
                            p.price,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A1F2E),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            p.originalPrice,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFB0B5CC),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Rating + distancia + tiempo
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFBBF24),
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            p.rating,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF5A5F72),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            ' · ',
                            style: TextStyle(
                              color: Color(0xFFB0B5CC),
                              fontSize: 10,
                            ),
                          ),
                          const Icon(
                            Icons.location_on_outlined,
                            size: 11,
                            color: Color(0xFFB0B5CC),
                          ),
                          Text(
                            p.distance,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8A8FA8),
                            ),
                          ),
                          const Text(
                            ' · ',
                            style: TextStyle(
                              color: Color(0xFFB0B5CC),
                              fontSize: 10,
                            ),
                          ),
                          const Icon(
                            Icons.access_time_rounded,
                            size: 11,
                            color: Color(0xFFB0B5CC),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            p.timeLeft,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8A8FA8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Botón Ver Promo
                Column(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ver Promo',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: _primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Footer de ahorro
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.07),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
              border: Border(
                top: BorderSide(color: _green.withOpacity(0.15), width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.savings_outlined,
                  color: Color(0xFF10B981),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ahorras si usas esta promo',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: _green.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  p.savings,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _green,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: const [
            Text('😕', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text(
              'Sin favoritos aquí',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1F2E),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Guarda promos tocando el ❤️\nen cualquier oferta',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF8A8FA8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom nav ───────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    final tabs = [
      _NavItem(icon: Icons.map_rounded, label: 'Inicio'),
      _NavItem(icon: Icons.explore_outlined, label: 'Explorar'),
      _NavItem(icon: Icons.favorite_border_rounded, label: 'Favoritos'),
      _NavItem(icon: Icons.person_outline_rounded, label: 'Perfil'),
    ];

    return Container(
      height: 64 + MediaQuery.of(context).padding.bottom,
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
          final isActive = _selectedNavTab == i;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedNavTab = i);
              HapticFeedback.selectionClick();
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
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? _primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isActive && i == 2
                          ? Icons.favorite_rounded
                          : tabs[i].icon,
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

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS AUXILIARES
// ─────────────────────────────────────────────────────────────────────────────

class _TabItem {
  final IconData icon;
  final String label;
  final String? badge;
  const _TabItem({
    required this.icon,
    required this.label,
    required this.badge,
  });
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
