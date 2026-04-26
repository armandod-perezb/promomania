import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Core/Routes/app_routes.dart';
import '../main.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS
// ─────────────────────────────────────────────────────────────────────────────

class _FlashDeal {
  final String title;
  final String store;
  final String category;
  final String price;
  final String originalPrice;
  final String discount;
  final String rating;
  final String emoji;
  final Color accentColor;

  const _FlashDeal({
    required this.title,
    required this.store,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.rating,
    required this.emoji,
    required this.accentColor,
  });
}

class _NearbyStore {
  final String name;
  final String category;
  final String distance;
  final String time;
  final String rating;
  final String emoji;
  final Color bgColor;

  const _NearbyStore({
    required this.name,
    required this.category,
    required this.distance,
    required this.time,
    required this.rating,
    required this.emoji,
    required this.bgColor,
  });
}

class _PromoCard {
  final String title;
  final String store;
  final String category;
  final Color categoryColor;
  final String? imageUrl;
  final String price;
  final String originalPrice;
  final String discount;
  final Color discountColor;
  final String rating;
  final String reviews;
  final String time;
  final String emoji;
  final bool isFavorite;

  const _PromoCard({
    required this.title,
    required this.store,
    required this.category,
    required this.categoryColor,
    this.imageUrl,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.discountColor,
    required this.rating,
    required this.reviews,
    required this.time,
    required this.emoji,
    this.isFavorite = false,
  });
}

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

  final List<_FlashDeal> _flashDeals = const [
    _FlashDeal(
      title: 'Café Especial',
      store: 'Coffee Lab',
      category: 'Café',
      price: '\$8.000',
      originalPrice: '\$12.000',
      discount: '-35%',
      rating: '4.8',
      emoji: '☕',
      accentColor: Color(0xFF8B4513),
    ),
    _FlashDeal(
      title: 'Bowl Açaí',
      store: 'Fresh & Co.',
      category: 'Salud',
      price: '\$18.000',
      originalPrice: '\$24.000',
      discount: '-25%',
      rating: '4.1',
      emoji: '🫐',
      accentColor: Color(0xFF6B21A8),
    ),
    _FlashDeal(
      title: 'Jugo Natural 1L',
      store: 'NaturaCo',
      category: 'Bebidas',
      price: '\$12.000',
      originalPrice: '\$15.000',
      discount: '-20%',
      rating: '4.0',
      emoji: '🥤',
      accentColor: Color(0xFFD97706),
    ),
  ];

  final List<_NearbyStore> _nearbyStores = const [
    _NearbyStore(
      name: 'Burger House',
      category: 'Comida',
      distance: '0.1km',
      time: '15 min',
      rating: '4.8',
      emoji: '🍔',
      bgColor: Color(0xFFFFF3E0),
    ),
    _NearbyStore(
      name: 'Coffee Lab',
      category: 'Café',
      distance: '0.3km',
      time: '8 min',
      rating: '4.7',
      emoji: '☕',
      bgColor: Color(0xFFF3E5F5),
    ),
    _NearbyStore(
      name: 'SportMax',
      category: 'Deportes',
      distance: '1.2km',
      time: '25 min',
      rating: '4.5',
      emoji: '🏋️',
      bgColor: Color(0xFFE8F5E9),
    ),
  ];

  final List<_PromoCard> _promos = const [
    _PromoCard(
      title: '2x1 Hamburguesas Gourmet',
      store: 'Burger House',
      category: 'Comida',
      categoryColor: Color(0xFFFF4D2E),
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd',
      price: '\$28.000',
      originalPrice: '\$56.000',
      discount: '-50%',
      discountColor: Color(0xFFFF4D2E),
      rating: '4.9',
      reviews: '432',
      time: '2 días',
      emoji: '🍔',
    ),
    _PromoCard(
      title: '40% OFF Zapatillas Nike',
      store: 'NorthFeet',
      category: 'Deportes',
      categoryColor: Color(0xFF3B82F6),
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
      price: '\$180.000',
      originalPrice: '\$300.000',
      discount: '-40%',
      discountColor: Color(0xFF3B82F6),
      rating: '4.5',
      reviews: '1128',
      time: '1 min',
      emoji: '👟',
      isFavorite: true,
    ),
    _PromoCard(
      title: 'Café Especial + Pastel',
      store: 'Coffee Lab',
      category: 'Comida',
      categoryColor: Color(0xFFFF4D2E),
      imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93',
      price: '\$18.000',
      originalPrice: '\$27.000',
      discount: '-33%',
      discountColor: Color(0xFFFF4D2E),
      rating: '4.9',
      reviews: '220',
      time: '1 día',
      emoji: '☕',
    ),
    _PromoCard(
      title: 'Kit Skincare Completo',
      store: 'Glow Studio',
      category: 'Belleza',
      categoryColor: Color(0xFFEC4899),
      imageUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9',
      price: '\$65.000',
      originalPrice: '\$98.000',
      discount: '-30%',
      discountColor: Color(0xFFEC4899),
      rating: '4.7',
      reviews: '156',
      time: '3 días',
      emoji: '💄',
    ),
    _PromoCard(
      title: 'iPhone 15 Pro — Oferta',
      store: 'Tech Zone',
      category: 'Tecnología',
      categoryColor: Color(0xFF6366F1),
      imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9',
      price: '\$3.654.000',
      originalPrice: '\$4.300.000',
      discount: '-15%',
      discountColor: Color(0xFF6366F1),
      rating: '4.6',
      reviews: '263',
      time: '1 año',
      emoji: '📱',
    ),
    _PromoCard(
      title: 'Colección Primavera 2025',
      store: 'Trend Studio',
      category: 'Moda',
      categoryColor: Color(0xFFF59E0B),
      imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050',
      price: '\$97.500',
      originalPrice: '\$130.000',
      discount: '-25%',
      discountColor: Color(0xFFF59E0B),
      rating: '4.4',
      reviews: '67',
      time: '4 min',
      emoji: '👗',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bannerFade = CurvedAnimation(parent: _bannerCtrl, curve: Curves.easeOut);
    _bannerCtrl.forward();

    // Simular countdown
    Future.delayed(const Duration(seconds: 1), _tickTimer);
  }

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
    Future.delayed(const Duration(seconds: 1), _tickTimer);
  }

  @override
  void dispose() {
    _bannerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildHeroBanner()),
            SliverToBoxAdapter(child: _buildFlashDealsSection()),
            SliverToBoxAdapter(child: _buildNearbySection()),
            SliverToBoxAdapter(child: _buildAllPromosHeader()),
            _buildPromosGrid(),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
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
              children: const [
                Row(
                  children: [
                    Icon(Icons.location_on, color: _primary, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Bogotá, Colombia',
                      style: TextStyle(
                        fontSize: 12,
                        color: _primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Buenos días',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
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
            child: const Center(
              child: Text('JD', style: TextStyle(color: Colors.white)),
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

  Widget _buildFlashDealsSection() {
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
            itemCount: _flashDeals.length,
            itemBuilder: (_, i) => _buildFlashDealCard(_flashDeals[i]),
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

  void _openPromotionDetails() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, AppRoutes.promotionDetails);
  }

  // ── Card NUEVA estilo imagen ─────────────────────────────────────────────

  Widget _buildFlashDealCard(_FlashDeal deal) {
    return GestureDetector(
      onTap: _openPromotionDetails,
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
                  Image.network(
                    _getImageByCategory(deal.category),
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                  // 🔴 DESCUENTO
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
                        deal.discount,
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
                    deal.title,
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
                    deal.store,
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
                        deal.price,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        deal.originalPrice,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB0B5CC),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
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
                        deal.rating,
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

  Widget _buildNearbySection() {
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
            itemCount: _nearbyStores.length,
            itemBuilder: (_, i) => _buildNearbyCard(_nearbyStores[i]),
          ),
        ),
      ],
    );
  }

  // ── Card moderna con imagen ───────────────────────────────────────────────

  Widget _buildNearbyCard(_NearbyStore store) {
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
                Image.network(
                  _getStoreImage(store.name),
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
                      store.distance,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // ⭐ RATING (overlay)
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
                        const Icon(Icons.star, size: 10, color: Colors.yellow),
                        const SizedBox(width: 3),
                        Text(
                          store.rating,
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
                  store.name,
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
                      store.category,
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
                      store.time,
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

  // ── Imágenes dinámicas ────────────────────────────────────────────────────

  String _getStoreImage(String name) {
    switch (name) {
      case 'Burger House':
        return 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd';
      case 'Coffee Lab':
        return 'https://images.unsplash.com/photo-1509042239860-f550ce710b93';
      case 'SportMax':
        return 'https://images.unsplash.com/photo-1517649763962-0c623066013b';
      default:
        return 'https://images.unsplash.com/photo-1492724441997-5dc865305da7';
    }
  }

  Widget _buildPromoGridCard(_PromoCard p) {
    return GestureDetector(
      onTap: _openPromotionDetails,
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
                    p.imageUrl != null
                        ? Image.network(p.imageUrl!, fit: BoxFit.cover)
                        : Container(
                            color: p.categoryColor.withValues(alpha: 0.15),
                            child: Center(
                              child: Text(
                                p.emoji,
                                style: const TextStyle(fontSize: 50),
                              ),
                            ),
                          ),

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
                          p.discount,
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
                          p.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: p.isFavorite
                              ? Colors.red
                              : const Color(0xFFB0B5CC),
                          size: 18,
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
                      color: p.categoryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      p.category,
                      style: TextStyle(
                        color: p.categoryColor,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // 🔥 TÍTULO
                  Text(
                    p.title,
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
                    p.store,
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
                        p.price,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        p.originalPrice,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFB0B5CC),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
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
                        p.rating,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${p.reviews})',
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
                        p.time,
                        style: const TextStyle(
                          fontSize: 10,
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
      ),
    );
  }

  /// TODAS LAS PROMO
  Widget _buildAllPromosHeader() {
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

  SliverPadding _buildPromosGrid() {
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
          (context, index) => _buildPromoGridCard(_promos[index]),
          childCount: _promos.length,
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
