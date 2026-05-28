// Importaciones necesarias para la pantalla de exploración de promociones
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart'; // UI framework principal
import 'package:flutter/services.dart'; // Para feedback háptico y servicios del sistema
import '../../../../../Core/Routes/app_routes.dart'; // Definición de rutas de navegación
import '../../../../../Core/di/app_scope.dart'; // Para acceso a servicios globales ()
import '../../../../../features/promotions/domain/entities/promocion.dart'; // Entity de promociones
import '../../../../../features/promotions/domain/entities/supermercado.dart'; // Entity de supermercados

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS (Importados arriba)
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA DE EXPLORACIÓN DE PROMOCIONES
// ─────────────────────────────────────────────────────────────────────────────
// Pantalla principal donde los usuarios pueden:
// - Explorar promociones disponibles
// - Ver flash deals con cuenta regresiva
// - Descubrir tiendas cercanas
// - Filtrar y ordenar promociones
// - Acceder a detalles de promociones individuales

/// Pantalla principal de exploración de promociones
/// Muestra un feed con diferentes secciones de promociones organizadas
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin {
  // Colores constantes de la aplicación
  static const Color _primary = Color(
    0xFFFF4D2E,
  ); // Color primario rojo/naranja
  static const Color _darkBg = Color(0xFF1A1F2E); // Fondo oscuro para elementos

  // Variables de estado de UI
  int _selectedTab =
      1; // Tab activa en navegación inferior (0=Inicio, 1=Explorar, 2=Favoritos, 3=Perfil)
  int _selectedSort = 0; // Índice de opción de ordenamiento seleccionada
  bool _gridView =
      false; // Control de vista: false=grid 2 columnas, true=lista 1 columna

  // Variables para countdown (cuenta regresiva) de flash deals
  // Valores simulados para demo: 00:46:23
  int _hours = 0, _minutes = 46, _seconds = 23;

  // Controladores de animación para el banner hero
  late final AnimationController
  _bannerCtrl; // Controlador principal de animación
  late final Animation<double>
  _bannerFade; // Animación de fade-in para el banner

  // Opciones de ordenamiento disponibles para las promociones
  final List<String> _sortOptions = ['Relevancia', 'Precio', 'Rating', 'Cerca'];

  @override
  void initState() {
    super.initState();
    // Inicializar controlador de animación para el banner hero
    _bannerCtrl = AnimationController(
      vsync: this, // Sincronizar con el ticker provider
      duration: const Duration(
        milliseconds: 600,
      ), // Duración de la animación: 600ms
    );
    // Crear animación de fade-in con curva suave
    _bannerFade = CurvedAnimation(parent: _bannerCtrl, curve: Curves.easeOut);
    _bannerCtrl.forward(); // Iniciar animación inmediatamente

    // Función interna para actualizar el countdown de flash deals
    void _tickTimer() {
      if (!mounted) return; // Verificar que el widget todavía está montado
      setState(() {
        // Lógica de decremento de tiempo para countdown
        if (_seconds > 0) {
          _seconds--; // Decrementar segundos
        } else if (_minutes > 0) {
          _minutes--; // Decrementar minutos
          _seconds = 59; // Reiniciar segundos
        } else if (_hours > 0) {
          _hours--; // Decrementar horas
          _minutes = 59; // Reiniciar minutos
          _seconds = 59; // Reiniciar segundos
        }
      });
    }

    // Iniciar el timer después de 1 segundo y luego cada segundo
    Future.delayed(const Duration(seconds: 1), _tickTimer);
  }

  @override
  void dispose() {
    _bannerCtrl.dispose(); // Liberar recursos del controlador de animación
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usar AnimatedBuilder para reconstruir UI cuando cambia el promoService
    return Consumer<PromoService>(
      builder: (context, promoService, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA), // Fondo gris claro
          body: CustomScrollView(
            // Slivers para mejor performance en listas largas
            slivers: [
              // Header con saludo y ubicación del usuario
              SliverToBoxAdapter(child: _buildHeader()),
              // Barra de búsqueda y filtros
              SliverToBoxAdapter(child: _buildSearchBar()),
              // Banner hero con animación
              SliverToBoxAdapter(child: _buildHeroBanner()),
              // Sección de flash deals (solo si hay datos y no hay errores)
              if (promotionsController.isLoaded && promotionsController.loadError == null)
                SliverToBoxAdapter(
                  child: _buildFlashDealsSection(),
                ),
              // Sección de tiendas cercanas (solo si hay datos y no hay errores)
              if (promotionsController.isLoaded && promotionsController.loadError == null)
                SliverToBoxAdapter(child: _buildNearbySection()),
              // Header de todas las promociones con filtros (solo si hay datos y no hay errores)
              if (promotionsController.isLoaded && promotionsController.loadError == null)
                SliverToBoxAdapter(child: _buildAllPromosHeader()),
              // Grid de todas las promociones (solo si hay datos y no hay errores)
              if (promotionsController.isLoaded && promotionsController.loadError == null)
                _buildPromosGrid(),
              // Estado de carga (solo si está cargando y no hay errores)
              if (!promotionsController.isLoaded && promotionsController.loadError == null)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
              // Estado de error (solo si hay error de carga)
              if (promotionsController.loadError != null)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icono de error
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        // Mensaje de error
                        Text(
                          'Error al cargar datos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Detalle del error
                        Text(
                          promotionsController.loadError!,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Botón para reintentar carga
                        ElevatedButton(
                          onPressed: () =>
                              promotionsController.reinitialize(), // Reintentar inicialización
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
              // Espacio al final del scroll
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
          // Navegación inferior
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  /// Construye el header superior con saludo personalizado y ubicación
  /// Muestra: ciudad, saludo personalizado, notificaciones y avatar del usuario
  Widget _buildHeader() {
    // Obtener usuario actual (para demo: primer usuario de la lista)
    final currentUser = usersController.getUsersSync().isNotEmpty
        ? usersController.getUsersSync().first
        : null;
    final userCity =
        currentUser?.ciudad ?? 'Bogotá'; // Ciudad del usuario o fallback

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top:
            MediaQuery.of(context).padding.top +
            10, // Respetar área de status bar
        left: 20,
        right: 20,
        bottom: 10,
      ),
      child: Row(
        children: [
          // Sección izquierda: saludo y ubicación
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila de ubicación
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
                // Saludo personalizado
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

          // Botón de notificaciones con badge indicador
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F7), // Fondo gris claro
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Icono de notificaciones
                const Center(child: Icon(Icons.notifications_none, size: 22)),
                // Badge indicador de notificaciones no leídas
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _primary, // Badge rojo/naranja
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Avatar del usuario con iniciales
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _darkBg, // Fondo oscuro para contraste
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                // Generar iniciales del nombre del usuario
                currentUser != null
                    ? currentUser.nombre
                          .split(' ') // Dividir nombre en palabras
                          .map(
                            (name) => name[0],
                          ) // Tomar primera letra de cada palabra
                          .take(2) // Tomar solo las primeras 2 letras
                          .join() // Unir las letras
                          .toUpperCase() // Convertir a mayúsculas
                    : 'U', // Fallback 'U' si no hay usuario
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

  // ── SECCIÓN DE BARRA DE BÚSQUEDA ────────────────────────────────────────────

  /// Construye la barra de búsqueda y filtros
  /// Incluye: campo de búsqueda placeholder y botón de filtros
  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          // Campo de búsqueda (placeholder)
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F7), // Fondo gris claro
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 12),
                  Icon(
                    Icons.search,
                    color: Color(0xFFB0B5CC),
                  ), // Icono de búsqueda
                  SizedBox(width: 8),
                  Text(
                    'Buscar tiendas, productos...', // Texto placeholder
                    style: TextStyle(color: Color(0xFFB0B5CC), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Botón de filtros
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _primary, // Fondo primario rojo/naranja
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.tune,
              color: Colors.white,
            ), // Icono de ajustes/filtros
          ),
        ],
      ),
    );
  }

  // ── SECCIÓN DE BANNER HERO ───────────────────────────────────────────────────

  /// Construye el banner hero promocional con animación fade-in
  /// Muestra: imagen de fondo, overlay con texto, badge y botón de acción
  Widget _buildHeroBanner() {
    return FadeTransition(
      opacity: _bannerFade, // Animación de fade-in configurada en initState
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          image: const DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1553621042-f6e147245754', // Imagen de sushi
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Overlay gradiente para mejorar legibilidad del texto
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.0), // Transparente arriba
                Colors.black.withOpacity(0.45), // Semi-transparente abajo
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge "Tiempo limitado"
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6), // Azul para badge
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

                // Título principal del banner
                const Text(
                  'Sushi Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                // Descripción de la oferta
                const Text(
                  '30% OFF — 20 piezas por \$42.000',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const Spacer(), // Empujar contenido hacia arriba
                // Botón de acción "Pedir ahora"
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6), // Azul para botón
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

  // ── SECCIÓN DE FLASH DEALS ───────────────────────────────────────────────────

  /// Construye la sección de ofertas flash con countdown
  /// Muestra: header con countdown y lista horizontal de promociones
  Widget _buildFlashDealsSection() {
    // Obtener flash deals del service (limitado a 5 para performance)
    final flashDeals = promotionsController.getFlashDealsSync(limit: 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con título, countdown y enlace "Ver todos"
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis
                      .horizontal, // Permitir scroll si el contenido es muy largo
                  child: Row(
                    children: [
                      // Icono de flash/relámpago
                      const Icon(Icons.bolt_rounded, color: _primary, size: 20),
                      const SizedBox(width: 6),
                      // Título "Flash Deals"
                      const Text(
                        'Flash Deals',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1F2E), // Gris oscuro
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Texto "Termina en"
                      const Text(
                        'Termina en',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A8FA8), // Gris claro
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Countdown: horas
                      _timerChip(_hours.toString().padLeft(2, '0')),
                      const SizedBox(width: 3),
                      const Text(':'), // Separador
                      const SizedBox(width: 3),
                      // Countdown: minutos
                      _timerChip(_minutes.toString().padLeft(2, '0')),
                      const SizedBox(width: 3),
                      const Text(':'), // Separador
                      const SizedBox(width: 3),
                      // Countdown: segundos
                      _timerChip(_seconds.toString().padLeft(2, '0')),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Enlace "Ver todos >"
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

        // Lista horizontal de flash deals
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: flashDeals.length,
            itemBuilder: (_, i) => _buildFlashDealCard(
              flashDeals[i],
            ), // Construir cada card
          ),
        ),
      ],
    );
  }

  // ── CHIP DE TIMER PARA COUNTDOWN ─────────────────────────────────────────────

  /// Construye un chip individual para mostrar valores del countdown
  /// Parámetro: val - valor numérico formateado (ej: "23", "45", "12")
  Widget _timerChip(String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _darkBg, // Fondo oscuro para contraste
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        val,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          fontFeatures: [
            FontFeature.tabularFigures(),
          ], // Números monoespaciados
        ),
      ),
    );
  }

  // ── MÉTODOS DE NAVEGACIÓN ─────────────────────────────────────────────────────

  /// Navega a la pantalla de detalles de una promoción
  /// Parámetro: promoCode - código único de la promoción a mostrar
  void _openPromotionDetails(String promoCode) {
    HapticFeedback.lightImpact(); // Feedback háptico al tocar
    Navigator.pushNamed(
      context,
      AppRoutes.promotionDetails, // Ruta definida en app_routes.dart
      arguments: promoCode, // Pasar código como argumento
    );
  }

  /// Construye imágenes de promociones con múltiples fallbacks
  /// Intenta: imagen cacheada → imagen de red → emoji fallback
  /// Parámetros:
  /// - promo: objeto promoción con datos de imagen
  /// - emoji: emoji a usar como fallback
  /// - height: altura de la imagen
  Widget _buildPromoImage(Promocion promo, String? emoji, double height) {
    // 1. Intentar usar imagen cacheada en memoria
    final imageBytes = promotionsController.getCachedImageBytes(promo.codigo);

    if (imageBytes != null) {
      return Image.memory(
        imageBytes,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildImageFallback(emoji, height), // Fallback si falla carga
      );
    }

    // 2. Intentar cargar imagen desde red si hay URL
    if (promo.foto != null && promo.foto!.isNotEmpty) {
      return Image.network(
        promo.foto!,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildImageFallback(emoji, height), // Fallback si falla red
      );
    }

    // 3. Fallback final: emoji con fondo gris
    return _buildImageFallback(emoji, height);
  }

  /// Construye el fallback de imagen cuando no hay imagen disponible
  /// Muestra emoji centrado en fondo gris
  /// Parámetros:
  /// - emoji: emoji a mostrar (o null para fallback)
  /// - height: altura del contenedor
  Widget _buildImageFallback(String? emoji, double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: Colors.grey[200], // Fondo gris claro
      child: Center(
        child: Text(
          emoji ?? '📦', // Emoji proporcionado o fallback a caja
          style: TextStyle(
            fontSize: height * 0.4,
          ), // Tamaño proporcional a la altura
        ),
      ),
    );
  }

  // ── CARD DE FLASH DEAL ─────────────────────────────────────────────────────

  /// Construye una card individual para flash deal
  /// Muestra: imagen con badge de descuento, título, tienda, precio y rating
  Widget _buildFlashDealCard(Promocion promo) {
    // Obtener datos relacionados del service
    final supermercado = promotionsController.getSupermercadoSync(promo.idSupermercado);
    final categoria = catalogController.getCategoriaByIdSync(promo.idCategoria);
    final categoriaStyle = catalogController.getCategoriaStyleSync(promo.idCategoria);
    final precioConDescuento = promotionsController.getPrecioConDescuento(promo);
    final rating = promotionsController.getPromocionRatingSync(promo.codigo);
    final discount = promo.descuento != null ? '-${promo.descuento}%' : '';

    return GestureDetector(
      onTap: () => _openPromotionDetails(promo.codigo), // Navegar a detalles
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06), // Sombra sutil
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de imagen con overlay
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Stack(
                children: [
                  // Imagen de la promoción (con fallbacks)
                  _buildPromoImage(promo, categoriaStyle['emoji'], 100),

                  // Badge de descuento (solo si hay descuento)
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
                          color: Colors.red, // Fondo rojo para descuento
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

            // Sección de información de la promoción
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de la promoción
                  Text(
                    promo.titulo,
                    maxLines: 1,
                    overflow: TextOverflow
                        .ellipsis, // Cortar con puntos si es muy largo
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F2E), // Gris oscuro
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Nombre de la tienda/supermercado
                  Text(
                    supermercado?.nombre ??
                        'Tienda', // Fallback si no hay tienda
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8A8FA8), // Gris claro
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Sección de precios (con descuento y precio original)
                  Row(
                    children: [
                      // Precio con descuento (resaltado)
                      Text(
                        '\$${precioConDescuento.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.red, // Rojo para precio especial
                        ),
                      ),
                      // Precio original tachado (solo si hay descuento)
                      if (promo.descuento != null && promo.descuento! > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '\$${promo.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFB0B5CC), // Gris claro
                            decoration:
                                TextDecoration.lineThrough, // Texto tachado
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Rating con estrella
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 12,
                        color: Color(0xFFFFB703), // Amarillo dorado
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1), // Rating con 1 decimal
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

  // ── UTILIDAD DE IMÁGENES POR CATEGORÍA ──────────────────────────────────────────

  /// Obtiene URL de imagen placeholder según categoría
  /// Usado para fallback cuando no hay imagen específica
  /// Parámetro: category - nombre de la categoría
  String _getImageByCategory(String category) {
    switch (category) {
      case 'Café':
        return 'https://images.unsplash.com/photo-1509042239860-f550ce710b93'; // Imagen de café
      case 'Salud':
        return 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd'; // Imagen de salud/belleza
      case 'Bebidas':
        return 'https://images.unsplash.com/photo-1551024506-0bccd828d307'; // Imagen de bebidas
      default:
        return 'https://images.unsplash.com/photo-1490645935967-10de6ba17061'; // Imagen genérica
    }
  }

  // ── SECCIÓN DE TIENDAS CERCANAS ────────────────────────────────────────────────

  /// Construye la sección de tiendas cercanas con cards horizontales
  /// Muestra: header con enlace a mapa y lista de tiendas con promociones
  Widget _buildNearbySection() {
    // Obtener tiendas cercanas del service (limitado a 5 para performance)
    final nearbyStores = promotionsController.getNearbyStoresSync(limit: 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con título y enlace "Ver mapa"
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
                  color: Color(0xFF1A1F2E), // Gris oscuro
                ),
              ),
              const Spacer(), // Empujar enlace hacia la derecha
              GestureDetector(
                onTap: () {}, // Sin implementar: abrir mapa
                child: const Text(
                  'Ver mapa >',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _primary, // Color primario para acción
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista horizontal de tiendas cercanas
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: nearbyStores.length,
            itemBuilder: (_, i) => _buildNearbyCard(
              nearbyStores[i],
            ), // Construir cada card
          ),
        ),
      ],
    );
  }

  // ── CARD DE TIENDA CERCANA ────────────────────────────────────────────────────

  /// Construye una card individual para tienda cercana
  /// Muestra: imagen, distancia, rating, nombre y cantidad de promociones
  /// Parámetros:
  /// - storeData: mapa con datos de tienda, promociones, distancia y tiempo
  /// - promoService: servicio para obtener datos adicionales
  Widget _buildNearbyCard(
    Map<String, dynamic> storeData
  ) {
    final supermercado =
        storeData['supermercado'] as Supermercado; // Datos de la tienda
    final promociones =
        storeData['promociones'] as List<Promocion>; // Lista de promociones
    final distancia = storeData['distancia'] as String; // Distancia formateada
    final tiempo = storeData['tiempo'] as String; // Tiempo estimado

    // Calcular rating promedio de todas las promociones de la tienda
    double avgRating = 0;
    if (promociones.isNotEmpty) {
      final totalRating = promociones
          .map((p) => promotionsController.getPromocionRatingSync(p.codigo))
          .reduce((a, b) => a + b); // Sumar todos los ratings
      avgRating = totalRating / promociones.length; // Calcular promedio
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

  Widget _buildPromoGridCard(Promocion promo) {
    final supermercado = promotionsController.getSupermercadoSync(promo.idSupermercado);
    final categoria = catalogController.getCategoriaByIdSync(promo.idCategoria);
    final categoriaStyle = catalogController.getCategoriaStyleSync(promo.idCategoria);
    final precioConDescuento = promotionsController.getPrecioConDescuento(promo);
    final rating = promotionsController.getPromocionRatingSync(promo.codigo);
    final reviewsCount = commentsController.getComentariosByPromocionSync(promo.codigo).length;
    final urgency = promotionsController.getPromocionUrgency(promo);

    // For demo, use first user as current user
    final currentUser = usersController.getUsersSync().isNotEmpty
        ? usersController.getUsersSync().first.id
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
                          interactionsController.toggleFavorito(
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
                            interactionsController.isFavoritoSync(currentUser, promo.codigo)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                interactionsController.isFavoritoSync(
                                  currentUser,
                                  promo.codigo,
                                )
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

  // ── HEADER DE TODAS LAS PROMOCIONES ────────────────────────────────────────────

  /// Construye el header de la sección de todas las promociones
  /// Incluye: título, dropdown de ordenamiento y toggle de vista
  Widget _buildAllPromosHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
      child: Row(
        children: [
          // Icono de ofertas
          const Icon(Icons.local_offer_rounded, color: _primary, size: 18),
          const SizedBox(width: 6),
          // Título "Todas las promociones"
          const Expanded(
            child: Text(
              'Todas las promociones',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1F2E), // Gris oscuro
              ),
            ),
          ),
          // Dropdown de ordenamiento
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedSort, // Opción actualmente seleccionada
              isDense: true, // Hacer el dropdown más compacto
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
                setState(() => _selectedSort = v); // Actualizar selección
              },
            ),
          ),
          const SizedBox(width: 8),
          // Toggle de vista (grid vs lista)
          GestureDetector(
            onTap: () =>
                setState(() => _gridView = !_gridView), // Cambiar vista
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFE3E6EF),
                ), // Borde gris
              ),
              child: Icon(
                _gridView
                    ? Icons.grid_view_rounded
                    : Icons.view_agenda_rounded, // Icono según vista
                size: 18,
                color: const Color(0xFF6B7280), // Gris medio
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── GRID DE TODAS LAS PROMOCIONES ──────────────────────────────────────────────

  /// Construye el grid de todas las promociones aprobadas
  /// Adapta layout según: tamaño de pantalla y modo de vista
  SliverPadding _buildPromosGrid() {
    // Obtener promociones aprobadas del service
    final promociones = promotionsController.getActivePromotionsSync();
    // Medir ancho de pantalla para layouts responsivos
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 400; // Pantallas estrechas

    // Configurar grid según modo de vista
    final crossAxisCount = _gridView
        ? 1
        : 2; // 1 columna (lista) o 2 columnas (grid)
    final childAspectRatio = _gridView
        ? (isNarrow ? 2.05 : 2.25) // Aspect ratio para vista lista
        : (isNarrow ? 0.52 : 0.56); // Aspect ratio para vista grid

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12, // Espacio vertical entre cards
          crossAxisSpacing: 10, // Espacio horizontal entre cards
          childAspectRatio: childAspectRatio, // Proporción de cada card
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildPromoGridCard(
            promociones[index],
          ), // Construir cada card
          childCount: promociones.length,
        ),
      ),
    );
  }

  // ── NAVEGACIÓN INFERIOR ───────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// CLASES AUXILIARES INTERNAS
// ─────────────────────────────────────────────────────────────────────────────

/// Modelo auxiliar para representar un tab de navegación
/// Contiene icono y etiqueta para cada opción del menú inferior
class _NavTab {
  final IconData icon; // Icono a mostrar en el tab
  final String label; // Etiqueta descriptiva del tab
  const _NavTab({required this.icon, required this.label});
}
