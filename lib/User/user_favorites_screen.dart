// Importaciones necesarias para la pantalla de favoritos de usuarios
import 'package:flutter/material.dart';           // UI framework principal
import 'package:flutter/services.dart';           // Para feedback háptico y estilo de sistema
import '../Core/Routes/app_routes.dart';         // Definición de rutas de navegación
import '../main.dart';                            // Para acceso a servicios globales (promoService)
import '../services/promo_service.dart';          // Servicio principal de gestión de promociones
import '../models/promocion.dart';                // Modelo de datos para promociones
import '../models/supermercado.dart';              // Modelo de datos para supermercados

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS (Importados arriba)
// ─────────────────────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA DE FAVORITOS DE USUARIO
// ─────────────────────────────────────────────────────────────────────────────
// Pantalla donde los usuarios pueden:
// - Ver sus promociones favoritas guardadas
// - Organizar favoritos por categorías (todas, por vencer, categorías, usados)
// - Eliminar favoritos con gesto swipe
// - Ver estadísticas de ahorros
// - Acceder a detalles de promociones individuales

/// Pantalla principal de favoritos del usuario
/// Muestra lista de promociones guardadas con diferentes filtros y organización
class MisFavoritosScreen extends StatefulWidget {
  const MisFavoritosScreen({super.key});

  @override
  State<MisFavoritosScreen> createState() => _MisFavoritosScreenState();
}

