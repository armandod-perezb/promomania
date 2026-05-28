// Importaciones necesarias para la pantalla de detalles de promoción
import 'dart:async'; // Para manejo de operaciones asíncronas y timers
import 'dart:typed_data'; // Para manejo de datos binarios (imágenes)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart'; // UI framework principal
import 'package:flutter/services.dart'; // Para feedback háptico y servicios del sistema
import '../../../../../Core/di/app_scope.dart'; // Para acceso a servicios globales (promoService, sessionManager)
import '../../../../../features/promotions/domain/entities/promocion.dart'; // Entity de promociones
import '../../../../../features/promotions/domain/entities/promocion_horario.dart'; // Entity horarios
import '../../../../../features/moderation/domain/entities/reporte.dart'; // Entity reportes
import '../../../../../features/comments/domain/entities/comentario.dart'; // Entity comentarios
import '../../../../../features/interactions/domain/entities/valoracion.dart'; // Entity valoraciones
import '../../../../../core/storage/image_storage_service.dart'; // Servicio para manejo de imágenes locales

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS (Importados arriba)
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA DE DETALLE DE PROMOCIÓN
// ─────────────────────────────────────────────────────────────────────────────
// Muestra información completa de una promoción incluyendo:
// - Imágenes y descripción
// - Precios y descuentos
// - Información de la tienda
// - Sistema de valoraciones y comentarios
// - Funcionalidades de favoritos y reportes

class PromoDetailScreen extends StatefulWidget {
  const PromoDetailScreen({super.key});

  @override
  State<PromoDetailScreen> createState() => _PromoDetailScreenState();
}

