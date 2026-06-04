import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../Core/Routes/app_routes.dart';
import '../../../../../Core/di/app_scope.dart';

/// Pantalla de auditoria con actividad reciente, filtros y atajos de aviso.

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS
// ─────────────────────────────────────────────────────────────────────────────

/// Enum que clasifica cada evento de auditoría por categoría.
/// Un enum es un tipo de dato con un conjunto fijo de valores posibles;
/// aquí sirve para filtrar la lista sin usar Strings "mágicos" como "user".
enum _ActivityType { user, promo, store, system }

/// Modelo de datos inmutable que representa un evento de auditoría.
/// Es "const" porque ninguno de sus campos cambia una vez creado (inmutable).
class _ActivityItem {
  final String actor; // Nombre del actor (usuario, comercio o sistema)
  final String actorInitial; // Inicial para el avatar circular
  final Color actorColor; // Color único que identifica al actor
  final String action; // Verbo de la acción (canjeó, creó, eliminó…)
  final String title; // Nombre de la entidad afectada
  final List<String> details; // Líneas de detalle adicionales (fecha, lugar…)
  final String time; // Tiempo relativo desde el evento (ej. "Hace 2m")
  final _ActivityType type; // Categoría del evento para el filtro
  final String? badge; // Etiqueta visual del tipo de evento (opcional)
  final Color? badgeColor; // Color de la etiqueta (opcional)