class _MisFavoritosScreenState extends State<MisFavoritosScreen>
    with TickerProviderStateMixin {
  // Colores constantes de la aplicación
  static const Color _primary = Color(0xFFFF4D2E);    // Color primario rojo/naranja
  static const Color _darkBg = Color(0xFF1A1F2E);     // Fondo oscuro para cards
  static const Color _green = Color(0xFF10B981);     // Verde para estado "sin prisa"
  static const Color _amber = Color(0xFFF59E0B);     // Ámbar para estado "esta semana"
  static const Color _lightBg = Color(0xFFF5F6FA);   // Fondo gris claro principal

  // Variables de estado de UI
  int _selectedTab = 0;        // Tab activa (0=Todas, 1=Por vencer, 2=Categorías, 3=Usados)
  int _selectedNavTab = 2;    // Tab activa en navegación inferior (2=Favoritos)
  bool _showBanner = true;     // Control de visibilidad del banner informativo


  @override
  void initState() {
    super.initState();
    // No se requiere inicialización adicional en este momento
    // El estado se maneja dinámicamente en el método build
  }

  /// Elimina una promoción de favoritos mediante toggle
  /// Parámetro: promoCode - código único de la promoción a eliminar
  void _dismiss(String promoCode) {
    // Obtener usuario actual (para demo: primer usuario de la lista)
    final currentUser = promoService.getUsuarios().isNotEmpty 
        ? promoService.getUsuarios().first.id 
        : 1;
    // Toggle del estado de favorito (elimina si estaba activo)
    promoService.toggleFavorito(currentUser, promoCode);
    // Feedback háptico medio para confirmar acción
    HapticFeedback.mediumImpact();
  }

  /// Formatea un valor numérico como moneda colombiana
  /// Agrega separadores de miles con puntos y prefijo $
  /// Parámetro: v - valor numérico a formatear
  String _formatCurrency(double v) {
    final s = v.toInt().toString();  // Convertir a entero y luego a string
    final buf = StringBuffer();
    // Recorrer dígitos y agregar punto cada 3 caracteres desde la derecha
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');  // Separador de miles
      buf.write(s[i]);
    }
    return '\$${buf.toString()}';  // Agregar prefijo de peso colombiano
  }

  @override
  Widget build(BuildContext context) {
    // Obtener usuario actual (para demo: primer usuario de la lista)
    final currentUser = promoService.getUsuarios().isNotEmpty 
        ? promoService.getUsuarios().first.id 
        : 1;
    // Obtener promociones favoritas del usuario actual
    final favoritePromos = promoService.getFavoritosByUsuario(currentUser);
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,  // Establecer estilo de sistema (status bar oscuro)
      child: Scaffold(
        backgroundColor: _lightBg,  // Fondo gris claro principal
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título y contador de favoritos
              _buildTopHeader(),
              // Card de estadísticas de ahorros
              _buildSavingsCard(),
              // Banner informativo con instrucciones (solo si está visible)
              if (_showBanner) _buildInfoBanner(),
              // Barra de tabs para filtrar favoritos
              _buildTabBar(),
              // Grupos de promociones según tab seleccionado
              _buildPromoGroups(),
              // Espacio al final del scroll
              const SizedBox(height: 24),
            ],
          ),
        ),
        // Navegación inferior
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ── SECCIÓN DE HEADER SUPERIOR ─────────────────────────────────────────────────

  /// Construye el header superior con título y contador de favoritos
  /// Muestra: título "Mis Favoritos" y badge con cantidad de promos guardadas
  Widget _buildTopHeader() {
    // Obtener usuario actual (para demo: primer usuario de la lista)
    final currentUser = promoService.getUsuarios().isNotEmpty 
        ? promoService.getUsuarios().first.id 
        : 1;
    // Obtener promociones favoritas del usuario
    final favoritePromos = promoService.getFavoritosByUsuario(currentUser);
    
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,  // Respetar área de status bar
        left: 16,
        right: 16,
        bottom: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Título principal de la pantalla
          const Text(
            'Mis Favoritos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1F2E),  // Gris oscuro
            ),
          ),
          // Badge con contador de favoritos
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),  // Fondo gris claro
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8EAF0)),  // Borde gris muy claro
            ),
            child: Row(
              children: [
                // Icono de corazón
                const Icon(Icons.favorite_rounded, color: _primary, size: 14),
                const SizedBox(width: 6),
                // Número de favoritos
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

  // ── SECCIÓN DE CARD DE AHORROS ───────────────────────────────────────────────────

  /// Construye la card de estadísticas de ahorros
  /// Muestra: total ahorrado, porcentaje usado, gráfico circular y estadísticas
  Widget _buildSavingsCard() {
    // Obtener usuario actual (para demo: primer usuario de la lista)
    final currentUser = promoService.getUsuarios().isNotEmpty 
        ? promoService.getUsuarios().first.id 
        : 1;
    // Obtener promociones favoritas del usuario
    final favoritePromos = promoService.getFavoritosByUsuario(currentUser);
    
    // Calcular total de ahorros potenciales
    double totalSavings = 0;
    for (final favorito in favoritePromos) {
      final promo = promoService.getPromocionByCodigo(favorito.codigoPromocion);
      if (promo != null && promo.descuento != null) {
        // Calcular monto de descuento: precio * (descuento / 100)
        final discountAmount = promo.precio * (promo.descuento! / 100);
        totalSavings += discountAmount;
      }
    }
    
    final total = totalSavings;     // Total de ahorros
    final used = 1;                 // Promociones usadas (valor demo)
    
    // Calcular promociones urgentes (que vencen hoy)
    int urgent = 0;
    for (final favorito in favoritePromos) {
      final promo = promoService.getPromocionByCodigo(favorito.codigoPromocion);
      if (promo != null) {
        final urgency = promoService.getPromocionUrgency(promo);
        if (urgency == 'today') urgent++;  // Contar solo las que vencen hoy
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _darkBg,  // Fondo oscuro para contraste
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _darkBg.withValues(alpha: 0.22),  // Sombra del color del fondo
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: badge y gráfico circular
          Row(
            children: [
              // Badge "AHORROS DISPONIBLES"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _primary,  // Fondo primario
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
                        letterSpacing: 0.4,  // Espaciado entre letras
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),  // Empujar gráfico hacia la derecha
              // Gráfico circular simulado (donut chart)
              SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Círculo de progreso
                    CircularProgressIndicator(
                      value: used / favoritePromos.length.clamp(1, 100),  // Porcentaje usado
                      strokeWidth: 5,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),  // Fondo del círculo
                      valueColor: const AlwaysStoppedAnimation<Color>(_primary),  // Color del progreso
                    ),
                    // Texto central del gráfico
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
                            color: Color(0xFF8A8FA8),  // Gris claro
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
          // Monto total de ahorros formateado
          Text(
            _formatCurrency(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,  // Espaciado negativo para estilo compacto
            ),
          ),
          // Etiqueta de moneda
          const Text(
            'COP',
            style: TextStyle(color: Color(0xFFB9C0D0), fontSize: 11),  // Gris azulado
          ),
          const SizedBox(height: 10),
          // Barra de progreso horizontal
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),  // Fondo semi-transparente
              borderRadius: BorderRadius.circular(999),  // Bordes redondeados completos
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: used / favoritePromos.length.clamp(1, 100),  // Porcentaje de progreso
              child: Container(
                decoration: BoxDecoration(
                  color: _primary,  // Color de progreso primario
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Fila de estadísticas mini
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniStat('${favoritePromos.length}', 'guardadas'),  // Total guardadas
              _miniStat('$used', 'Usadas'),                       // Total usadas
              _miniStat('$urgent', 'Urgentes'),                   // Total urgentes
            ],
          ),
        ],
      ),
    );
  }

  /// Construye una estadística mini para la card de ahorros
  /// Muestra: valor numérico y etiqueta descriptiva
  /// Parámetros:
  /// - val: valor numérico a mostrar
  /// - label: etiqueta descriptiva
  Widget _miniStat(String val, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Valor numérico
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        // Etiqueta descriptiva
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8A8FA8), fontSize: 10),  // Gris claro
        ),
      ],
    );
  }

  /// Construye un divisor vertical para estadísticas
  /// Línea blanca semi-transparente de 1px de ancho
  Widget _statDivider() => Container(
    width: 1,
    height: 28,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    color: Colors.white.withOpacity(0.1),  // Blanco muy transparente
  );

  // ── SECCIÓN DE BANNER INFORMATIVO ─────────────────────────────────────────────────

  /// Construye el banner informativo con instrucciones de swipe
  /// Muestra: icono de swipe, mensaje instructivo y botón de cerrar
  Widget _buildInfoBanner() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),  // Animación suave
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F3F8), width: 1),  // Borde gris muy claro
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),  // Sombra muy sutil
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono de swipe izquierda
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.12),  // Fondo primario transparente
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.swipe_left_outlined,
              color: _primary,
              size: 12,
            ),
          ),
          const SizedBox(width: 8),
          // Mensaje instructivo
          const Expanded(
            child: Text(
              'Desliza una promo a la izquierda para eliminarla',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),  // Gris medio
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Botón de cerrar (placeholder)
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),  // Fondo gris claro
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.close, color: Color(0xFFB0B5CC), size: 11),  // Gris claro
          ),
        ],
      ),
    );
  }

  // ── SECCIÓN DE BARRA DE TABS ───────────────────────────────────────────────────

  /// Construye la barra de tabs para filtrar favoritos
  /// Muestra: 4 tabs (Todas, Por vencer, Categorías, Usados)
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),  // Sombra muy sutil
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _tabItem(0, 'Todas'),        // Tab 0: Todas las promociones
          _tabItem(1, 'Por vencer'),    // Tab 1: Promociones por vencer (3 días o menos)
          _tabItem(2, 'Categorías'),    // Tab 2: Agrupadas por categorías
          _tabItem(3, 'Usados'),        // Tab 3: Promociones ya usadas
        ],
      ),
    );
  }

  // ── SECCIÓN DE GRUPOS DE PROMOCIONES ─────────────────────────────────────────────

  /// Construye los grupos de promociones según el tab seleccionado
  /// Filtra y organiza las promociones favoritas del usuario
  Widget _buildPromoGroups() {
    // Obtener usuario actual (para demo: primer usuario de la lista)
    final currentUser = promoService.getUsuarios().isNotEmpty 
        ? promoService.getUsuarios().first.id 
        : 1;
    // Obtener promociones favoritas del usuario
    final favoritePromos = promoService.getFavoritosByUsuario(currentUser);
    
    // Obtener promociones agrupadas por urgencia
    final promosByUrgency = promoService.getPromocionesByUrgency(currentUser);
    
    // Filtrar y mostrar según tab seleccionado
    switch (_selectedTab) {
      case 0: // Todas - mostrar todas las promociones agrupadas por urgencia
        return _buildAllCategories(promosByUrgency);
      case 1: // Por vencer - mostrar promociones que vencen en 3 días o menos
        return _buildExpiringSoon(currentUser);
      case 2: // Categorías - mostrar promociones agrupadas por categoría
        return _buildByCategories(currentUser);
      case 3: // Usados - mostrar promociones ya usadas (no implementado)
        return _buildEmptyState();
      default:
        return _buildAllCategories(promosByUrgency);  // Fallback a todas
    }
  }

  /// Obtiene promociones que vencen en 3 días o menos
  /// Filtra las promociones favoritas del usuario por fecha de vencimiento
  /// Parámetro: userId - ID del usuario actual
  List<Promocion> _getPromotionsExpiringIn3Days(int userId) {
    // Obtener promociones favoritas del usuario
    final favoritePromos = promoService.getFavoritosByUsuario(userId);
    // Convertir favoritos a objetos Promocion completos
    final promocionesFavoritas = favoritePromos
        .map((f) => promoService.getPromocionByCodigo(f.codigoPromocion))
        .where((p) => p != null)  // Filtrar nulos
        .cast<Promocion>();

    List<Promocion> expiringSoon = [];
    final ahora = DateTime.now();  // Fecha y hora actual

    // Analizar cada promoción para determinar si vence pronto
    for (final promo in promocionesFavoritas) {
      // Solo considerar promociones con fecha de vencimiento (no permanentes)
      if (promo.tipoVigencia != 'permanente' && promo.fechaFin != null) {
        try {
          final fechaFin = DateTime.parse(promo.fechaFin!);  // Parsear fecha de fin
          final diferencia = fechaFin.difference(ahora);     // Calcular diferencia
          
          // Incluir promociones que vencen en 3 días o menos
          if (!diferencia.isNegative && diferencia.inDays <= 3) {
            expiringSoon.add(promo);
          }
        } catch (e) {
          // Ignorar fechas inválidas o mal formateadas
        }
      }
    }

    return expiringSoon;
  }

  /// Construye la sección de promociones que vencen pronto
  /// Muestra promociones que vencen en 3 días o menos con cards swipeables
  /// Parámetro: userId - ID del usuario actual
  Widget _buildExpiringSoon(int userId) {
    final expiringSoon = _getPromotionsExpiringIn3Days(userId);
    
    // Mostrar estado vacío si no hay promociones por vencer
    if (expiringSoon.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de sección con emoji y color de urgencia
        _buildGroupHeader(
          'Vencen en 3 días o menos',
          const Color(0xFFFF4D2E),  // Rojo para urgencia
          '⏰',
        ),
        // Cards de promociones con gesto de swipe para eliminar
        ...expiringSoon.map((p) => _buildSwipeCard(p)).toList(),
      ],
    );
  }

  /// Construye la sección de promociones agrupadas por categorías
  /// Organiza las promociones favoritas por su categoría correspondiente
  /// Parámetro: userId - ID del usuario actual
  Widget _buildByCategories(int userId) {
    // Obtener promociones favoritas del usuario
    final favoritePromos = promoService.getFavoritosByUsuario(userId);
    // Convertir a objetos Promocion completos
    final promocionesFavoritas = favoritePromos
        .map((f) => promoService.getPromocionByCodigo(f.codigoPromocion))
        .where((p) => p != null)
        .cast<Promocion>();

    // Agrupar promociones por categoría
    final Map<String, List<Promocion>> promosByCategory = {};
    
    for (final promo in promocionesFavoritas) {
      // Obtener información de la categoría
      final categoria = promoService.getCategoria(promo.idCategoria);
      final categoryName = categoria?.nombre ?? 'Sin categoría';
      
      // Inicializar lista para la categoría si no existe
      if (!promosByCategory.containsKey(categoryName)) {
        promosByCategory[categoryName] = [];
      }
      // Agregar promoción a su categoría
      promosByCategory[categoryName]!.add(promo);
    }

    // Mostrar estado vacío si no hay categorías
    if (promosByCategory.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Construir sección para cada categoría
        ...promosByCategory.entries.map((entry) {
          final categoryName = entry.key;
          final promos = entry.value;
          // Obtener estilo y emoji de la categoría
          final categoryStyle = promoService.getCategoriaStyle(promos.first.idCategoria);
          final emoji = categoryStyle['emoji'] ?? '📦';
          final color = _getCategoryColor(categoryName);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header de categoría con color y emoji específicos
              _buildGroupHeader(categoryName, color, emoji),
              // Cards de promociones de esta categoría
              ...promos.map((p) => _buildSwipeCard(p)).toList(),
              const SizedBox(height: 16),  // Espacio entre categorías
            ],
          );
        }).toList(),
      ],
    );
  }

  /// Construye la sección de todas las promociones agrupadas por urgencia
  /// Organiza las promociones en tres grupos: vencen hoy, esta semana, sin prisa
  /// Parámetro: promosByUrgency - mapa con promociones agrupadas por urgencia
  Widget _buildAllCategories(Map<String, List<Promocion>> promosByUrgency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Promociones que vencen hoy (máxima urgencia)
        if (promosByUrgency['today']!.isNotEmpty) ...[
          _buildGroupHeader(
            'Vencen hoy — ¡Actúa ya!',
            const Color(0xFFFF4D2E),  // Rojo para máxima urgencia
            '🔥',
          ),
          ...promosByUrgency['today']!.map((p) => _buildSwipeCard(p)).toList(),
        ],
        // Promociones que vencen esta semana (urgencia media)
        if (promosByUrgency['thisWeek']!.isNotEmpty) ...[
          _buildGroupHeader('Esta semana', const Color(0xFFF59E0B), '⏳'),  // Ámbar
          ...promosByUrgency['thisWeek']!.map((p) => _buildSwipeCard(p)).toList(),
        ],
        // Promociones sin prisa (baja urgencia)
        if (promosByUrgency['noRush']!.isNotEmpty) ...[
          _buildGroupHeader('Sin prisa', const Color(0xFF10B981), '🟢'),  // Verde
          ...promosByUrgency['noRush']!.map((p) => _buildSwipeCard(p)).toList(),
        ],
      ],
    );
  }

  /// Obtiene el color asignado a una categoría específica
  /// Asigna colores distintivos para diferentes tipos de categorías
  /// Parámetro: categoryName - nombre de la categoría
  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'alimentos':
        return const Color(0xFF10B981);  // Verde
      case 'tecnología':
        return const Color(0xFF3B82F6);  // Azul
      case 'ropa':
        return const Color(0xFF8B5CF6);  // Púrpura
      case 'hogar':
        return const Color(0xFFF59E0B);  // Ámbar
      case 'salud':
        return const Color(0xFFEF4444);  // Rojo
      case 'deportes':
        return const Color(0xFF06B6D4);  // Cian
      case 'belleza':
        return const Color(0xFFEC4899);  // Rosa
      case 'juguetes':
        return const Color(0xFF84CC16);  // Lima
      case 'libros':
        return const Color(0xFF6366F1);  // Índigo
      case 'automotriz':
        return const Color(0xFF6B7280);  // Gris
      default:
        return const Color(0xFFFF4D2E);  // Color primario como fallback
    }
  }

  /// Construye el header de un grupo de promociones
  /// Muestra: emoji, título y color distintivo para cada sección
  /// Parámetros:
  /// - title: título del grupo
  /// - color: color distintivo del grupo
  /// - emoji: emoji representativo del grupo
  Widget _buildGroupHeader(String title, Color color, String emoji) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          // Badge del grupo con emoji y título
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),  // Color transparente del grupo
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 11)),  // Emoji del grupo
                const SizedBox(width: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1F2E),  // Gris oscuro
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una card de promoción con gesto de swipe para eliminar
  /// Implementa DismissibleWidget para permitir eliminación con swipe izquierdo
  /// Parámetro: promo - objeto promoción a mostrar
  Widget _buildSwipeCard(Promocion promo) {
    return Dismissible(
      key: Key(promo.codigo),  // Key única para identificar la card
      direction: DismissDirection.endToStart,  // Solo swipe de derecha a izquierda
      onDismissed: (_) => _dismiss(promo.codigo),  // Acción al hacer swipe
      background: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        decoration: BoxDecoration(
          color: _primary,  // Fondo primario para acción de eliminar
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de eliminación
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
            SizedBox(height: 4),
            // Texto de acción
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
      child: _buildPromoCard(promo),  // Card principal de la promoción
    );
  }

  /// Construye la card principal de una promoción favorita
  /// Muestra: imagen, información básica, precios, rating y urgencia
  /// Parámetro: promo - objeto promoción a mostrar
  Widget _buildPromoCard(Promocion promo) {
    // Obtener datos relacionados del service
    final supermercado = promoService.getSupermercado(promo.idSupermercado);
    final categoria = promoService.getCategoria(promo.idCategoria);
    final categoriaStyle = promoService.getCategoriaStyle(promo.idCategoria);
    final precioConDescuento = promoService.getPrecioConDescuento(promo);
    final rating = promoService.getPromocionRating(promo.codigo);
    final urgency = promoService.getPromocionUrgency(promo);
    
    // Determinar color y etiqueta de urgencia
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
    
    // Formatear descuento si existe
    final discount = promo.descuento != null ? '-${promo.descuento}%' : '';
    
    // Formatear tiempo restante para mostrar
    String timeDisplay = 'permanente';
    if (promo.fechaFin != null) {
      try {
        final fechaFin = DateTime.parse(promo.fechaFin!);  // Parsear fecha de fin
        final ahora = DateTime.now();                    // Fecha actual
        final diferencia = fechaFin.difference(ahora);   // Calcular diferencia
        
        // Formatear según unidades de tiempo
        if (diferencia.inDays > 0) {
          timeDisplay = '${diferencia.inDays} días';
        } else if (diferencia.inHours > 0) {
          timeDisplay = '${diferencia.inHours} horas';
        } else {
          timeDisplay = '${diferencia.inMinutes} min';
        }
      } catch (e) {
        timeDisplay = 'permanente';  // Fallback para fechas inválidas
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),  // Sombra muy sutil
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Fila principal con imagen e información
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                // Sección de imagen/emoji
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Imagen de la promoción (con fallbacks)
                        _buildPromoImage(promo, categoriaStyle['emoji'], 50),
                        // Overlay gradiente para mejorar legibilidad
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
                        // Badge de descuento (solo si hay descuento)
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
                                color: _primary,  // Fondo primario
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
                // Sección de información de la promoción
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fila: nombre de tienda y badge de urgencia
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              supermercado?.nombre ?? 'Tienda',  // Fallback si no hay tienda
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF8A8FA8),  // Gris claro
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          // Badge de urgencia
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: urgencyColor.withValues(alpha: 0.12),  // Color transparente
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
                      // Título de la promoción
                      Text(
                        promo.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1F2E),  // Gris oscuro
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Sección de precios
                      Row(
                        children: [
                          // Precio con descuento (resaltado)
                          Text(
                            '\$${precioConDescuento.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A1F2E),
                            ),
                          ),
                          // Precio original tachado (solo si hay descuento)
                          if (promo.descuento != null && promo.descuento! > 0) ...[
                            const SizedBox(width: 5),
                            Text(
                              '\$${promo.precio.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: Color(0xFFB0B5CC),  // Gris claro
                                decoration: TextDecoration.lineThrough,  // Texto tachado
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Fila inferior: rating y tiempo restante
                      Row(
                        children: [
                          // Icono y rating
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFBBF24),  // Amarillo dorado
                            size: 10,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),  // Rating con 1 decimal
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF5A5F72),  // Gris medio
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Separador
                          const Text(
                            ' · ',
                            style: TextStyle(
                              color: Color(0xFFB0B5CC),  // Gris claro
                              fontSize: 8,
                            ),
                          ),
                          // Icono y tiempo
                          const Icon(
                            Icons.access_time_rounded,
                            size: 9,
                            color: Color(0xFFB0B5CC),  // Gris claro
                          ),
                          const SizedBox(width: 2),
                          Text(
                            timeDisplay,  // Tiempo restante formateado
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF8A8FA8),  // Gris claro
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

  /// Construye un item de tab con icono, etiqueta y badge (opcional)
  /// Utilizado en la barra de navegación superior
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

  /// Devuelve el icono correspondiente a cada tab
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

  /// Construye la imagen de la promoción con fallbacks
  /// Utilizado en la sección de imagen de la promoción
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

  /// Construye el fallback de la imagen con un emoji
  /// Utilizado en la sección de imagen de la promoción
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

  /// Abre la pantalla de detalles de la promoción
  /// Utilizado en el botón Ver Promo
  void _openPromotionDetails(String promoCode) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, AppRoutes.promotionDetails, arguments: promoCode);
  }

  // ── Empty state ──────────────────────────────────────────────────────────────

  /// Construye el estado vacío de la pantalla de favoritos
  /// Utilizado cuando no hay promociones favoritas
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

  /// Construye la barra de navegación inferior con tabs animados
  /// Utilizado en la pantalla de favoritos
  Widget _buildBottomNav() {
    // Definición de tabs con iconos y etiquetas
    final tabs = [
      _NavItem(icon: Icons.map_rounded, label: 'Inicio'),
      _NavItem(icon: Icons.explore_outlined, label: 'Explorar'),
      _NavItem(icon: Icons.favorite_border_rounded, label: 'Favoritos'),
      _NavItem(icon: Icons.person_outline_rounded, label: 'Perfil'),
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

/// Modelo auxiliar para representar un tab de navegación
/// Contiene icono y etiqueta para cada opción del menú inferior
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