class _PromoDetailScreenState extends State<PromoDetailScreen>
    with TickerProviderStateMixin {
  // Colores constantes de la aplicación
  static const Color _primary = Color(
    0xFFFF4D2E,
  ); // Color primario rojo/naranja
  static const Color _darkBg = Color(0xFF1A1F2E); // Fondo oscuro para countdown
  static const Color _green = Color(
    0xFF10B981,
  ); // Verde para indicadores de ahorro
  static const Color _lightBg = Color(0xFFF5F6FA); // Fondo claro principal

  // URLs de imágenes placeholder cuando no hay imágenes disponibles
  static const String _heroImageUrl =
      'https://images.unsplash.com/photo-1496747611176-843222e1e57c'; // Imagen hero placeholder
  static const String _storeImageUrl =
      'https://images.unsplash.com/photo-1494438639946-1ebd1d20bf85'; // Logo de tienda placeholder

  // Variables de estado principales
  Promocion? _promo; // Promoción actual que se está mostrando
  List<PromocionHorario> _horarios = []; // Lista de horarios de disponibilidad
  bool _routeDataResolved =
      false; // Control para evitar reprocesar datos de ruta

  // Estados de UI interactiva
  bool _isFavorite = false; // Estado de favorito del usuario actual
  bool _descExpanded = false; // Control para expandir/colapsar descripción

  // Variables para countdown (cuenta regresiva)
  // Inicializado con valores de ejemplo: termina 8 mar 2026 → días, horas, minutos, segundos
  int _days = 0, _hours = 23, _minutes = 57, _seconds = 6;
  Timer? _timer; // Timer para actualizar countdown cada segundo

  // Datos de calificación (estáticos por ahora)
  // Índice 0 = 1 estrella, índice 4 = 5 estrellas
  final List<int> _ratingCounts = [2, 3, 9, 21, 32];

  @override
  void initState() {
    super.initState();
    // Inicializar timer para countdown que se actualiza cada segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
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
        } else if (_days > 0) {
          _days--; // Decrementar días
          _hours = 23; // Reiniciar horas
          _minutes = 59; // Reiniciar minutos
          _seconds = 59; // Reiniciar segundos
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Evitar reprocesar datos si ya se han resuelto
    if (_routeDataResolved) return;
    _routeDataResolved = true;

    // Obtener código de promoción de los argumentos de la ruta
    final args = ModalRoute.of(context)?.settings.arguments;
    final codigo = args is String ? args : null;

    // Intentar obtener promoción por código, si no hay fallback a primera aprobada
    final promoByCode = codigo != null
        ? promotionsController.getPromotionByCodeSync(codigo)
        : null;
    final fallbackPromo = promotionsController.getActivePromotionsSync().isNotEmpty
        ? promotionsController.getActivePromotionsSync().first
        : (promotionsController.getAllPromotionsSync().isNotEmpty
              ? promotionsController.getAllPromotionsSync().first
              : null);

    // Asignar promoción encontrada
    _promo = promoByCode ?? fallbackPromo;
    if (_promo != null) {
      // Cargar datos relacionados con la promoción
      _horarios = promotionsController.getPromocionesHorariosByCodigo(
        _promo!.codigo,
      ); // Horarios de disponibilidad
      _isFavorite = interactionsController.isFavoritoSync(
        _activeUserId,
        _promo!.codigo,
      ); // Estado de favorito del usuario
    }
  }

  @override
  void dispose() {
    // Cancelar timer para evitar memory leaks
    _timer?.cancel();
    super.dispose();
  }

  // Getters para cálculos y datos auxiliares
  int get _totalReviews => _ratingCounts.fold(
    0,
    (a, b) => a + b,
  ); // Total de reseñas sumando todos los ratings
  int get _activeUserId =>
      sessionManager.usuarioActual?.id ??
      1; // ID del usuario activo (fallback a 1)
  int get _nextReporteId =>
      (moderationController.getReportesSync().isNotEmpty
          ? promoService
                .getReportes()
                .last
                .id // Último ID de reporte
          : 0) +
      1; // Siguiente ID disponible

  /// Formatea la lista de horarios como texto legible
  /// Returns: String con formato "Lunes: 9:00 - 18:00 · Martes: 9:00 - 18:00"
  String _horarioTexto() {
    if (_horarios.isEmpty) return 'Horario no especificado';
    return _horarios
        .map((h) => '${h.diaSemana}: ${h.horaInicio} - ${h.horaFin}')
        .join(' · ');
  }

  /// Reporta la promoción actual al sistema
  /// Crea un reporte con estado 'pendiente' para revisión administrativa
  Future<void> _reportarPromocion() async {
    if (_promo == null) return;

    // Crear y agregar reporte al servicio
    moderationController.addReporte(
      Reporte(
        id: _nextReporteId,
        motivo: 'Reporte enviado desde detalle de promoción',
        fecha: DateTime.now().toIso8601String(), // Timestamp actual
        estado: 'pendiente', // Estado inicial para revisión
        idUsuario: _activeUserId, // Usuario que reporta
        codigoPromocion: _promo!.codigo, // Promoción reportada
      ),
    );

    // Verificar que el widget todavía está montado antes de mostrar SnackBar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reporte enviado. Será revisado por el admin.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usar AnimatedBuilder para reconstruir UI cuando cambia el promoService
    return Consumer<PromoService>(
      builder: (context, promoService, child) {
        // Manejo de caso cuando no hay promoción disponible
        if (_promo == null) {
          return const Scaffold(
            body: Center(
              child: Text('No se encontró información de la promoción'),
            ),
          );
        }

        // Configurar estilo de barra de estado para tema claro
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: _lightBg,
            body: Stack(
              children: [
                // Contenido principal scrollable
                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    bottom: 100,
                  ), // Espacio para bottom bar
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroImage(), // Imagen principal con overlay
                      _buildMainInfo(), // Información principal (título, precio, rating)
                      _buildDivider(), // Separador visual
                      _buildCountdown(), // Cuenta regresiva de la promoción
                      _buildDivider(),
                      _buildStats(), // Estadísticas (vistas, likes, etc.)
                      _buildDivider(),
                      _buildDescription(), // Descripción expandible con tags
                      _buildDivider(),
                      _buildStoreSection(), // Información de la tienda
                      _buildDivider(),
                      _buildLocationSection(), // Ubicación y mapa
                      _buildDivider(),
                      _buildReviewsSection(), // Sistema de reseñas y comentarios
                      _buildViewAllReviews(), // Botón para ver todas las reseñas
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                // Barra inferior fija con acciones principales
                _buildBottomBar(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── SECCIÓN DE IMAGEN PRINCIPAL (HERO) ───────────────────────────────────────

  /// Obtiene los bytes de una imagen local de la promoción
  /// Returns: Uint8List con datos de imagen o null si hay error
  Future<Uint8List?> _getHeroImageBytes() async {
    final promoImage = _promo?.foto?.trim();
    if (promoImage == null || promoImage.isEmpty) return null;
    if (promoImage.startsWith('http'))
      return null; // No procesar URLs remotas aquí

    try {
      final imageStorageService = ImageStorageService();
      return await imageStorageService.readImageBytes(promoImage);
    } catch (e) {
      debugPrint('Error obteniendo imagen de promoción: $e');
    }

    return null;
  }

  /// Construye el placeholder para cuando no hay imagen disponible
  /// Muestra un gradiente gris con icono y texto "Sin imagen"
  Widget _buildHeroPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[300]!, Colors.grey[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Sin imagen',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la imagen principal (hero) de la promoción
  /// Soporta tres tipos de imágenes:
  /// 1. Placeholder (sin imagen de promoción)
  /// 2. Imagen remota (URL HTTP)
  /// 3. Imagen local (almacenamiento interno)
  Widget _buildHeroImage() {
    final promoImage = _promo?.foto?.trim() ?? '';
    final hasPromoImage = _promo?.foto?.trim().isNotEmpty ?? false;
    final isRemoteImage = promoImage.startsWith('http');

    return SizedBox(
      height: 290,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Lógica de carga de imagen según tipo
          if (!hasPromoImage)
            // Caso 1: Sin imagen personalizada - usar placeholder
            Image.network(
              _heroImageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            )
          else if (isRemoteImage)
            // Caso 2: Imagen remota - cargar desde URL con manejo de errores
            Image.network(
              promoImage,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return _buildHeroPlaceholder();
              },
            )
          else
            // Caso 3: Imagen local - cargar desde almacenamiento interno
            FutureBuilder<Uint8List?>(
              future: _getHeroImageBytes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Estado de carga
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey[300]!, Colors.grey[400]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasData && snapshot.data != null) {
                  // Imagen cargada exitosamente
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildHeroPlaceholder();
                    },
                  );
                }

                // Error o sin datos - mostrar placeholder
                return _buildHeroPlaceholder();
              },
            ),
          // Overlay gradiente para mejorar legibilidad de botones
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.24), // Más oscuro arriba
                  Colors.black.withValues(alpha: 0.10), // Menos oscuro en medio
                  Colors.black.withValues(alpha: 0.52), // Más oscuro abajo
                ],
              ),
            ),
          ),
          // Botones de acción overlay sobre la imagen
          Positioned(
            top:
                MediaQuery.of(context).padding.top +
                10, // Respetar área de status bar
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón de regreso
                _heroBtn(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context), // Navegar hacia atrás
                ),
                // Botones de acción derecha
                Row(
                  children: [
                    _heroBtn(
                      icon: Icons.share_outlined,
                      onTap: () {},
                    ), // Compartir (sin implementar)
                    const SizedBox(width: 10),
                    // Botón de favoritos con estado dinámico
                    _heroBtn(
                      icon: _isFavorite
                          ? Icons
                                .favorite_rounded // Favorito activo
                          : Icons.favorite_border_rounded, // Favorito inactivo
                      iconColor: _isFavorite
                          ? _primary
                          : Colors.white, // Color según estado
                      onTap: () {
                        // Toggle de estado de favorito
                        interactionsController.toggleFavorito(
                          _activeUserId,
                          _promo!.codigo,
                        );
                        setState(
                          () => _isFavorite = interactionsController.isFavoritoSync(
                            _activeUserId,
                            _promo!.codigo,
                          ),
                        );
                        HapticFeedback.lightImpact(); // Feedback háptico
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Badge de categoría "Moda"
          Positioned(
            bottom: 14,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.9,
                ), // Fondo semitransparente
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Moda',
                style: TextStyle(
                  color: Color(0xFF8B5CF6), // Púrpura para categoría
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

  /// Construye botón reutilizable para el overlay de la imagen hero
  /// Parámetros:
  /// - icon: Icono a mostrar
  /// - iconColor: Color del icono (blanco por defecto)
  /// - onTap: Acción al presionar
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
          color: Colors.black.withOpacity(
            0.35,
          ), // Fondo semitransparente oscuro
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
          ), // Borde sutil
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  // ── SECCIÓN DE INFORMACIÓN PRINCIPAL ────────────────────────────────────────

  /// Construye la sección principal de información de la promoción
  /// Incluye: breadcrumb, título, rating, distancia, tiempo y precio
  Widget _buildMainInfo() {
    final promo = _promo!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb de navegación y categorías
          Row(
            children: const [
              Text(
                'Moda',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8B5CF6), // Púrpura para categoría principal
                ),
              ),
              SizedBox(width: 8),
              Text(
                '•',
                style: TextStyle(color: Color(0xFFD1D5DB)),
              ), // Separador
              SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                size: 13,
                color: Color(0xFF3B82F6),
              ), // Verificación
              SizedBox(width: 4),
              Text(
                'Moda · Ropa casual',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF6B7280),
                ), // Subcategorías
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Título principal de la promoción
          Text(
            promo.titulo,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827), // Gris oscuro para texto
              height: 1.18, // Altura de línea compacta
            ),
          ),
          const SizedBox(height: 14),
          // Fila de métricas: rating, distancia y tiempo
          Row(
            children: [
              // Sección de estrellas de rating
              Row(
                children: List.generate(5, (i) {
                  if (i < 4) {
                    // 4 estrellas completas
                    return const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFBBF24), // Amarillo dorado
                      size: 16,
                    );
                  }
                  // 1 estrella media (4.5 estrellas)
                  return const Icon(
                    Icons.star_half_rounded,
                    color: Color(0xFFFBBF24),
                    size: 16,
                  );
                }),
              ),
              const SizedBox(width: 6),
              // Valor numérico del rating
              const Text(
                '4.4',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              // Número de reseñas
              const Text(
                ' (67 reseñas)',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF8A8FA8)),
              ),
              const SizedBox(width: 8),
              const Text(
                '•',
                style: TextStyle(color: Color(0xFFB0B5CC)),
              ), // Separador
              const SizedBox(width: 8),
              // Icono y distancia
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
              const Text(
                '•',
                style: TextStyle(color: Color(0xFFB0B5CC)),
              ), // Separador
              const SizedBox(width: 8),
              // Icono y tiempo restante
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
          // Sección de precio y descuento
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna principal de precio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila con precio y descuento
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Precio principal en grande
                        Text(
                          '\$${promo.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: _primary, // Color primario rojo/naranja
                          ),
                        ),
                        // Badge de descuento (si aplica)
                        if ((promo.descuento ?? 0) > 0) ...[
                          const SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 4,
                            ), // Alinear con precio
                            child: Text(
                              '${promo.descuento}% OFF',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFB0B5CC), // Gris claro
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Texto de moneda y descripción
                    const Text(
                      'COP · Precio con descuento',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8A8FA8)),
                    ),
                  ],
                ),
              ),
              // Badge de ahorro (lado derecho)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.10), // Fondo verde claro
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _green.withValues(alpha: 0.18), // Borde verde
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

  // ── SECCIÓN DE COUNTDOWN (CUENTA REGRESIVA) ───────────────────────────────

  /// Construye la cuenta regresiva hasta que termina la promoción
  /// Muestra días, horas, minutos y segundos restantes
  Widget _buildCountdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _darkBg, // Fondo oscuro para contraste
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Badge con fecha de finalización
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _primary, // Fondo primario rojo/naranja
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
          const Spacer(), // Empujar unidades hacia la derecha
          // Unidades de tiempo: Días, Horas, Minutos, Segundos
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

  /// Construye una unidad individual del countdown (ej: "15 D")
  /// Parámetros:
  /// - val: Valor numérico (ej: "15")
  /// - label: Etiqueta de tiempo (ej: "D" para días)
  Widget _countdownUnit(String val, String label) {
    return Column(
      children: [
        // Contenedor del valor numérico
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.10,
            ), // Fondo semitransparente
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              fontFeatures: [
                FontFeature.tabularFigures(),
              ], // Números monoespaciados
            ),
          ),
        ),
        const SizedBox(height: 3),
        // Etiqueta debajo del valor
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5), // Semitransparente
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Construye el separador dos puntos (:) entre unidades de tiempo
  Widget _countdownSep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white.withOpacity(
            0.5,
          ), // Semitransparente como las etiquetas
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ── SECCIÓN DE ESTADÍSTICAS ────────────────────────────────────────────────

  /// Construye la sección de estadísticas de la promoción
  /// Muestra: vistas, útiles, guardados y reportes
  Widget _buildStats() {
    final promo = _promo!;
    // Contar reportes para esta promoción
    final reportesCount = promoService
        .getReportesByPromocion(promo.codigo)
        .length;
    // Contar favoritos para esta promoción
    final favoritosCount = promoService.favoritos
        .where((f) => f.codigoPromocion == promo.codigo)
        .length;

    // Definir estadísticas a mostrar
    final stats = [
      _Stat(
        icon: Icons.visibility_outlined,
        value: '${promo.vistas}', // Vistas de la promoción
        label: 'Vistas',
      ),
      _Stat(
        icon: Icons.thumb_up_outlined,
        value: '267',
        label: 'Útil',
      ), // Valoraciones positivas (estático)
      _Stat(
        icon: Icons.favorite_border_rounded,
        value: '$favoritosCount', // Contador dinámico de favoritos
        label: 'Guardados',
      ),
      _Stat(
        icon: Icons.report_outlined,
        value: '$reportesCount',
        label: 'Reportes',
      ), // Contador dinámico
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
                border: Border.all(
                  color: const Color(0xFFF0F1F5),
                ), // Borde gris claro
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03), // Sombra sutil
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icono de la estadística
                  Icon(s.icon, color: const Color(0xFF9CA3AF), size: 20),
                  const SizedBox(height: 8),
                  // Valor numérico
                  Text(
                    s.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827), // Gris oscuro
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Etiqueta descriptiva
                  Text(
                    s.label,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF8A8FA8), // Gris claro
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

  // ── SECCIÓN DE DESCRIPCIÓN ───────────────────────────────────────────────────

  /// Construye la sección de descripción expandible con tags
  /// Incluye: texto completo/preview, botón expandir, tags y botones útil/no útil
  Widget _buildDescription() {
    // Obtener texto de descripción o usar fallback
    final fullText = _promo?.descripcion?.trim().isNotEmpty == true
        ? _promo!.descripcion!.trim()
        : 'Esta promoción no tiene descripción ampliada.';
    const preview = 150; // Límite de caracteres para preview

    // Tags relacionados con la promoción (estáticos por ahora)
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
          // Título de la sección
          const Text(
            'Sobre esta promo',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1F2E), // Gris oscuro
            ),
          ),
          const SizedBox(height: 10),
          // Texto de descripción (completo o preview según estado)
          Text(
            _descExpanded || fullText.length <= preview
                ? fullText // Texto completo si está expandido o es corto
                : '${fullText.substring(0, preview)}...', // Preview con puntos suspensivos
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5A5F72), // Gris medio
              height: 1.6, // Altura de línea para legibilidad
            ),
          ),
          const SizedBox(height: 6),
          // Botón para expandir/colapsar descripción
          GestureDetector(
            onTap: () => setState(() => _descExpanded = !_descExpanded),
            child: Row(
              children: [
                Text(
                  _descExpanded ? 'Ver menos' : 'Ver más',
                  style: const TextStyle(
                    color: _primary, // Color primario para acción
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  _descExpanded
                      ? Icons
                            .keyboard_arrow_up_rounded // Flecha arriba si está expandido
                      : Icons
                            .keyboard_arrow_down_rounded, // Flecha abajo si está colapsado
                  color: _primary,
                  size: 18,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Tags de categorías y características
          Wrap(
            spacing: 8, // Espacio horizontal entre tags
            runSpacing: 8, // Espacio vertical entre líneas de tags
            children: tags.map((t) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA), // Fondo gris claro
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE8EAF0),
                    width: 1,
                  ), // Borde sutil
                ),
                child: Text(
                  t,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5A5F72), // Gris medio
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          // Botones de útil/no útil para la descripción
          Row(
            children: [
              _utilBtn(
                Icons.thumb_up_outlined,
                '¿Fue útil?',
              ), // Botón positivo con texto
              const SizedBox(width: 10),
              _utilBtn(
                Icons.thumb_down_outlined,
                null,
              ), // Botón negativo sin texto
            ],
          ),
        ],
      ),
    );
  }

  /// Construye botón reutilizable para acciones útil/no útil
  /// Parámetros:
  /// - icon: Icono a mostrar (pulgar arriba/abajo)
  /// - label: Texto opcional (solo para botón positivo)
  Widget _utilBtn(IconData icon, String? label) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(), // Feedback háptico al tocar
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA), // Fondo gris claro
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE8EAF0),
            width: 1.2,
          ), // Borde sutil
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF5A5F72),
            ), // Icono gris medio
            if (label != null) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF5A5F72), // Mismo color que el icono
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── SECCIÓN DE INFORMACIÓN DE TIENDA ────────────────────────────────────────

  /// Construye la sección con información del supermercado/tienda
  /// Muestra: logo, nombre, rating, verificación y botón de acción
  Widget _buildStoreSection() {
    final promo = _promo!;
    final supermercado = promotionsController.getSupermercadoSync(promo.idSupermercado);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          const Text(
            'La tienda',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1F2E), // Gris oscuro
            ),
          ),
          const SizedBox(height: 12),
          // Card con información de la tienda
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.04,
                  ), // Sombra muy sutil
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Logo de la tienda con badge de verificación
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Imagen del logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        _storeImageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Badge verde de verificación (esquina inferior derecha)
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: _green, // Fondo verde
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ), // Borde blanco
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
                // Información de la tienda (nombre, ciudad, rating)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre con badge de verificación
                      Row(
                        children: [
                          Text(
                            supermercado?.nombre ?? 'Tienda no disponible',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1F2E), // Gris oscuro
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF3B82F6), // Azul para verificación
                            size: 15,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      // Ciudad y tipo
                      Text(
                        '${supermercado?.ciudad ?? 'Ciudad no disponible'} · Promoción',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF8A8FA8), // Gris claro
                        ),
                      ),
                      const SizedBox(height: 7),
                      // Rating con estrellas
                      FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown, // Escalar si no hay espacio
                        child: Row(
                          children: [
                            // 5 estrellas (4.5 rating)
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < 4
                                      ? Icons
                                            .star_rounded // 4 estrellas completas
                                      : Icons
                                            .star_half_rounded, // 1 estrella media
                                  color: const Color(
                                    0xFFFBBF24,
                                  ), // Amarillo dorado
                                  size: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Valor numérico del rating
                            const Text(
                              '4.4',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1F2E),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Número de reseñas
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
                // Botón de acción "Ver" tienda
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F8), // Fondo gris muy claro
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
                          color: Color(0xFF1F2937), // Gris oscuro
                        ),
                      ),
                      SizedBox(width: 1),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 17,
                        color: Color(0xFF8A8FA8), // Gris claro
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

  // ── SECCIÓN DE UBICACIÓN ─────────────────────────────────────────────────────

  /// Construye la sección de ubicación con información de contacto y mapa
  /// Muestra: dirección, horario, teléfono, mapa placeholder y navegación
  Widget _buildLocationSection() {
    final promo = _promo!;
    final supermercado = promotionsController.getSupermercadoSync(promo.idSupermercado);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila de información de dirección
          _locationRow(
            icon: Icons.location_on_outlined,
            mainText:
                supermercado?.direccion ??
                promo.ubicacion ??
                'Ubicación no especificada', // Fallback si no hay dirección
            subText: supermercado?.ciudad, // Ciudad como subtexto
          ),
          const SizedBox(height: 10),
          // Fila de información de horario
          _locationRow(
            icon: Icons.access_time_rounded,
            mainText: _horarioTexto(), // Horarios formateados
          ),
          const SizedBox(height: 10),
          // Fila de información de teléfono
          _locationRow(
            icon: Icons.phone_outlined,
            mainText:
                '+57 (601) 789-0123', // Teléfono estático (debería ser dinámico)
          ),
          const SizedBox(height: 14),
          // Mapa placeholder con grid y pin
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 130,
              width: double.infinity,
              color: const Color(0xFFE8F0FE), // Fondo azul claro
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Líneas de grid para efecto de mapa
                  CustomPaint(
                    size: const Size(double.infinity, 130),
                    painter: _GridPainter(),
                  ),
                  // Pin de ubicación en el centro
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _primary, // Fondo primario
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withOpacity(
                            0.4,
                          ), // Sombra del mismo color
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
          // Botón de navegación "Cómo llegar"
          GestureDetector(
            onTap: () {}, // Sin implementar
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA), // Fondo gris claro
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE8EAF0),
                  width: 1,
                ), // Borde sutil
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.near_me_outlined, color: _primary, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Cómo llegar — 0.9 km',
                    style: TextStyle(
                      color: _primary, // Color primario para acción
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

  /// Construye una fila de información de ubicación reutilizable
  /// Parámetros:
  /// - icon: Icono a mostrar (ubicación, tiempo, teléfono)
  /// - mainText: Texto principal de la información
  /// - subText: Texto secundario opcional (ciudad, etc.)
  Widget _locationRow({
    required IconData icon,
    required String mainText,
    String? subText,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA), // Fondo gris claro
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF8A8FA8),
            size: 18,
          ), // Icono gris medio
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mainText,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF1A1F2E), // Gris oscuro
                    height: 1.4, // Altura de línea para legibilidad
                  ),
                ),
                if (subText != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A8FA8), // Gris claro
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

  // ── SECCIÓN DE RESEÑAS Y COMENTARIOS ────────────────────────────────────────

  /// Construye la sección completa de reseñas
  /// Incluye: botones like/dislike, formulario de comentarios y lista de reseñas
  Widget _buildReviewsSection() {
    if (_promo == null) return const SizedBox.shrink();

    // Obtener comentarios de esta promoción
    final comentarios = commentsController.getComentariosByPromocionSync(_promo!.codigo);
    final total = comentarios.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección con icono y contador
          Row(
            children: [
              const Icon(Icons.reviews_outlined, color: _primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Reseñas ($total)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1F2E), // Gris oscuro
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Botones de like/dislike para la promoción
          _buildPromotionLikeDislikeButtons(),
          const SizedBox(height: 16),
          // Botón para agregar nuevo comentario
          _buildAddCommentButton(),
          const SizedBox(height: 16),
          // Lista de comentarios existentes
          if (comentarios.isEmpty)
            // Mensaje cuando no hay comentarios
            const Text(
              'No hay reseñas aún. ¡Sé el primero en comentar!',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFAA8880), // Gris azulado
                fontStyle: FontStyle.italic,
              ),
            )
          else
            // Renderizar cada comentario como una card
            ...comentarios.map((c) => _buildCommentCard(c)).toList(),
        ],
      ),
    );
  }

  Widget _buildAddCommentButton() {
    return GestureDetector(
      onTap: _showAddCommentDialog,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.add_comment_outlined, color: _primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Agregar un comentario',
              style: TextStyle(
                color: _primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(Comentario comentario) {
    final usuario = usersController.getUserByIdSync(comentario.idUsuario);
    final userName = usuario?.nombre ?? 'Usuario Anónimo';
    final userInitials = userName
        .split(' ')
        .map((e) => e[0])
        .take(2)
        .join('')
        .toUpperCase();
    final userColor = _getUserAvatarColor(comentario.idUsuario);

    // Format date
    DateTime fecha;
    try {
      fecha = DateTime.parse(comentario.fecha);
    } catch (e) {
      fecha = DateTime.now();
    }

    final now = DateTime.now();
    final difference = now.difference(fecha);
    String timeAgo;

    if (difference.inDays > 0) {
      timeAgo =
          'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      timeAgo =
          'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      timeAgo =
          'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      timeAgo = 'Ahora';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: userColor.withValues(alpha: 0.1),
                child: Text(
                  userInitials,
                  style: TextStyle(
                    color: userColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF1A1F2E),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (usuario?.rol == 'admin')
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: Color(0xFF10B981),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFAA8880),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comentario.contenido,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5A5F72),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionLikeDislikeButtons() {
    if (_promo == null) return const SizedBox.shrink();

    // Get current user's valoracion for this promotion (if any)
    final userValoraciones = interactionsController.getValoracionesByPromocionSync(
      _promo!.codigo,
    );
    final userValoracion = userValoraciones.firstWhere(
      (v) => v.idUsuario == _activeUserId,
      orElse: () =>
          Valoracion(id: -1, tipo: '', idUsuario: -1, codigoPromocion: ''),
    );

    // Count likes and dislikes for this promotion
    final likes = promoService.contarValoracionesPositivas(_promo!.codigo);
    final dislikes = promoService.contarValoracionesNegativas(_promo!.codigo);

    // Check if current user has already rated
    final hasRated = userValoracion.id != -1;
    final isPositive = hasRated && userValoracion.tipo == 'positiva';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Te fue útil esta promoción?',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1F2E),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Like button
              Expanded(
                child: GestureDetector(
                  onTap: () => _toggleValoracion('positiva'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? _primary.withValues(alpha: 0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isPositive ? _primary : const Color(0xFFE8EAF0),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.thumb_up_outlined,
                          size: 20,
                          color: isPositive
                              ? _primary
                              : const Color(0xFF8A8FA8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Útil ($likes)',
                          style: TextStyle(
                            fontSize: 14,
                            color: isPositive
                                ? _primary
                                : const Color(0xFF8A8FA8),
                            fontWeight: isPositive
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Dislike button
              Expanded(
                child: GestureDetector(
                  onTap: () => _toggleValoracion('negativa'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: hasRated && !isPositive
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: hasRated && !isPositive
                            ? Colors.red
                            : const Color(0xFFE8EAF0),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.thumb_down_outlined,
                          size: 20,
                          color: hasRated && !isPositive
                              ? Colors.red
                              : const Color(0xFF8A8FA8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'No útil ($dislikes)',
                          style: TextStyle(
                            fontSize: 14,
                            color: hasRated && !isPositive
                                ? Colors.red
                                : const Color(0xFF8A8FA8),
                            fontWeight: hasRated && !isPositive
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleValoracion(String tipo) {
    if (_promo == null) return;

    final userValoraciones = interactionsController.getValoracionesByPromocionSync(
      _promo!.codigo,
    );
    final existingValoracion = userValoraciones.firstWhere(
      (v) => v.idUsuario == _activeUserId,
      orElse: () =>
          Valoracion(id: -1, tipo: '', idUsuario: -1, codigoPromocion: ''),
    );

    if (existingValoracion.id != -1) {
      // User has already rated, remove existing rating
      interactionsController.deleteValoracion(existingValoracion.id);
    }

    // Add new valoracion
    final newValoracion = Valoracion(
      id: interactionsController.getAllValoracionesSync().isNotEmpty
          ? interactionsController.getAllValoracionesSync().last.id + 1
          : 1,
      tipo: tipo,
      idUsuario: _activeUserId,
      codigoPromocion: _promo!.codigo,
    );

    interactionsController.addValoracion(newValoracion);
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tipo == 'positiva' ? 'Marcado como útil' : 'Marcado como no útil',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showAddCommentDialog() {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Comentario'),
        content: TextField(
          controller: commentController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Escribe tu comentario aquí...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (commentController.text.trim().isNotEmpty && _promo != null) {
                _addComment(commentController.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primary),
            child: const Text(
              'Publicar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _addComment(String contenido) {
    if (_promo == null) return;

    final newComment = Comentario(
      id: commentsController.getComentariosSync().isNotEmpty
          ? commentsController.getComentariosSync().last.id + 1
          : 1,
      contenido: contenido,
      fecha: DateTime.now().toIso8601String(),
      idUsuario: _activeUserId,
      codigoPromocion: _promo!.codigo,
      idCommentReply: null,
    );

    commentsController.addComment(newComment);
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comentario agregado exitosamente')),
    );
  }

  Color _getUserAvatarColor(int userId) {
    final colors = [
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
    ];
    return colors[userId % colors.length];
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
                interactionsController.toggleFavorito(_activeUserId, _promo!.codigo);
                setState(
                  () => _isFavorite = interactionsController.isFavoritoSync(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt_rounded, size: 20),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Activar Promoción',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
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

  /// Construye un divisor visual entre secciones
  Widget _buildDivider() =>
      const Divider(color: Color(0xFFF0F1F5), thickness: 6, height: 6);
}

// ─────────────────────────────────────────────────────────────────────────────
// CLASES AUXILIARES INTERNAS
// ─────────────────────────────────────────────────────────────────────────────

/// Modelo auxiliar para datos de estadísticas
/// Usado para construir las cards de vistas, útiles, guardados, reportes
class _Stat {
  final IconData icon; // Icono a mostrar
  final String value; // Valor numérico como texto
  final String label; // Etiqueta descriptiva

  const _Stat({required this.icon, required this.value, required this.label});
}

/// Custom painter para dibujar grid de mapa placeholder
/// Crea líneas horizontales y verticales para simular un mapa
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFFD0DCF8) // Color azul claro para líneas
      ..strokeWidth = 0.8; // Grosor de línea delgado

    const spacing = 24.0; // Espaciado entre líneas

    // Dibujar líneas verticales
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Dibujar líneas horizontales
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false; // No necesita repintado
}
