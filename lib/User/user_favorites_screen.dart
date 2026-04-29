import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Core/Routes/app_routes.dart';
import '../main.dart';
import '../services/promo_service.dart';
import '../models/promocion.dart';
import '../models/supermercado.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS
// ─────────────────────────────────────────────────────────────────────────────


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


  @override
  void initState() {
    super.initState();
  }

  void _dismiss(String promoCode) {
    // For demo, use first user as current user
    final currentUser = promoService.getUsuarios().isNotEmpty 
        ? promoService.getUsuarios().first.id 
        : 1;
    promoService.toggleFavorito(currentUser, promoCode);
    HapticFeedback.mediumImpact();
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
    // For demo, use first user as current user
    final currentUser = promoService.getUsuarios().isNotEmpty 
        ? promoService.getUsuarios().first.id 
        : 1;
    final favoritePromos = promoService.getFavoritosByUsuario(currentUser);
    
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
    // For demo, use first user as current user
    final currentUser = promoService.getUsuarios().isNotEmpty 
        ? promoService.getUsuarios().first.id 
        : 1;
    final favoritePromos = promoService.getFavoritosByUsuario(currentUser);
    
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
                  '${favoritePromos.length}',
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
    // For demo, use first user as current user
    final currentUser = promoService.getUsuarios().isNotEmpty 
        ? promoService.getUsuarios().first.id 
        : 1;
    final favoritePromos = promoService.getFavoritosByUsuario(currentUser);
    
    // Calculate total savings
    double totalSavings = 0;
    for (final favorito in favoritePromos) {
      final promo = promoService.getPromocionByCodigo(favorito.codigoPromocion);
      if (promo != null && promo.descuento != null) {
        final discountAmount = promo.precio * (promo.descuento! / 100);
        totalSavings += discountAmount;
      }
    }
    
    final total = totalSavings;
    final used = 1;
    
    // Calculate urgent promotions (expiring today)
    int urgent = 0;
    for (final favorito in favoritePromos) {
      final promo = promoService.getPromocionByCodigo(favorito.codigoPromocion);
      if (promo != null) {
        final urgency = promoService.getPromocionUrgency(promo);
        if (urgency == 'today') urgent++;
      }
    }

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
                      value: used / favoritePromos.length.clamp(1, 100),
                      strokeWidth: 5,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(_primary),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${((used / favoritePromos.length.clamp(1, 100)) * 100).toInt()}%',
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
              widthFactor: used / favoritePromos.length.clamp(1, 100),
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
              _miniStat('${favoritePromos.length}', 'guardadas'),
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
        children: [
          _tabItem(0, 'Todas'),
          _tabItem(1, 'Por vencer'),
          _tabItem(2, 'Categorías'),
          _tabItem(3, 'Usados'),
        ],
      ),
    );
  }

  // ── Grupos de promos ─────────────────────────────────────────────────────────

  Widget _buildPromoGroups() {
    // For demo, use first user as current user
    final currentUser = promoService.getUsuarios().isNotEmpty 
        ? promoService.getUsuarios().first.id 
        : 1;
    final favoritePromos = promoService.getFavoritosByUsuario(currentUser);
    
    // Get promotions by urgency
    final promosByUrgency = promoService.getPromocionesByUrgency(currentUser);
    
    // Filter based on selected tab
    switch (_selectedTab) {
      case 0: // Todas
        return _buildAllCategories(promosByUrgency);
      case 1: // Por vencer (3 días o menos)
        return _buildExpiringSoon(currentUser);
      case 2: // Categorías
        return _buildByCategories(currentUser);
      case 3: // Usados (not implemented yet)
        return _buildEmptyState();
      default:
        return _buildAllCategories(promosByUrgency);
    }
  }

  // Helper method to get promotions expiring in 3 days or less
  List<Promocion> _getPromotionsExpiringIn3Days(int userId) {
    final favoritePromos = promoService.getFavoritosByUsuario(userId);
    final promocionesFavoritas = favoritePromos
        .map((f) => promoService.getPromocionByCodigo(f.codigoPromocion))
        .where((p) => p != null)
        .cast<Promocion>();

    List<Promocion> expiringSoon = [];
    final ahora = DateTime.now();

    for (final promo in promocionesFavoritas) {
      if (promo.tipoVigencia != 'permanente' && promo.fechaFin != null) {
        try {
          final fechaFin = DateTime.parse(promo.fechaFin!);
          final diferencia = fechaFin.difference(ahora);
          
          // Include promotions expiring in 3 days or less
          if (!diferencia.isNegative && diferencia.inDays <= 3) {
            expiringSoon.add(promo);
          }
        } catch (e) {
          // Skip invalid dates
        }
      }
    }

    return expiringSoon;
  }

  Widget _buildExpiringSoon(int userId) {
    final expiringSoon = _getPromotionsExpiringIn3Days(userId);
    
    if (expiringSoon.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGroupHeader(
          'Vencen en 3 días o menos',
          const Color(0xFFFF4D2E),
          '⏰',
        ),
        ...expiringSoon.map((p) => _buildSwipeCard(p)).toList(),
      ],
    );
  }

  Widget _buildByCategories(int userId) {
    final favoritePromos = promoService.getFavoritosByUsuario(userId);
    final promocionesFavoritas = favoritePromos
        .map((f) => promoService.getPromocionByCodigo(f.codigoPromocion))
        .where((p) => p != null)
        .cast<Promocion>();

    // Group by category
    final Map<String, List<Promocion>> promosByCategory = {};
    
    for (final promo in promocionesFavoritas) {
      final categoria = promoService.getCategoria(promo.idCategoria);
      final categoryName = categoria?.nombre ?? 'Sin categoría';
      
      if (!promosByCategory.containsKey(categoryName)) {
        promosByCategory[categoryName] = [];
      }
      promosByCategory[categoryName]!.add(promo);
    }

    if (promosByCategory.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...promosByCategory.entries.map((entry) {
          final categoryName = entry.key;
          final promos = entry.value;
          final categoryStyle = promoService.getCategoriaStyle(promos.first.idCategoria);
          final emoji = categoryStyle['emoji'] ?? '📦';
          final color = _getCategoryColor(categoryName);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGroupHeader(categoryName, color, emoji),
              ...promos.map((p) => _buildSwipeCard(p)).toList(),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAllCategories(Map<String, List<Promocion>> promosByUrgency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (promosByUrgency['today']!.isNotEmpty) ...[
          _buildGroupHeader(
            'Vencen hoy — ¡Actúa ya!',
            const Color(0xFFFF4D2E),
            '🔥',
          ),
          ...promosByUrgency['today']!.map((p) => _buildSwipeCard(p)).toList(),
        ],
        if (promosByUrgency['thisWeek']!.isNotEmpty) ...[
          _buildGroupHeader('Esta semana', const Color(0xFFF59E0B), '⏳'),
          ...promosByUrgency['thisWeek']!.map((p) => _buildSwipeCard(p)).toList(),
        ],
        if (promosByUrgency['noRush']!.isNotEmpty) ...[
          _buildGroupHeader('Sin prisa', const Color(0xFF10B981), '🟢'),
          ...promosByUrgency['noRush']!.map((p) => _buildSwipeCard(p)).toList(),
        ],
      ],
    );
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'alimentos':
        return const Color(0xFF10B981);
      case 'tecnología':
        return const Color(0xFF3B82F6);
      case 'ropa':
        return const Color(0xFF8B5CF6);
      case 'hogar':
        return const Color(0xFFF59E0B);
      case 'salud':
        return const Color(0xFFEF4444);
      case 'deportes':
        return const Color(0xFF06B6D4);
      case 'belleza':
        return const Color(0xFFEC4899);
      case 'juguetes':
        return const Color(0xFF84CC16);
      case 'libros':
        return const Color(0xFF6366F1);
      case 'automotriz':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFFFF4D2E);
    }
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

  Widget _buildSwipeCard(Promocion promo) {
    return Dismissible(
      key: Key(promo.codigo),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _dismiss(promo.codigo),
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

  Widget _buildPromoCard(Promocion promo) {
    final supermercado = promoService.getSupermercado(promo.idSupermercado);
    final categoria = promoService.getCategoria(promo.idCategoria);
    final categoriaStyle = promoService.getCategoriaStyle(promo.idCategoria);
    final precioConDescuento = promoService.getPrecioConDescuento(promo);
    final rating = promoService.getPromocionRating(promo.codigo);
    final urgency = promoService.getPromocionUrgency(promo);
    
    // Determine urgency color and label
    Color urgencyColor;
    String urgencyLabel;
    switch (urgency) {
      case 'today':
        urgencyColor = _primary;
        urgencyLabel = 'VENCE HOY';
        break;
      case 'thisWeek':
        urgencyColor = _amber;
        urgencyLabel = 'ESTA SEMANA';
        break;
      default:
        urgencyColor = _green;
        urgencyLabel = 'SIN PRISA';
    }
    
    final discount = promo.descuento != null ? '-${promo.descuento}%' : '';
    
    // Format time display
    String timeDisplay = 'permanente';
    if (promo.fechaFin != null) {
      try {
        final fechaFin = DateTime.parse(promo.fechaFin!);
        final ahora = DateTime.now();
        final diferencia = fechaFin.difference(ahora);
        
        if (diferencia.inDays > 0) {
          timeDisplay = '${diferencia.inDays} días';
        } else if (diferencia.inHours > 0) {
          timeDisplay = '${diferencia.inHours} horas';
        } else {
          timeDisplay = '${diferencia.inMinutes} min';
        }
      } catch (e) {
        timeDisplay = 'permanente';
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                        _buildPromoImage(promo, categoriaStyle['emoji'], 50),
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
                        if (discount.isNotEmpty)
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
                                discount,
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
                              supermercado?.nombre ?? 'Tienda',
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
                              color: urgencyColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              urgencyLabel,
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
                        promo.titulo,
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
                            '\$${precioConDescuento.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A1F2E),
                            ),
                          ),
                          if (promo.descuento != null && promo.descuento! > 0) ...[
                            const SizedBox(width: 5),
                            Text(
                              '\$${promo.precio.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: Color(0xFFB0B5CC),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
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
                            rating.toStringAsFixed(1),
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
                            Icons.access_time_rounded,
                            size: 9,
                            color: Color(0xFFB0B5CC),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            timeDisplay,
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
                    GestureDetector(
                      onTap: () => _openPromotionDetails(promo.codigo),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _primary.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ver',
                      style: TextStyle(
                        fontSize: 9,
                        color: _primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Footer con ahorro
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (promo.descuento != null && promo.descuento! > 0)
                  Text(
                    'Ahorras \$${(promo.precio * promo.descuento! / 100).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: _green,
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Text(
                  categoria?.nombre ?? 'Categoría',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(int.parse(categoriaStyle['color']!.replaceFirst('#', '0xFF'))),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper Methods ────────────────────────────────────────────────────────────

  Widget _tabItem(int index, String label) {
    final isActive = _selectedTab == index;
    
    // For demo, use first user as current user
    final currentUser = promoService.getUsuarios().isNotEmpty 
        ? promoService.getUsuarios().first.id 
        : 1;
    final favoritePromos = promoService.getFavoritosByUsuario(currentUser);
    final promosByUrgency = promoService.getPromocionesByUrgency(currentUser);
    
    // Calculate badge counts
    String? badge;
    if (index == 0) {
      badge = favoritePromos.length.toString();
    } else if (index == 1) {
      final urgentCount = promosByUrgency['today']!.length + promosByUrgency['thisWeek']!.length;
      badge = urgentCount > 0 ? urgentCount.toString() : null;
    }
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = index);
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
                    _getTabIcon(index),
                    size: 22,
                    color: isActive
                        ? Colors.white
                        : const Color(0xFF9CA3AF),
                  ),
                  if (badge != null)
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
                          badge,
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
                label,
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
  }

  IconData _getTabIcon(int index) {
    switch (index) {
      case 0:
        return Icons.bookmark_border_rounded;
      case 1:
        return Icons.local_fire_department_outlined;
      case 2:
        return Icons.folder_outlined;
      case 3:
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildPromoImage(Promocion promo, String? emoji, double height) {
    // Check if we have cached image bytes
    final imageBytes = promoService.getImageBytes(promo.codigo);
    
    if (imageBytes != null) {
      return Image.memory(
        imageBytes,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageFallback(emoji, height),
      );
    }
    
    // Try network image if available
    if (promo.foto != null && promo.foto!.isNotEmpty) {
      return Image.network(
        promo.foto!,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageFallback(emoji, height),
      );
    }
    
    // Fallback to emoji
    return _buildImageFallback(emoji, height);
  }

  Widget _buildImageFallback(String? emoji, double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.grey[200],
      child: Center(
        child: Text(
          emoji ?? '📦',
          style: TextStyle(fontSize: height * 0.4),
        ),
      ),
    );
  }

  void _openPromotionDetails(String promoCode) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, AppRoutes.promotionDetails, arguments: promoCode);
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
