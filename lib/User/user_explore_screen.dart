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
// PANTALLA PRINCIPAL
// ─────────────────────────────────────────────────────────────────────────────

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);

  int _selectedTab = 1; // Explorar activo
  int _selectedSort = 0;
  bool _gridView = false;

  // Countdown timer simulado: 00:46:23
  int _hours = 0, _minutes = 46, _seconds = 23;

  late final AnimationController _bannerCtrl;
  late final Animation<double> _bannerFade;

  final List<String> _sortOptions = ['Relevancia', 'Precio', 'Rating', 'Cerca'];

  @override
  void initState() {
    super.initState();
    _bannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bannerFade = CurvedAnimation(parent: _bannerCtrl, curve: Curves.easeOut);
    _bannerCtrl.forward();

    void _tickTimer() {
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
        }
      });
    }

    Future.delayed(const Duration(seconds: 1), _tickTimer);
  }

  @override
  void dispose() {
    _bannerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: promoService,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(promoService)),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildHeroBanner()),
              if (promoService.loaded && promoService.loadError == null)
                SliverToBoxAdapter(child: _buildFlashDealsSection(promoService)),
              if (promoService.loaded && promoService.loadError == null)
                SliverToBoxAdapter(child: _buildNearbySection(promoService)),
              if (promoService.loaded && promoService.loadError == null)
                SliverToBoxAdapter(child: _buildAllPromosHeader(promoService)),
              if (promoService.loaded && promoService.loadError == null)
                _buildPromosGrid(promoService),
              if (!promoService.loaded && promoService.loadError == null)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (promoService.loadError != null)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar datos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          promoService.loadError!,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => promoService.init(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(PromoService promoService) {
    // Get current user (for demo, using first user)
    final currentUser = promoService.getUsuarios().isNotEmpty
        ? promoService.getUsuarios().first
        : null;
    final userCity = currentUser?.ciudad ?? 'Bogotá';

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: _primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$userCity, Colombia',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Buenos días${currentUser != null ? ', ${currentUser.nombre.split(' ').first}' : ''}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // 🔔 Notificación
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                const Center(child: Icon(Icons.notifications_none, size: 22)),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // 👤 Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _darkBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                currentUser != null
                    ? currentUser.nombre
                          .split(' ')
                          .map((name) => name[0])
                          .take(2)
                          .join()
                          .toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Barra de búsqueda ─────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 12),
                  Icon(Icons.search, color: Color(0xFFB0B5CC)),
                  SizedBox(width: 8),
                  Text(
                    'Buscar tiendas, productos...',
                    style: TextStyle(color: Color(0xFFB0B5CC), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.tune, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ── Hero Banner ───────────────────────────────────────────────────────────

  Widget _buildHeroBanner() {
    return FadeTransition(
      opacity: _bannerFade,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          image: const DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1553621042-f6e147245754',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.0),
                Colors.black.withOpacity(0.45),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🟦 etiqueta
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Tiempo limitado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Sushi Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  '30% OFF — 20 piezas por \$42.000',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const Spacer(),

                // 🔵 botón
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Pedir ahora',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Flash Deals ───────────────────────────────────────────────────────────

  Widget _buildFlashDealsSection(PromoService promoService) {
    final flashDeals = promoService.getFlashDeals(limit: 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded, color: _primary, size: 20),
                      const SizedBox(width: 6),
                      const Text(
                        'Flash Deals',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1F2E),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Termina en',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A8FA8),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _timerChip(_hours.toString().padLeft(2, '0')),
                      const SizedBox(width: 3),
                      const Text(':'),
                      const SizedBox(width: 3),
                      _timerChip(_minutes.toString().padLeft(2, '0')),
                      const SizedBox(width: 3),
                      const Text(':'),
                      const SizedBox(width: 3),
                      _timerChip(_seconds.toString().padLeft(2, '0')),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Ver todos >',
                style: TextStyle(
                  fontSize: 12.5,
                  color: _primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: flashDeals.length,
            itemBuilder: (_, i) =>
                _buildFlashDealCard(flashDeals[i], promoService),
          ),
        ),
      ],
    );
  }

  // ── Timer Chip ───────────────────────────────────────────────────────────

  Widget _timerChip(String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _darkBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        val,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  // ── Navegación ───────────────────────────────────────────────────────────

  void _openPromotionDetails(String promoCode) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(
      context,
      AppRoutes.promotionDetails,
      arguments: promoCode,
    );
  }

  // Helper method to build promo images with fallback
  Widget _buildPromoImage(Promocion promo, String? emoji, double height) {
    // Check if we have cached image bytes
    final imageBytes = promoService.getImageBytes(promo.codigo);

    if (imageBytes != null) {
      return Image.memory(
        imageBytes,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildImageFallback(emoji, height),
      );
    }

    // Try network image if available
    if (promo.foto != null && promo.foto!.isNotEmpty) {
      return Image.network(
        promo.foto!,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildImageFallback(emoji, height),
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
        child: Text(emoji ?? '📦', style: TextStyle(fontSize: height * 0.4)),
      ),
    );
  }

  // ── Card NUEVA estilo imagen ─────────────────────────────────────────────

  Widget _buildFlashDealCard(Promocion promo, PromoService promoService) {
    final supermercado = promoService.getSupermercado(promo.idSupermercado);
    final categoria = promoService.getCategoria(promo.idCategoria);
    final categoriaStyle = promoService.getCategoriaStyle(promo.idCategoria);
    final precioConDescuento = promoService.getPrecioConDescuento(promo);
    final rating = promoService.getPromocionRating(promo.codigo);
    final discount = promo.descuento != null ? '-${promo.descuento}%' : '';

    return GestureDetector(
      onTap: () => _openPromotionDetails(promo.codigo),
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 IMAGEN
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Stack(
                children: [
                  _buildPromoImage(promo, categoriaStyle['emoji'], 100),

                  // 🔴 DESCUENTO
                  if (discount.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          discount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            //  INFO
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promo.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    supermercado?.nombre ?? 'Tienda',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8A8FA8),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 💰 PRECIOS
                  Row(
                    children: [
                      Text(
                        '\$${precioConDescuento.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.red,
                        ),
                      ),
                      if (promo.descuento != null && promo.descuento! > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '\$${promo.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFB0B5CC),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

                  // RATING
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: Color(0xFFFFB703),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Imágenes por categoría ───────────────────────────────────────────────

  String _getImageByCategory(String category) {
    switch (category) {
      case 'Café':
        return 'https://images.unsplash.com/photo-1509042239860-f550ce710b93';
      case 'Salud':
        return 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd';
      case 'Bebidas':
        return 'https://images.unsplash.com/photo-1551024506-0bccd828d307';
      default:
        return 'https://images.unsplash.com/photo-1490645935967-10de6ba17061';
    }
  }

  // ── Tiendas cerca ─────────────────────────────────────────────────────────

  Widget _buildNearbySection(PromoService promoService) {
    final nearbyStores = promoService.getNearbyStores(limit: 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, color: _primary, size: 18),
              const SizedBox(width: 6),
              const Text(
                'Tiendas cerca',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1F2E),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Ver mapa >',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: nearbyStores.length,
            itemBuilder: (_, i) =>
                _buildNearbyCard(nearbyStores[i], promoService),
          ),
        ),
      ],
    );
  }

  // ── Card moderna con imagen ───────────────────────────────────────────────

  Widget _buildNearbyCard(
    Map<String, dynamic> storeData,
    PromoService promoService,
  ) {
    final supermercado = storeData['supermercado'] as Supermercado;
    final promociones = storeData['promociones'] as List<Promocion>;
    final distancia = storeData['distancia'] as String;
    final tiempo = storeData['tiempo'] as String;

    // Calculate average rating from promotions
    double avgRating = 0;
    if (promociones.isNotEmpty) {
      final totalRating = promociones
          .map((p) => promoService.getPromocionRating(p.codigo))
          .reduce((a, b) => a + b);
      avgRating = totalRating / promociones.length;
    }

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼 IMAGEN
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: promociones.isNotEmpty
                      ? _buildPromoImage(promociones.first, '🏪', 110)
                      : const Center(
                          child: Icon(
                            Icons.store,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                ),

                // 📍 DISTANCIA (overlay)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      distancia,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // ⭐ RATING (overlay)
                if (avgRating > 0)
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 10,
                            color: Colors.yellow,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
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

          // 📄 INFO
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supermercado.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1F2E),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${promociones.length} promos',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8A8FA8),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: Color(0xFFB0B5CC),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      tiempo,
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
        ],
      ),
    );
  }

  Widget _buildPromoGridCard(Promocion promo, PromoService promoService) {
    final supermercado = promoService.getSupermercado(promo.idSupermercado);
    final categoria = promoService.getCategoria(promo.idCategoria);
    final categoriaStyle = promoService.getCategoriaStyle(promo.idCategoria);
    final precioConDescuento = promoService.getPrecioConDescuento(promo);
    final rating = promoService.getPromocionRating(promo.codigo);
    final reviewsCount = promoService.getPromocionReviewsCount(promo.codigo);
    final urgency = promoService.getPromocionUrgency(promo);

    // For demo, use first user as current user
    final currentUser = promoService.getUsuarios().isNotEmpty
        ? promoService.getUsuarios().first.id
        : 1;
    
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

    final discount = promo.descuento != null ? '-${promo.descuento}%' : '';
    final categoryColor = Color(
      int.parse(categoriaStyle['color']!.replaceFirst('#', '0xFF')),
    );

    return GestureDetector(
      onTap: () => _openPromotionDetails(promo.codigo),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 IMAGEN REAL
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: SizedBox(
                height: 126,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen o fallback
                    _buildPromoImage(promo, categoriaStyle['emoji'], 126),

                    // 🔥 OVERLAY OSCURO
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // 🔥 DESCUENTO (arriba izquierda)
                    if (discount.isNotEmpty)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            discount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                    // 🔥 FAVORITO (círculo blanco flotante)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          promoService.toggleFavorito(
                            currentUser,
                            promo.codigo,
                          );
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            promoService.isFavorito(currentUser, promo.codigo) 
                                ? Icons.favorite 
                                : Icons.favorite_border,
                            color: promoService.isFavorito(currentUser, promo.codigo)
                                ? Colors.red
                                : const Color(0xFFB0B5CC),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔥 CONTENIDO
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 CATEGORÍA (chip)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      categoria?.nombre ?? 'Categoría',
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 🔥 TÍTULO
                  Text(
                    promo.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // 🔥 STORE
                  Text(
                    supermercado?.nombre ?? 'Tienda',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8A8FA8),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 🔥 PRECIO
                  Row(
                    children: [
                      Text(
                        '\$${precioConDescuento.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.redAccent,
                        ),
                      ),
                      if (promo.descuento != null && promo.descuento! > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '\$${promo.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFB0B5CC),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 6),

                  // 🔥 RATING + TIEMPO
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: Color(0xFFFBBF24),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '($reviewsCount)',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF8A8FA8),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.access_time,
                        size: 11,
                        color: Color(0xFFB0B5CC),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        timeDisplay,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFB0B5CC),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// TODAS LAS PROMO
  Widget _buildAllPromosHeader(PromoService promoService) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
      child: Row(
        children: [
          const Icon(Icons.local_offer_rounded, color: _primary, size: 18),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Todas las promociones',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1F2E),
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedSort,
              isDense: true,
              borderRadius: BorderRadius.circular(12),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1A1F2E),
                fontWeight: FontWeight.w600,
              ),
              items: List.generate(
                _sortOptions.length,
                (i) => DropdownMenuItem(value: i, child: Text(_sortOptions[i])),
              ),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _selectedSort = v);
              },
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _gridView = !_gridView),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE3E6EF)),
              ),
              child: Icon(
                _gridView ? Icons.grid_view_rounded : Icons.view_agenda_rounded,
                size: 18,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverPadding _buildPromosGrid(PromoService promoService) {
    final promociones = promoService.getPromocionesAprobadas();
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 400;
    final crossAxisCount = _gridView ? 1 : 2;
    final childAspectRatio = _gridView
        ? (isNarrow ? 2.05 : 2.25)
        : (isNarrow ? 0.52 : 0.56);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 10,
          childAspectRatio: childAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) =>
              _buildPromoGridCard(promociones[index], promoService),
          childCount: promociones.length,
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────

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
      height: 64 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
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
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? _primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
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

// ── Modelo auxiliar ───────────────────────────────────────────────────────────

class _NavTab {
  final IconData icon;
  final String label;
  const _NavTab({required this.icon, required this.label});
}