  const _ActivityItem({
    required this.actor,
    required this.actorInitial,
    required this.actorColor,
    required this.action,
    required this.title,
    required this.details,
    required this.time,
    required this.type,
    this.badge,
    this.badgeColor,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA AUDITORÍA ADMIN
// ─────────────────────────────────────────────────────────────────────────────

/// Pantalla administrativa de auditoria con actividad reciente del sistema.
class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({super.key});

  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

/// State con TickerProviderStateMixin porque en el futuro puede alojar
/// AnimationControllers; también permite que sus hijos usen vsync: this.
class _AdminAuditScreenState extends State<AdminAuditScreen>
    with TickerProviderStateMixin {
  // ── Paleta de colores centralizada ──────────────────────────────────────────
  // Definidas como constantes estáticas para que no se recreen en cada build.
  static const Color _primary = Color(0xFFFF4D2E); // Naranja/rojo de la marca
  static const Color _darkBg = Color(
    0xFF1A1F2E,
  ); // Fondo oscuro de cards premium
  static const Color _green = Color(0xFF10B981); // Verde para estados positivos
  static const Color _blue = Color(0xFF3B82F6); // Azul para promos y push
  static const Color _purple = Color(0xFF8B5CF6); // Morado para sistema/vistas
  static const Color _amber = Color(0xFFF59E0B); // Ámbar para alertas/expirados
  static const Color _pink = Color(0xFFEC4899); // Rosa para ciertos usuarios
  static const Color _lightBg = Color(0xFFF5F6FA); // Fondo gris muy claro

  // ── Índices de estado de navegación ─────────────────────────────────────────
  int _selectedTab =
      0; // Tab activo dentro de la auditoría (Actividad/Reportes/…)
  int _selectedFilter =
      0; // Filtro activo de la lista (Todas/Usuarios/Promos/…)
  int _selectedNavTab = 4; // Tab activo en la barra inferior (4 = Avisos)

  // ── Dataset de actividad ─────────────────────────────────────────────────────
  // Lista constante de eventos de ejemplo. En producción vendría del backend.
  // Se usa 'const' para que Flutter no recree los objetos en cada rebuild.
  final List<_ActivityItem> _activities = const [
    _ActivityItem(
      actor: 'Maria Garcia',
      actorInitial: 'M',
      actorColor: Color(0xFFFF4D2E),
      action: 'canjeó',
      title: '2×1 en Pizzas Express',
      details: [
        'Medellín, Poblado · 9 Mar 18:22',
        'Código: PIZZA2X1 · Pizza Express',
      ],
      time: 'Hace 2m',
      type: _ActivityType.user,
      badge: 'Canje',
      badgeColor: Color(0xFF10B981),
    ),
    _ActivityItem(
      actor: 'TechStore Bogotá',
      actorInitial: 'T',
      actorColor: Color(0xFF3B82F6),
      action: 'creó',
      title: '30% OFF en Laptops HP · Descuento: 35%',
      details: ['Bogotá, Carrera · 9 Mar 14:17'],
      time: 'Hace 8m',
      type: _ActivityType.promo,
      badge: 'Nueva promo',
      badgeColor: Color(0xFF3B82F6),
    ),
    _ActivityItem(
      actor: 'Carlos López',
      actorInitial: 'C',
      actorColor: Color(0xFF10B981),
      action: 'se registró',
      title: 'Cuenta de usuario',
      details: ['Cali, Norte · 9 Mar 14:00', 'carlos.lopez@email.com'],
      time: 'Hace 13m',
      type: _ActivityType.user,
      badge: 'Registro',
      badgeColor: Color(0xFF10B981),
    ),
    _ActivityItem(
      actor: 'Ana Martínez',
      actorInitial: 'A',
      actorColor: Color(0xFFEC4899),
      action: 'visualizó',
      title: '50% en Zapatillas Nike',
      details: ['Sport Zone · Tiempo de vista: 48s'],
      time: 'Hace 22m',
      type: _ActivityType.user,
      badge: 'Vista',
      badgeColor: Color(0xFF8B5CF6),
    ),
    _ActivityItem(
      actor: 'Sistema',
      actorInitial: 'S',
      actorColor: Color(0xFF8B5CF6),
      action: 'expiró',
      title: 'Oferta Flash Tecnología',
      details: [
        'Medellín · 9 Mar 13:55',
        '47 canjes realizados durante la campaña',
      ],
      time: 'Hace 1h',
      type: _ActivityType.system,
      badge: 'Expirada',
      badgeColor: Color(0xFFF59E0B),
    ),
    _ActivityItem(
      actor: 'Admin Principal',
      actorInitial: 'A',
      actorColor: Color(0xFFFF4D2E),
      action: 'agregó',
      title: 'Moda Latina',
      details: [
        'Bogotá · 9 Mar 12:30',
        'Categoría: Moda · 5 promociones iniciales',
      ],
      time: 'Hace 2h',
      type: _ActivityType.store,
      badge: 'Comercio',
      badgeColor: Color(0xFF3B82F6),
    ),
    _ActivityItem(
      actor: 'Pizza Express',
      actorInitial: 'P',
      actorColor: Color(0xFFF59E0B),
      action: 'eliminó',
      title: 'Oferta Flash Tecnología',
      details: ['Medellín · 9 Mar 11:20', 'Razón: Promoción reemplazada'],
      time: 'Hace 3h',
      type: _ActivityType.promo,
      badge: 'Eliminada',
      badgeColor: Color(0xFFFF4D2E),
    ),
    _ActivityItem(
      actor: 'Luis Herrera',
      actorInitial: 'L',
      actorColor: Color(0xFF10B981),
      action: 'inició sesión',
      title: 'App Movil',
      details: [
        'Medellín · 9 Mar 10:05',
        'Dispositivo: iPhone 14 Pro · iOS 17.2',
      ],
      time: 'Hace 5h',
      type: _ActivityType.user,
      badge: 'Sesión',
      badgeColor: Color(0xFF10B981),
    ),
  ];

  /// Getter que devuelve la lista filtrada según el chip activo.
  /// Un getter en Dart es una propiedad calculada: no almacena datos,
  /// sino que los calcula cada vez que se accede (como un método sin paréntesis).
  /// .where() filtra sin modificar la lista original; .toList() la materializa.
  List<_ActivityItem> get _filtered {
    switch (_selectedFilter) {
      case 1:
        return _activities.where((a) => a.type == _ActivityType.user).toList();
      case 2:
        return _activities.where((a) => a.type == _ActivityType.promo).toList();
      case 3:
        return _activities.where((a) => a.type == _ActivityType.store).toList();
      default:
        return _activities; // case 0: devuelve todos sin filtrar
    }
  }

  @override
  Widget build(BuildContext context) {
    // AnnotatedRegion controla el color de los íconos de la barra de estado
    // del sistema operativo (hora, batería…). SystemUiOverlayStyle.dark
    // los pone en color oscuro, apropiado sobre fondos claros.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _lightBg,
        body: Column(
          children: [
            _buildAdminTopBar(), // Barra de marca + notificaciones + avatar
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Bloque blanco superior: header + card de push + tabs
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          _buildPageHeader(), // Título "Auditoría"
                          _buildPushNotifCard(), // Card oscura con estadísticas push
                          const SizedBox(height: 4),
                          _buildStatsRow(), // Vacío por ahora (SizedBox.shrink)
                          _buildTabBar(), // Tabs: Actividad/Reportes/Alertas/Exportar
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Bloque blanco inferior: filtros + lista de eventos
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          _buildFilterChips(), // Chips horizontales de filtro
                          _buildActivityHeader(), // Título "Actividad en Tiempo Real"
                          _buildActivityList(), // Lista de eventos filtrados
                          _buildVerMas(), // Botón "Ver más actividad"
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(), // Barra fija inferior de 5 tabs
      ),
    );
  }

  // ── Admin top bar ─────────────────────────────────────────────────────────────

  /// Barra superior con logo de la app, nombre del panel,
  /// ícono de notificaciones con punto rojo y avatar del admin.
  Widget _buildAdminTopBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        // padding.top es la altura de la barra de estado del sistema (notch, etc.).
        // Se suma 8 px extra de margen visual.
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 10,
      ),
      child: Row(
        children: [
          // ── Logo de la marca ──
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_offer_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          // ── Nombre y subtítulo del panel ──
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROMOMANIA',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB0B5CC),
                  letterSpacing: 1.2, // Espaciado entre letras para legibilidad
                ),
              ),
              Text(
                'Admin Panel',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1F2E),
                ),
              ),
            ],
          ),
          // Spacer empuja el resto de widgets hacia la derecha
          const Spacer(),
          // ── Ícono de notificaciones con punto indicador ──
          Stack(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _lightBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF1A1F2E),
                  size: 20,
                ),
              ),
              // Punto rojo posicionado encima del ícono con Positioned
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _primary,
                    shape: BoxShape.circle,
                    // Borde blanco para separar el punto del ícono de fondo
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // ── Avatar del admin (navega al perfil al tocar) ──
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.userProfile),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _darkBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Page header ───────────────────────────────────────────────────────────────

  /// Encabezado de sección con ícono, título "Auditoría" y subtítulo.
  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Ícono de escudo/política con fondo ámbar translúcido
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.policy_outlined, color: _amber, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auditoría',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1F2E),
                  ),
                ),
                Text(
                  'Centro de reportes y alertas',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF8A8FA8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Push Notification card ────────────────────────────────────────────────────

  /// Card oscura premium que muestra el estado de las notificaciones push
  /// con tres métricas: enviadas, tasa de apertura y clics.
  Widget _buildPushNotifCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
      child: Container(
        decoration: BoxDecoration(
          color: _darkBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _darkBg.withOpacity(0.2),
              blurRadius: 14,
              offset: const Offset(0, 5), // Sombra hacia abajo
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fila superior: badge de tipo + botón "Nueva Campaña" ──
            Row(
              children: [
                // Badge azul translúcido que identifica la sección
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        color: Color(0xFF3B82F6),
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Push Notifications',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Botón de acción principal (sin navegación implementada aún)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Nueva Campaña',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Descripción con opacidad reducida para no competir con los números
            Text(
              'Llega a tus usuarios en tiempo\nreal con mensajes personalizados',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12.5,
                height: 1.45, // Interlineado para el salto de línea
              ),
            ),
            const SizedBox(height: 16),
            // ── Fila de 3 métricas separadas por divisores verticales ──
            Row(
              children: [
                _darkStat('4.2K', '↑ +14%', 'Enviadas'),
                _darkStatDivider(),
                // highlight: true pone el valor en color ámbar para destacarlo
                _darkStat('89%', '↑ +8%', 'Tasa', highlight: true),
                _darkStatDivider(),
                _darkStat('2.8K', '↑ +11%', 'Clics'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Mini-stat vertical dentro de la card oscura.
  /// [highlight] cambia el color del valor a ámbar para resaltarlo visualmente.
  Widget _darkStat(
    String val,
    String change,
    String label, {
    bool highlight = false, // Parámetro nombrado con valor por defecto false
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(
              // Si highlight es true → ámbar; si no → blanco
              color: highlight ? _amber : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            change,
            style: const TextStyle(
              color: Color(0xFF10B981), // Verde para variaciones positivas
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Línea vertical blanca semitransparente que separa las tres métricas.
  Widget _darkStatDivider() =>
      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1));

  // ── Stats row ─────────────────────────────────────────────────────────────────

  /// Sección reservada para estadísticas adicionales del tab Actividad.
  /// SizedBox.shrink() es el widget más liviano para no ocupar espacio
  /// cuando no hay contenido (equivale a un widget de tamaño 0×0).
  Widget _buildStatsRow() {
    return const SizedBox.shrink();
  }

  // ── Tab bar ───────────────────────────────────────────────────────────────────

  /// Barra de tabs internos de la auditoría: Actividad, Reportes, Alertas, Exportar.
  /// El badge de Reportes se obtiene en tiempo real del promoService.
  Widget _buildTabBar() {
    // Cantidad de reportes activos (dato en vivo del servicio global)
    final reportesBadge = moderationController.getReportesSync().length;

    // Lista de definiciones de tabs (modelo auxiliar _TabDef al final del archivo)
    final tabs = [
      _TabDef(icon: Icons.timeline_rounded, label: 'Actividad'),
      _TabDef(
        icon: Icons.bar_chart_rounded,
        label: 'Reportes',
        // Si hay reportes muestra el número; si no, no muestra badge (null)
        badge: reportesBadge > 0 ? '$reportesBadge' : null,
      ),
      _TabDef(icon: Icons.warning_amber_rounded, label: 'Alertas', badge: '3'),
      _TabDef(icon: Icons.download_outlined, label: 'Exportar'),
    ];

    return Container(
      // Línea divisora en la parte inferior del tab bar
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F1F5), width: 1)),
      ),
      child: Row(
        // List.generate crea una lista de widgets a partir de un índice,
        // evitando escribir cada tab manualmente.
        children: List.generate(tabs.length, (i) {
          final isActive = _selectedTab == i;
          final t = tabs[i];
          return Expanded(
            child: GestureDetector(
              onTap: () =>
                  _onAuditTabTap(i), // Navega al sub-módulo correspondiente
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      // Solo el tab activo tiene línea naranja en la parte inferior
                      color: isActive ? _primary : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Stack permite superponer el badge encima del ícono
                    Stack(
                      clipBehavior:
                          Clip.none, // Permite que el badge salga del bounds
                      children: [
                        Icon(
                          t.icon,
                          size: 20,
                          color: isActive ? _primary : const Color(0xFFB0B5CC),
                        ),
                        // El badge solo se muestra si t.badge no es null
                        if (t.badge != null)
                          Positioned(
                            top: -4,
                            right: -8, // Sale a la derecha del ícono
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: _primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                t.badge!, // ! afirma que no es null (ya lo chequeamos)
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
                    const SizedBox(height: 4),
                    Text(
                      t.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: isActive ? _primary : const Color(0xFFB0B5CC),
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

  // ── Filter chips ──────────────────────────────────────────────────────────────

  /// Fila horizontal de chips para filtrar la lista de actividad por categoría.
  /// Usa SingleChildScrollView horizontal para que quepan sin overflow.
  Widget _buildFilterChips() {
    final filters = ['🔵 Todas', '👤 Usuarios', '🏷 Promos', '🏪 Comercios'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Scroll solo en el eje X
        child: Row(
          children: List.generate(filters.length, (i) {
            final isActive = _selectedFilter == i;
            return GestureDetector(
              onTap: () {
                // setState() le dice a Flutter que _selectedFilter cambió
                // y que debe reconstruir el widget con el nuevo valor.
                setState(() => _selectedFilter = i);
                // HapticFeedback.selectionClick() genera vibración suave al seleccionar
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                // AnimatedContainer interpola automáticamente entre el estado anterior
                // y el nuevo en 180ms, animando color y borde sin código extra.
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isActive ? _darkBg : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? _darkBg : const Color(0xFFE8EAF0),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  filters[i],
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : const Color(0xFF5A5F72),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Activity header ───────────────────────────────────────────────────────────

  /// Encabezado de la lista con punto verde "en vivo" y botón de actualizar.
  Widget _buildActivityHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          // Punto verde que simboliza actividad en tiempo real
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: _green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Actividad en Tiempo Real',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1F2E),
            ),
          ),
          const Spacer(),
          // Botón "Actualizar" (solo genera haptic; sin lógica de recarga aún)
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _lightBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 13,
                    color: Color(0xFF8A8FA8),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Actualizar',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF8A8FA8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Activity list ─────────────────────────────────────────────────────────────

  /// Renderiza la lista de eventos filtrados como una columna de items.
  /// Usa el getter _filtered para obtener solo los eventos del tipo seleccionado.
  Widget _buildActivityList() {
    final items = _filtered; // Llama al getter que aplica el filtro actual
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          // isLast se usa para no dibujar la línea de tiempo bajo el último item
          final isLast = i == items.length - 1;
          return _buildActivityItem(item, isLast: isLast);
        }),
      ),
    );
  }

  /// Construye la fila de un evento individual con:
  /// - Línea de tiempo vertical (conecta los eventos entre sí)
  /// - Avatar circular con la inicial y color del actor
  /// - Caja de detalle con título, badge y líneas de información
  Widget _buildActivityItem(_ActivityItem item, {bool isLast = false}) {
    // IntrinsicHeight hace que todos los hijos de la fila tengan la misma altura,
    // necesario para que la línea de tiempo llegue exactamente al siguiente item.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Columna izquierda: avatar + línea de tiempo ──
          SizedBox(
            width: 40,
            child: Column(
              children: [
                const SizedBox(height: 2),
                // Avatar circular con color e inicial del actor
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: item.actorColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: item.actorColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item.actorInitial,
                      style: TextStyle(
                        color: item.actorColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                // La línea de tiempo solo aparece si NO es el último item.
                // Expanded hace que ocupe todo el espacio restante de la columna,
                // conectando visualmente este item con el siguiente.
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFF0F1F5),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // ── Columna derecha: nombre + acción + caja de detalle ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila: texto del actor+acción a la izquierda, hora a la derecha
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          // RichText permite mezclar estilos en una sola línea:
                          // nombre en negrita + acción en texto normal.
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: item.actor,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1F2E),
                                ),
                              ),
                              TextSpan(
                                text: ' ${item.action}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF5A5F72),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB0B5CC),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // ── Caja de detalle del evento ──
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFEEF0F6),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1F2E),
                                  height: 1.3,
                                ),
                              ),
                            ),
                            // El badge solo se renderiza si item.badge no es null.
                            // ...[widgets] es el spread operator: inserta los
                            // widgets de la lista directamente en la lista padre.
                            if (item.badge != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: (item.badgeColor ?? _primary)
                                      .withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.badge!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: item.badgeColor ?? _primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Líneas de detalle (fecha, lugar, código…)
                        // Solo se muestran si la lista no está vacía.
                        if (item.details.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          // .map() transforma cada String en un widget Text
                          ...item.details.map(
                            (d) => Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                d,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF8A8FA8),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Ver más ───────────────────────────────────────────────────────────────────

  /// Botón que simula cargar más eventos.
  /// Por ahora solo genera feedback háptico; la lógica de paginación
  /// se implementaría aquí (ej. llamada al backend con offset).
  Widget _buildVerMas() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: Container(
          width: double.infinity, // Ocupa todo el ancho disponible
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: _lightBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Ver más actividad →',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5A5F72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────────

  /// Barra de navegación inferior con 5 módulos del panel admin.
  /// El tab activo (_selectedNavTab = 4, Avisos) se resalta con naranja.
  Widget _buildBottomNav() {
    final tabs = [
      _NavItem(icon: Icons.dashboard_outlined, label: 'Panel'),
      _NavItem(icon: Icons.people_outline_rounded, label: 'Usuarios'),
      _NavItem(icon: Icons.local_offer_outlined, label: 'Promos'),
      _NavItem(icon: Icons.storefront_outlined, label: 'Comercios'),
      _NavItem(icon: Icons.notifications_outlined, label: 'Avisos'),
    ];

    return Container(
      // padding.bottom añade espacio para el home indicator en iPhones sin botón físico
      height: 60 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, -2), // Sombra hacia arriba
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (i) {
          final isActive = _selectedNavTab == i;
          return GestureDetector(
            onTap: () => _onBottomNavTap(i),
            // HitTestBehavior.opaque hace que toda el área del SizedBox
            // sea táctil, aunque tenga fondo transparente.
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 62,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // AnimatedContainer anima el fondo naranja al seleccionar un tab
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? _primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      tabs[i].icon,
                      color: isActive ? _primary : const Color(0xFFB0B5CC),
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tabs[i].label,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
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

  // ── Métodos de navegación ─────────────────────────────────────────────────────

  /// Traduce el índice del bottom nav a la ruta del módulo correspondiente.
  String _routeForIndex(int index) {
    switch (index) {
      case 0:
        return AppRoutes.adminDashboard;
      case 1:
        return AppRoutes.manageUsers;
      case 2:
        return AppRoutes.managePromotions;
      case 3:
        return AppRoutes.manageStores;
      default:
        return AppRoutes.manageNotifications;
    }
  }

  /// Traduce el índice del tab de auditoría a su ruta específica.
  /// Cada sub-pantalla de auditoría tiene su propia ruta en AppRoutes.
  String _notiRouteForTab(int index) {
    switch (index) {
      case 0:
        return AppRoutes.adminNotiActivity;
      case 1:
        return AppRoutes.adminNotiReport;
      case 2:
        return AppRoutes.adminNotiAlert;
      default:
        return AppRoutes.adminNotiExport;
    }
  }

  /// Maneja el tap en los tabs internos de auditoría.
  /// pushReplacementNamed reemplaza la pantalla actual sin apilar una nueva,
  /// evitando que el botón "atrás" regrese al tab anterior.
  void _onAuditTabTap(int index) {
    if (index == _selectedTab) return; // No navega si ya está activo
    HapticFeedback.selectionClick();
    Navigator.pushReplacementNamed(context, _notiRouteForTab(index));
  }

  /// Maneja el tap en la barra de navegación inferior.
  void _onBottomNavTap(int index) {
    if (index == _selectedNavTab) return; // No navega si ya está activo
    HapticFeedback.selectionClick();
    Navigator.pushReplacementNamed(context, _routeForIndex(index));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS AUXILIARES
// ─────────────────────────────────────────────────────────────────────────────

/// Definición de un tab de auditoría: ícono, etiqueta y badge opcional.
/// Se separó en un modelo para que _buildTabBar sea más limpio y legible.
class _TabDef {
  final IconData icon;
  final String label;
  final String? badge; // null = sin badge; String = muestra el valor en rojo
  const _TabDef({required this.icon, required this.label, this.badge});
}

/// Definición de un ítem del bottom nav: solo ícono y etiqueta.
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
