// Importaciones necesarias para la pantalla de mapa principal
import 'package:flutter/material.dart';           // UI framework principal
import 'package:flutter/services.dart';           // Para feedback háptico y estilo de sistema
import 'package:flutter_map/flutter_map.dart';     // Biblioteca para mapas interactivos
import 'package:latlong2/latlong.dart' show LatLng; // Para coordenadas geográficas
import '../Core/Routes/app_routes.dart';         // Definición de rutas de navegación
import '../main.dart';                            // Para acceso a servicios globales

/// Pantalla principal de mapa con promociones geolocalizadas
/// Muestra mapa interactivo con marcadores de promociones y controles de navegación
class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen>
    with TickerProviderStateMixin {
  // Colores constantes de la aplicación
  static const Color _primary = Color(0xFFFF4D2E);    // Color primario rojo/naranja
  static const Color _darkBg = Color(0xFF1A1F2E);     // Fondo oscuro para elementos
  
  // Ubicación inicial del mapa (Bogotá, Colombia)
  static const LatLng _defaultCenter = LatLng(4.7110, -74.0721);

  // Variables de estado de UI
  int _selectedTab = 0;                    // Tab activa en navegación inferior
  double _zoomLevel = 14;                  // Nivel de zoom actual del mapa
  int _selectedPromo = 0;                  // ID de promoción seleccionada
  final MapController _mapController = MapController(); // Controlador del mapa

  // Controladores de animación para el bottom sheet
  late final AnimationController _cardController;  // Controlador principal
  late final Animation<Offset> _cardSlide;        // Animación de deslizamiento
  late final Animation<double> _cardFade;         // Animación de opacidad

  // Lista de promociones de ejemplo para mostrar en el mapa
  // Cada promo contiene: ID, etiqueta de descuento, color y coordenadas
  final List<_MapPromo> _promos = const [
    _MapPromo(
      id: 0,
      label: '-50%',
      color: Color(0xFFE91E8C),  // Rosa
      latLng: LatLng(4.7162, -74.0703),  // Coordenada Bogotá norte
    ),
    _MapPromo(
      id: 1,
      label: '50%',
      color: Color(0xFFFF4D2E),  // Rojo primario
      latLng: LatLng(4.7093, -74.0757),  // Coordenada Bogotá centro
    ),
    _MapPromo(
      id: 2,
      label: '-40%',
      color: Color(0xFF3B82F6),  // Azul
      latLng: LatLng(4.7058, -74.0682),  // Coordenada Bogotá oeste
    ),
    _MapPromo(
      id: 3,
      label: '-33%',
      color: Color(0xFF10B981),  // Verde
      latLng: LatLng(4.7018, -74.0801),  // Coordenada Bogotá sur
    ),
    _MapPromo(
      id: 4,
      label: '-33%',
      color: Color(0xFF10B981),  // Verde
      latLng: LatLng(4.6979, -74.0648),  // Coordenada Bogotá este
    ),
  ];

  // Detalles completos de cada promoción para el bottom sheet
  // Contiene información visual y descriptiva de cada oferta
  final List<_PromoDetail> _promoDetails = const [
    _PromoDetail(
      category: 'Comida',
      categoryColor: Color(0xFFFF4D2E),  // Rojo para comida
      discount: '-50%',
      title: '2x1 en Hamburguesa',
      store: 'Burger House',
      emoji: '🍔',
    ),
    _PromoDetail(
      category: 'Moda',
      categoryColor: Color(0xFFE91E8C),  // Rosa para moda
      discount: '50%',
      title: 'Descuento en ropa',
      store: 'Fashion Store',
      emoji: '👕',
    ),
    _PromoDetail(
      category: 'Tech',
      categoryColor: Color(0xFF3B82F6),  // Azul para tecnología
      discount: '-40%',
      title: 'Accesorios Apple',
      store: 'iZone Store',
      emoji: '📱',
    ),
    _PromoDetail(
      category: 'Salud',
      categoryColor: Color(0xFF10B981),  // Verde para salud
      discount: '-33%',
      title: 'Vitaminas y suplementos',
      store: 'VitaShop',
      emoji: '💊',
    ),
    _PromoDetail(
      category: 'Salud',
      categoryColor: Color(0xFF10B981),  // Verde para salud
      discount: '-33%',
      title: 'Consulta médica',
      store: 'Clínica Norte',
      emoji: '🏥',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar controlador de animación para el bottom sheet
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),  // Duración de la animación
    );
    // Configurar animación de deslizamiento (de abajo hacia arriba)
    _cardSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
        );
    // Configurar animación de opacidad (fade in)
    _cardFade = CurvedAnimation(parent: _cardController, curve: Curves.easeOut);
    // Iniciar animación al cargar la pantalla
    _cardController.forward();
  }

  @override
  void dispose() {
    // Liberar recursos del controlador de animación
    _cardController.dispose();
    super.dispose();
  }

  /// Selecciona una promoción y muestra su detalle en el bottom sheet
  /// Actualiza el estado y reproduce la animación del card
  /// Parámetro: id - ID de la promoción a seleccionar
  void _selectPromo(int id) {
    setState(() => _selectedPromo = id);  // Actualizar promoción seleccionada
    _cardController.forward(from: 0);      // Reproducir animación desde el inicio
    HapticFeedback.lightImpact();          // Feedback háptico ligero
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,  // Establecer estilo de sistema (status bar oscuro)
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // ── Mapa real OpenStreetMap (gratis, sin API key) ──
            _buildOsmMap(),

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
        // Navegación inferior
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ── SECCIÓN DE MAPA ─────────────────────────────────────────────────────────────

  /// Construye el mapa interactivo con OpenStreetMap
  /// Muestra tiles de mapa, marcadores de promociones y ubicación del usuario
  Widget _buildOsmMap() {
    return Positioned.fill(
      child: FlutterMap(
        mapController: _mapController,  // Controlador para manipular el mapa
        options: MapOptions(
          initialCenter: _defaultCenter,  // Centro inicial (Bogotá)
          initialZoom: _zoomLevel,       // Nivel de zoom inicial
          minZoom: 5,                   // Zoom mínimo permitido
          maxZoom: 19,                  // Zoom máximo permitido
        ),
        children: [
          // Capa de tiles del mapa (OpenStreetMap)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.promomania.app',  // Identificador de la app
          ),
          // Capa de marcadores de promociones
          MarkerLayer(markers: _buildPromoMarkers()),
          // Capa con marcador de ubicación del usuario
          MarkerLayer(markers: [_buildUserPin()]),
        ],
      ),
    );
  }

  /// Construye la lista de marcadores de promociones para el mapa
  /// Cada marcador es interactivo y muestra animación al ser seleccionado
  List<Marker> _buildPromoMarkers() {
    return _promos.map((p) {
      final isSelected = _selectedPromo == p.id;  // Verificar si está seleccionada
      return Marker(
        point: p.latLng,  // Posición del marcador en el mapa
        width: 86,
        height: 56,
        child: GestureDetector(
          onTap: () {
            _selectPromo(p.id);           // Seleccionar promoción
            _mapController.move(p.latLng, _zoomLevel);  // Centrar mapa en la promoción
          },
          child: AnimatedScale(
            scale: isSelected ? 1.2 : 1.0,  // Escala según selección
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,     // Curva de animación suave
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

  /// Construye el marcador de ubicación del usuario
  /// Muestra un punto azul en el centro del mapa
  Marker _buildUserPin() {
    return Marker(
      point: _defaultCenter,  // Posición del usuario (centro del mapa)
      width: 22,
      height: 22,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6),  // Azul para ubicación del usuario
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),  // Borde blanco
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.4),  // Sombra azul
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  // ── SECCIÓN DE BARRA DE BÚSQUEDA ─────────────────────────────────────────────────────

  /// Construye la barra de búsqueda superior con campo de texto y botón de filtros
  /// Muestra: campo de búsqueda placeholder y botón de capas/filtros
  Widget _buildSearchBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,  // Respetar área de status bar
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
                    color: Colors.black.withOpacity(0.12),  // Sombra suave
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  // Icono de búsqueda
                  const Icon(
                    Icons.search_rounded,
                    color: Color(0xFFB0B5CC),  // Gris claro
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  // Texto placeholder
                  Text(
                    'Buscar promociones cerca...',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Botón de filtros/capas
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _primary,  // Fondo primario
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.4),  // Sombra del color primario
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.layers_rounded,  // Icono de capas/filtros
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ── SECCIÓN DE BADGE DE ZOOM ───────────────────────────────────────────────────────

  /// Construye el indicador de nivel de zoom actual
  /// Muestra el porcentaje de zoom basado en el nivel actual
  Widget _buildZoomBadge() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 72,  // Debajo de la barra de búsqueda
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),  // Sombra muy sutil
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          // Calcular porcentaje de zoom (5-19 rango -> 0-100%)
          'Zoom: ${((_zoomLevel - 5) / 14 * 100).clamp(0, 100).toInt()}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1F2E),  // Gris oscuro
          ),
        ),
      ),
    );
  }

  // ── SECCIÓN DE CONTROLES DE MAPA ─────────────────────────────────────────────────────

  /// Construye los controles de navegación del mapa
  /// Muestra: botón de ubicación actual, zoom in y zoom out
  Widget _buildMapControls() {
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).padding.top + 72,  // Alineado con badge de zoom
      child: Column(
        children: [
          // Botón de ubicación actual (centrar mapa)
          _mapControlBtn(
            icon: Icons.near_me_outlined,
            onTap: () {
              HapticFeedback.lightImpact();
              _mapController.move(_defaultCenter, _zoomLevel);  // Centrar en ubicación
            },
          ),
          const SizedBox(height: 8),
          // Botón de zoom in
          _mapControlBtn(
            icon: Icons.add_rounded,
            onTap: () {
              final nextZoom = (_zoomLevel + 1).clamp(5, 19).toDouble();
              setState(() => _zoomLevel = nextZoom);
              _mapController.move(_mapController.camera.center, _zoomLevel);
            },
          ),
          const SizedBox(height: 8),
          // Botón de zoom out
          _mapControlBtn(
            icon: Icons.remove_rounded,
            onTap: () {
              final nextZoom = (_zoomLevel - 1).clamp(5, 19).toDouble();
              setState(() => _zoomLevel = nextZoom);
              _mapController.move(_mapController.camera.center, _zoomLevel);
            },
          ),
        ],
      ),
    );
  }

  /// Construye un botón individual de control del mapa
  /// Muestra: icono centrado con fondo blanco y sombra
  /// Parámetros:
  /// - icon: icono a mostrar
  /// - onTap: acción al presionar
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
              color: Colors.black.withOpacity(0.1),  // Sombra suave
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1A1F2E), size: 20),  // Icono gris oscuro
      ),
    );
  }

  // ── SECCIÓN DE BOTTOM SHEET DE PROMOCIÓN ───────────────────────────────────────────────

  /// Construye el bottom sheet con detalles de la promoción seleccionada
  /// Muestra: emoji/imagen, información completa y botón de acción
  Widget _buildBottomPromoSheet() {
    final promo = _promoDetails[_selectedPromo];  // Obtener promoción seleccionada
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _cardSlide,  // Animación de deslizamiento
        child: FadeTransition(
          opacity: _cardFade,   // Animación de opacidad
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),  // Sombra pronunciada
                  blurRadius: 24,
                  offset: const Offset(0, -4),  // Sombra hacia arriba
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Emoji / imagen de la promoción
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: promo.categoryColor.withOpacity(0.1),  // Fondo con color de categoría
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
                  // Sección de información
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fila de badges (categoría y descuento)
                        Row(
                          children: [
                            _categoryBadge(promo.category, promo.categoryColor),
                            const SizedBox(width: 8),
                            _discountBadge(promo.discount),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Título de la promoción
                        Text(
                          promo.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1F2E),  // Gris oscuro
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Fila de ubicación
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFFB0B5CC),  // Gris claro
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              promo.store,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF8A8FA8),  // Gris claro
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
                        color: _primary,  // Fondo primario
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.35),  // Sombra del color primario
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,  // Icono de agregar
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

  /// Construye un badge de categoría con color personalizado
  /// Muestra: nombre de categoría con fondo del color correspondiente
  /// Parámetros:
  /// - label: nombre de la categoría
  /// - color: color de la categoría
  Widget _categoryBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),  // Color transparente de la categoría
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

  /// Construye un badge de descuento con color primario
  /// Muestra: porcentaje de descuento con fondo primario y texto blanco
  /// Parámetro: label - texto del descuento (ej: '-50%', '50%')
  Widget _discountBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _primary,  // Fondo primario
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

  // ── SECCIÓN DE NAVEGACIÓN INFERIOR ─────────────────────────────────────────────────────

  /// Construye la barra de navegación inferior con tabs animados
  /// Muestra: 4 tabs principales con iconos y etiquetas
  Widget _buildBottomNav() {
    // Definición de tabs con iconos y etiquetas
    final tabs = [
      _NavTab(icon: Icons.map_rounded, label: 'Inicio'),
      _NavTab(icon: Icons.explore_outlined, label: 'Explorar'),
      _NavTab(icon: Icons.favorite_border_rounded, label: 'Favoritos'),
      _NavTab(icon: Icons.person_outline_rounded, label: 'Perfil'),
    ];
    // Rutas correspondientes a cada tab
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

// ─────────────────────────────────────────────────────────────────────────────
// CLASES AUXILIARES INTERNAS
// ─────────────────────────────────────────────────────────────────────────────

/// Modelo auxiliar para representar una promoción en el mapa
/// Contiene: ID, etiqueta de descuento, color y coordenadas geográficas
class _MapPromo {
  final int id;           // Identificador único
  final String label;     // Etiqueta de descuento (ej: '-50%')
  final Color color;      // Color distintivo para el marcador
  final LatLng latLng;    // Coordenadas geográficas

  const _MapPromo({
    required this.id,
    required this.label,
    required this.color,
    required this.latLng,
  });
}

/// Modelo auxiliar para representar detalles completos de una promoción
/// Contiene información visual y descriptiva para el bottom sheet
class _PromoDetail {
  final String category;       // Categoría de la promoción
  final Color categoryColor;   // Color de la categoría
  final String discount;       // Texto del descuento
  final String title;          // Título descriptivo
  final String store;          // Nombre de la tienda
  final String emoji;          // Emoji representativo

  const _PromoDetail({
    required this.category,
    required this.categoryColor,
    required this.discount,
    required this.title,
    required this.store,
    required this.emoji,
  });
}

/// Modelo auxiliar para representar un tab de navegación
/// Contiene icono y etiqueta para cada opción del menú inferior
class _NavTab {
  final IconData icon;    // Icono a mostrar en el tab
  final String label;    // Etiqueta descriptiva del tab
  const _NavTab({required this.icon, required this.label});
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS PERSONALIZADOS DE MAPA
// ─────────────────────────────────────────────────────────────────────────────

/// Widget personalizado para marcadores de promociones en el mapa
/// Muestra: badge con etiqueta y punta triangular, con animación de selección
class _PromoMarker extends StatelessWidget {
  final String label;      // Etiqueta de descuento
  final Color color;       // Color del marcador
  final bool isSelected;    // Estado de selección

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
        // Badge principal del marcador
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,  // Fondo según selección
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: isSelected ? 0 : 2),  // Borde según selección
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(isSelected ? 0.4 : 0.2),  // Sombra según selección
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,  // Texto según selección
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        // Punta triangular del marcador
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

/// CustomPainter para dibujar la punta triangular del marcador
/// Crea un triángulo invertido que apunta hacia abajo
class _MarkerTipPainter extends CustomPainter {
  final Color color;       // Color de relleno
  final Color borderColor;  // Color del borde

  const _MarkerTipPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // Crear triángulo invertido
    final path = Path()
      ..moveTo(0, 0)                    // Esquina izquierda
      ..lineTo(size.width / 2, size.height)  // Punto inferior central
      ..lineTo(size.width, 0)            // Esquina derecha
      ..close();                         // Cerrar el triángulo
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MarkerTipPainter old) => false;  // No necesita repintado
}
