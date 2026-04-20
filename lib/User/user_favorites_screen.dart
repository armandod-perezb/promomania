import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Core/Routes/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS
// ─────────────────────────────────────────────────────────────────────────────

enum _PromoUrgency { today, thisWeek, noRush }

class _FavoritePromo {
  final String id;
  final String imageUrl;
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
    required this.imageUrl,
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
      imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93',
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
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
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
      imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9',
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
      imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050',
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
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9',
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header que se desplaza con el contenido
              _buildTopHeader(),
              _buildSavingsCard(),
              if (_showBanner) _buildInfoBanner(),
              _buildTabBar(),
              _buildPromoGroups(),
              const SizedBox(height: 24),
            ],
          ),
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
        left: 16,
        right: 16,
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Mis Favoritos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1F2E),
            ),
          ),
          // Badge de contador
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8EAF0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite_rounded, color: _primary, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${_visiblePromos.length}',
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 12.5,
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
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _darkBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _darkBg.withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.savings_outlined, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'AHORROS DISPONIBLES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Donut chart simulado
              SizedBox(
                width: 50,
                height: 50,
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
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'Usados',
                          style: TextStyle(
                            color: Color(0xFF8A8FA8),
                            fontSize: 7,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const Text(
            'COP',
            style: TextStyle(color: Color(0xFFB9C0D0), fontSize: 11),
          ),
          const SizedBox(height: 10),
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: used / _visiblePromos.length.clamp(1, 100),
              child: Container(
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStat('${_visiblePromos.length}', 'guardadas'),
              _miniStat('$used', 'Usadas'),
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
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8A8FA8), fontSize: 10),
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
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F3F8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.swipe_left_outlined,
              color: _primary,
              size: 12,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Desliza una promo a la izquierda para eliminarla',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.close, color: Color(0xFFB0B5CC), size: 11),
          ),
        ],
      ),
    );
  }

  // ── Tab bar ──────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    final tabs = [
      _TabItem(
        icon: Icons.bookmark_border_rounded,
        label: 'Todas',
        badge: null,
      ),
      _TabItem(
        icon: Icons.local_fire_department_outlined,
        label: 'Por vencer',
        badge: '1',
      ),
      _TabItem(icon: Icons.folder_outlined, label: 'Carpetas', badge: '4'),
      _TabItem(
        icon: Icons.check_circle_outline_rounded,
        label: 'Usados',
        badge: '1',
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF111827)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          tabs[i].icon,
                          size: 22,
                          color: isActive
                              ? Colors.white
                              : const Color(0xFF9CA3AF),
                        ),
                        if (tabs[i].badge != null)
                          Positioned(
                            top: -10,
                            right: -14,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _primary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                tabs[i].badge!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tabs[i].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF9CA3AF),
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
            'Vencen hoy — ¡Actúa ya!',
            const Color(0xFFFF4D2E),
            '🔥',
          ),
          ...today.map((p) => _buildSwipeCard(p)).toList(),
        ],
        if (thisWeek.isNotEmpty) ...[
          _buildGroupHeader('Esta semana', const Color(0xFFF59E0B), '⏳'),
          ...thisWeek.map((p) => _buildSwipeCard(p)).toList(),
        ],
        if (noRush.isNotEmpty) ...[
          _buildGroupHeader('Sin prisa', const Color(0xFF10B981), '🟢'),
          ...noRush.map((p) => _buildSwipeCard(p)).toList(),
        ],
      ],
    );
  }

  Widget _buildGroupHeader(String title, Color color, String emoji) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1F2E),
                  ),
                ),
              ],
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
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
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
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
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
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Imagen / Emoji
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(p.imageUrl, fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              p.discount,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                                fontSize: 10,
                                color: Color(0xFF8A8FA8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: urgencyColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              p.urgencyLabel,
                              style: TextStyle(
                                color: urgencyColor,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1F2E),
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Precio
                      Row(
                        children: [
                          Text(
                            p.price,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A1F2E),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            p.originalPrice,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFFB0B5CC),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Rating + distancia + tiempo
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFBBF24),
                            size: 10,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            p.rating,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF5A5F72),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            ' · ',
                            style: TextStyle(
                              color: Color(0xFFB0B5CC),
                              fontSize: 8,
                            ),
                          ),
                          const Icon(
                            Icons.location_on_outlined,
                            size: 9,
                            color: Color(0xFFB0B5CC),
                          ),
                          Text(
                            p.distance,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF8A8FA8),
                            ),
                          ),
                          const Text(
                            ' · ',
                            style: TextStyle(
                              color: Color(0xFFB0B5CC),
                              fontSize: 8,
                            ),
                          ),
                          const Icon(
                            Icons.access_time_rounded,
                            size: 9,
                            color: Color(0xFFB0B5CC),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            p.timeLeft,
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF8A8FA8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Botón Ver Promo
                Column(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
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
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Ver Promo',
                      style: TextStyle(
                        fontSize: 8,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  size: 12,
                ),
                const SizedBox(width: 5),
                Text(
                  'Ahorras si usas esta promo',
                  style: TextStyle(
                    fontSize: 10,
                    color: _green.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  p.savings,
                  style: const TextStyle(
                    fontSize: 11.5,
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
    final routesByTab = [
      AppRoutes.userHome,
      AppRoutes.explore,
      AppRoutes.userFavorites,
      AppRoutes.userProfile,
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
              HapticFeedback.selectionClick();

              if (_selectedNavTab != i) {
                setState(() => _selectedNavTab = i);
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
