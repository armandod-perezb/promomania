import 'package:flutter/material.dart';
import '../Core/Routes/app_routes.dart';
import '../main.dart';

/// Pantalla principal del panel administrativo.
/// Muestra métricas clave, actividad reciente y accesos rápidos a las
/// funciones más importantes de la app (usuarios, promos, comercios).
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Índice del tab activo en la barra de navegación inferior (empieza en 0 = Panel).
  int _selectedIndex = 0;

  // ── Paleta de colores centralizada para reutilizarla en toda la pantalla ──
  static const Color primaryOrange = Color(0xFFFF5733);       // Color principal de la marca
  static const Color lightOrange = Color(0xFFFF7755);         // Variante más clara del naranja
  static const Color darkBg = Color(0xFF1A1A2E);              // Fondo oscuro (cards oscuras)
  static const Color cardBg = Color(0xFFFFFFFF);              // Fondo blanco de las cards
  static const Color textDark = Color(0xFF1A1A2E);            // Texto principal (casi negro)
  static const Color textGray = Color(0xFF8A8A9A);            // Texto secundario (gris)
  static const Color greenAccent = Color(0xFF2ECC71);         // Verde para métricas positivas
  static const Color greenLight = Color(0xFFE8F8F0);          // Fondo suave para badges verdes

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder escucha los cambios del promoService (ChangeNotifier).
    // Cada vez que promoService notifica (se agrega/edita un dato),
    // Flutter reconstruye automáticamente todo el dashboard con los datos actualizados.
    return AnimatedBuilder(
      animation: promoService,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F8), // Fondo gris muy suave de la pantalla
          body: SafeArea(
            // SafeArea evita que el contenido quede tapado por la cámara o la barra del sistema
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    // Permite hacer scroll vertical cuando el contenido es mayor que la pantalla
                    child: Column(
                      children: [
                        _buildHeader(),             // Encabezado con KPIs y saludo
                        const SizedBox(height: 16),
                        _buildMetricsGrid(),        // Cuadrícula de 4 métricas
                        const SizedBox(height: 16),
                        _buildWeeklyRevenueChart(), // Gráfica de ingresos de la semana
                        const SizedBox(height: 16),
                        _buildTopUsers(),           // Lista de usuarios más activos
                        const SizedBox(height: 16),
                        _buildTopStores(),          // Lista de comercios con más promos
                        const SizedBox(height: 16),
                        _buildGeoDistribution(),    // Distribución por ciudad con barras
                        const SizedBox(height: 16),
                        _buildRecentActivity(),     // Feed de eventos recientes
                        const SizedBox(height: 16),
                        _buildQuickActions(),       // Botones de acción rápida
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                // La barra de navegación queda fija en la parte inferior, fuera del scroll
                _buildBottomNav(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── HEADER ─────────────────────────────────────────────────────────────────

  /// Construye el encabezado degradado naranja con:
  /// - Barra superior (título + notificaciones + avatar)
  /// - Saludo personalizado
  /// - Tres estadísticas en vivo (usuarios, promos, comercios)
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        // Degradado de izquierda a derecha entre los dos tonos de naranja
        gradient: LinearGradient(
          colors: [primaryOrange, lightOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // Solo redondea las esquinas inferiores para que se vea como una "cabecera"
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Fila superior: título + botones de acción ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Panel de Control',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  _headerIconBtn(Icons.notifications_outlined), // Ícono de campana
                  const SizedBox(width: 10),
                  // Avatar "A" que lleva al perfil de usuario
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.userProfile),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Bienvenido, Admin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // ── Fila de KPIs: los valores vienen en tiempo real del promoService ──
          Row(
            children: [
              _headerStat(
                Icons.people_outline,
                promoService.usuarios.length.toString(),     // Cantidad real de usuarios
                'Usuarios',
                '+50%',
              ),
              const SizedBox(width: 12),
              _headerStat(
                Icons.confirmation_number_outlined,
                promoService.promociones.length.toString(),  // Cantidad real de tickets
                'Tickets',
                '+32%',
              ),
              const SizedBox(width: 12),
              _headerStat(
                Icons.attach_money,
                '\$4.2M',                                     // Revenue
                'Revenue',
                '+32%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Botón redondo con ícono para la barra superior del header.
  Widget _headerIconBtn(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white24,                    // Blanco translúcido
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  /// Mini-card de estadística usada dentro del header.
  /// Recibe: ícono, valor numérico, etiqueta y badge de tendencia.
  Widget _headerStat(IconData icon, String value, String label, String badge) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Ícono en la izquierda
            Icon(icon, color: primaryOrange, size: 24),
            const SizedBox(width: 8),
            // Valor y label en el centro
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: textGray,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // Badge de tendencia en la derecha
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: greenAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up, color: greenAccent, size: 10),
                  const SizedBox(width: 2),
                  Text(
                    badge,
                    style: const TextStyle(
                      color: greenAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── METRICS GRID ────────────────────────────────────────────────────────────

  /// Cuadrícula 2×2 con métricas secundarias: Conversión, Engagement,
  /// Comercios activos y Rating de satisfacción.
  Widget _buildMetricsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Primera fila: Conversión | Engagement
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  icon: Icons.show_chart,
                  iconColor: primaryOrange,
                  iconBg: const Color(0xFFFFF0ED),  // Fondo naranja muy claro
                  value: '68%',
                  label: 'Conversión',
                  sublabel: 'Tasa de canje',
                  badge: '+5.2%',
                  badgeColor: primaryOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metricCard(
                  icon: Icons.multiline_chart,
                  iconColor: textDark,
                  iconBg: textDark,                 // Card con fondo oscuro (variante)
                  iconColorOverride: Colors.white,  // Ícono blanco sobre fondo oscuro
                  value: '8.4',
                  label: 'Engagement',
                  sublabel: 'Promos/Usuario',
                  badge: '+12%',
                  badgeColor: primaryOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Segunda fila: Comercios | Rating
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  icon: Icons.storefront,
                  iconColor: greenAccent,
                  iconBg: greenLight,
                  value: promoService.supermercados.length.toString(), // Dato en tiempo real
                  label: 'Comercios',
                  sublabel: 'Activos ahora',
                  badge: '+2',
                  badgeColor: primaryOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metricCard(
                  icon: Icons.star_outline,
                  iconColor: const Color(0xFFF5A623),
                  iconBg: const Color(0xFFFFF8ED),
                  value: '4.8',
                  label: 'Rating',
                  sublabel: 'Satisfacción',
                  badge: '+0.3',
                  badgeColor: primaryOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card individual de métrica.
  /// [iconColorOverride] permite forzar un color de ícono distinto al del fondo.
  Widget _metricCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    Color? iconColorOverride,   // Opcional: sobreescribe el color del ícono
    required String value,
    required String label,
    required String sublabel,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          // Sombra suave para dar sensación de elevación
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ícono con fondo de color
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColorOverride ?? iconColor, // ?? = usa override si existe
                  size: 20,
                ),
              ),
              // Badge de tendencia (ej. "+5.2%") con ícono de flecha
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, color: badgeColor, size: 11),
                    const SizedBox(width: 2),
                    Text(
                      badge,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Valor principal grande
          Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: textDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(sublabel, style: const TextStyle(color: textGray, fontSize: 11)),
        ],
      ),
    );
  }

  // ─── WEEKLY REVENUE CHART ────────────────────────────────────────────────────

  /// Gráfica de línea de ingresos de los últimos 7 días.
  /// El dibujo real lo hace el CustomPainter [_LineChartPainter] al final del archivo.
  Widget _buildWeeklyRevenueChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Encabezado de la gráfica ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ingresos Semanales',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Últimos 7 días  •  COP \$15.2M total',
                      style: const TextStyle(color: textGray, fontSize: 12),
                    ),
                  ],
                ),
                // Ícono decorativo de tendencia
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: primaryOrange,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ── Área del canvas donde se dibuja la gráfica ──
            SizedBox(
              height: 120,
              child: CustomPaint(
                painter: _LineChartPainter(), // CustomPainter definido al final del archivo
                size: Size.infinite,          // Ocupa todo el ancho disponible
              ),
            ),
            const SizedBox(height: 8),
            // ── Etiquetas de los días de la semana bajo la gráfica ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']
                  .map(
                    (d) => Text(
                      d,
                      style: const TextStyle(color: textGray, fontSize: 11),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TOP USERS ───────────────────────────────────────────────────────────────

  /// Lista de los 3 usuarios con más actividad en la plataforma.
  /// Los datos son estáticos de ejemplo (en producción vendrían del backend).
  Widget _buildTopUsers() {
    // Lista de mapas con la info de cada usuario top
    final users = [
      {
        'name': 'Luis Herrera',
        'tickets': '39 tickets',
        'badge': '+12%',
        'color': primaryOrange,
      },
      {
        'name': 'Carlos López',
        'tickets': '54 tickets',
        'badge': '+8%',
        'color': const Color(0xFF3498DB), // Azul
      },
      {
        'name': 'Sofía Ramírez',
        'tickets': '37 tickets',
        'badge': '+15%',
        'color': greenAccent,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Encabezado de la sección ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: primaryOrange,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Top Usuarios',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right, color: textGray), // Flecha "ver más"
              ],
            ),
            const SizedBox(height: 16),
            // Genera una fila por cada usuario usando spread operator (...)
            ...users.map(
              (u) => _userRow(
                name: u['name'] as String,
                sub: u['tickets'] as String,
                badge: u['badge'] as String,
                color: u['color'] as Color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fila individual de usuario con avatar, nombre, subtítulo y badge de crecimiento.
  Widget _userRow({
    required String name,
    required String sub,
    required String badge,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          // Avatar circular con la inicial del nombre
          CircleAvatar(
            radius: 20,
            backgroundColor: color,
            child: Text(
              name[0], // Primera letra del nombre
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(sub, style: const TextStyle(color: textGray, fontSize: 12)),
              ],
            ),
          ),
          // Badge verde de crecimiento (ej. "+12%")
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: greenLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.trending_up, color: greenAccent, size: 12),
                const SizedBox(width: 3),
                Text(
                  badge,
                  style: const TextStyle(
                    color: greenAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── TOP STORES ──────────────────────────────────────────────────────────────

  /// Lista de los 3 comercios con más promociones activas.
  Widget _buildTopStores() {
    final stores = [
      {'name': 'Sport Zone',    'city': 'Cali',     'count': '15', 'badge': '+23%'},
      {'name': 'TechStore',     'city': 'Bogotá',   'count': '12', 'badge': '+18%'},
      {'name': 'Pizza Express', 'city': 'Medellín', 'count': '8',  'badge': '+10%'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        color: primaryOrange,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Top Comercios',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right, color: textGray),
              ],
            ),
            const SizedBox(height: 16),
            ...stores.map(
              (s) => _storeRow(
                name: s['name']!,
                city: s['city']!,
                count: s['count']!,
                badge: s['badge']!,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fila individual de comercio: logo con inicial, nombre/ciudad, conteo y badge.
  Widget _storeRow({
    required String name,
    required String city,
    required String count,
    required String badge,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          // Cuadrado oscuro con la inicial del comercio (simula logo)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: textDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                name[0], // Primera letra del nombre del comercio
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Ciudad con ícono de pin de ubicación
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 11, color: textGray),
                    const SizedBox(width: 2),
                    Text(city, style: const TextStyle(color: textGray, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          // Número de promociones del comercio
          Text(
            count,
            style: const TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          // Badge de porcentaje de crecimiento
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: greenLight,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: greenAccent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── GEO DISTRIBUTION ────────────────────────────────────────────────────────

  /// Muestra cuántos comercios y usuarios hay por ciudad,
  /// con una barra de progreso proporcional al total.
  Widget _buildGeoDistribution() {
    // Cada mapa representa una ciudad con su porcentaje (pct) del total
    final cities = [
      {
        'city': 'Bogotá',
        'stores': '12 tiendas',
        'users': '245 usuarios',
        'pct': 0.40,           // 40% del total
        'color': primaryOrange,
      },
      {
        'city': 'Medellín',
        'stores': '8 tiendas',
        'users': '189 usuarios',
        'pct': 0.27,
        'color': const Color(0xFF2C3E50),
      },
      {
        'city': 'Cali',
        'stores': '6 tiendas',
        'users': '156 usuarios',
        'pct': 0.20,
        'color': greenAccent,
      },
      {
        'city': 'Barranquilla',
        'stores': '4 tiendas',
        'users': '98 usuarios',
        'pct': 0.13,
        'color': const Color(0xFFF5A623),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: greenLight,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: greenAccent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Distribución Geográfica',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Genera una fila por cada ciudad
            ...cities.map(
              (c) => _geoRow(
                city: c['city'] as String,
                stores: c['stores'] as String,
                users: c['users'] as String,
                pct: c['pct'] as double,
                color: c['color'] as Color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fila geográfica: nombre de ciudad, datos y barra de progreso coloreada.
  Widget _geoRow({
    required String city,
    required String stores,
    required String users,
    required double pct,   // Valor entre 0.0 y 1.0
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Punto de color + nombre de ciudad
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    city,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Datos y porcentaje a la derecha
              Row(
                children: [
                  Text(
                    '$stores  •  $users',
                    style: const TextStyle(color: textGray, fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(pct * 100).toInt()}%', // Convierte 0.40 → "40%"
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Barra de progreso coloreada proporcional al porcentaje
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: const Color(0xFFF0F0F5),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── RECENT ACTIVITY ─────────────────────────────────────────────────────────

  /// Feed de los últimos eventos del sistema: canjes, creaciones,
  /// visualizaciones y expiraciones de promociones.
  Widget _buildRecentActivity() {
    final activities = [
      {
        'text': 'María García',
        'action': 'canjeó',
        'detail': '2×1 Pizzas',
        'time': 'hace 2h',
        'color': greenAccent,
        'icon': Icons.swap_horiz,           // Ícono de canje
      },
      {
        'text': 'Carlos López',
        'action': 'creó',
        'detail': '30% Laptops HP',
        'time': 'hace 5h',
        'color': const Color(0xFF3498DB),
        'icon': Icons.add_circle_outline,   // Ícono de creación
      },
      {
        'text': 'Ana Martínez',
        'action': 'vio',
        'detail': '50% Zapatillas',
        'time': 'hace 10h',
        'color': textGray,
        'icon': Icons.visibility_outlined,  // Ícono de vista
      },
      {
        'text': 'Sistema',
        'action': 'expiró',
        'detail': 'Oferta Flash',
        'time': 'hace 15h',
        'color': const Color(0xFFF5A623),
        'icon': Icons.timer_off_outlined,   // Ícono de expiración
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.bolt, color: primaryOrange, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Actividad Reciente',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Botón "Ver todo" (sin navegación implementada aún)
                const Text(
                  'Ver todo',
                  style: TextStyle(
                    color: primaryOrange,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...activities.map(
              (a) => _activityRow(
                name: a['text'] as String,
                action: a['action'] as String,
                detail: a['detail'] as String,
                time: a['time'] as String,
                color: a['color'] as Color,
                icon: a['icon'] as IconData,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fila de evento: ícono coloreado + texto enriquecido (nombre + acción + detalle) + hora.
  Widget _activityRow({
    required String name,
    required String action,
    required String detail,
    required String time,
    required Color color,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Círculo con ícono semitransparente del color del evento
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          // RichText permite combinar estilos distintos en una sola línea de texto
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: textDark),
                children: [
                  TextSpan(
                    text: name,
                    style: const TextStyle(fontWeight: FontWeight.w600), // Nombre en negrita
                  ),
                  TextSpan(text: ' $action '),                           // Acción normal
                  TextSpan(
                    text: detail,
                    style: const TextStyle(fontWeight: FontWeight.w600), // Detalle en negrita
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Hora relativa (ej. "hace 2h")
          Text(time, style: const TextStyle(color: textGray, fontSize: 11)),
        ],
      ),
    );
  }

  // ─── QUICK ACTIONS ────────────────────────────────────────────────────────────

  /// Panel de acciones rápidas con fondo oscuro.
  /// Cada botón navega directamente a la pantalla correspondiente.
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: textDark,                  // Fondo oscuro para contrastar con el resto
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, color: primaryOrange, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Acciones Rápidas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Navega a gestión de usuarios
                _quickActionBtn(
                  icon: Icons.person_add_outlined,
                  label: 'Nuevo\nUsuario',
                  color: primaryOrange,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.manageUsers),
                ),
                // Navega a gestión de promociones
                _quickActionBtn(
                  icon: Icons.local_offer_outlined,
                  label: 'Crear\nPromo',
                  color: greenAccent,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.managePromotions),
                ),
                // Navega a gestión de notificaciones
                _quickActionBtn(
                  icon: Icons.notifications_outlined,
                  label: 'Notificar',
                  color: const Color(0xFFF5A623),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.manageNotifications),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Botón de acción rápida: ícono grande + etiqueta debajo.
  Widget _quickActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap, // Callback opcional; si es null el botón no hace nada
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.3, // Interlineado para el salto de línea del label
            ),
          ),
        ],
      ),
    );
  }

  // ─── NAVEGACIÓN ──────────────────────────────────────────────────────────────

  /// Devuelve la ruta correspondiente al índice del tab seleccionado.
  String _routeForIndex(int index) {
    switch (index) {
      case 0: return AppRoutes.adminDashboard;
      case 1: return AppRoutes.manageUsers;
      case 2: return AppRoutes.managePromotions;
      case 3: return AppRoutes.manageStores;
      default: return AppRoutes.manageNotifications;
    }
  }

  /// Maneja el tap en un tab de la barra inferior.
  /// Si el tab ya está activo no hace nada (evita recargar la misma pantalla).
  void _onBottomNavTap(int index) {
    if (index == _selectedIndex) return; // No navega si ya estás ahí
    Navigator.pushReplacementNamed(context, _routeForIndex(index));
  }

  // ─── BOTTOM NAV ──────────────────────────────────────────────────────────────

  /// Barra de navegación inferior con 5 tabs animados.
  /// El tab activo se resalta con fondo naranja translúcido y texto naranja.
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.dashboard,             'label': 'Panel'},
      {'icon': Icons.people_outline,        'label': 'Usuarios'},
      {'icon': Icons.local_offer_outlined,  'label': 'Promos'},
      {'icon': Icons.storefront_outlined,   'label': 'Comercios'},
      {'icon': Icons.notifications_outlined,'label': 'Avisos'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          // Sombra hacia arriba para separar la barra del contenido
          BoxShadow(color: Color(0x10000000), blurRadius: 12, offset: Offset(0, -2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == _selectedIndex; // ¿Es el tab activo?
          return GestureDetector(
            onTap: () => _onBottomNavTap(i),
            // AnimatedContainer anima suavemente el cambio de fondo al seleccionar
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                // Solo el tab activo tiene fondo naranja translúcido
                color: selected ? primaryOrange.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[i]['icon'] as IconData,
                    color: selected ? primaryOrange : textGray, // Color según estado
                    size: 22,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    items[i]['label'] as String,
                    style: TextStyle(
                      color: selected ? primaryOrange : textGray,
                      fontSize: 10,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
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

// ─── CUSTOM LINE CHART PAINTER ───────────────────────────────────────────────

/// CustomPainter que dibuja la gráfica de ingresos semanales directamente
/// sobre el Canvas de Flutter usando la API de dibujo de bajo nivel.
/// Se llama automáticamente cuando el widget necesita repintarse.
class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const orange = Color(0xFFFF5733);

    // ── Etiquetas del eje Y ──
    final yLabelStyle = TextStyle(color: Colors.grey.shade400, fontSize: 10);
    final yLabels = ['\$3.2\nM', '\$2.4\nM', '\$1.6\nM', '\$0.8\nM', '\$0.0\nM'];

    // Dibuja cada etiqueta del eje Y distribuida verticalmente
    for (int i = 0; i < yLabels.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: yLabels[i], style: yLabelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, i * (size.height / 4) - 6));
    }

    const leftPad = 40.0; // Espacio a la izquierda para las etiquetas del eje Y
    final w = size.width - leftPad; // Ancho útil de la gráfica
    final h = size.height;

    // ── Líneas de cuadrícula horizontales ──
    final gridPaint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = i * h / 4;
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);
    }

    // ── Puntos de datos normalizados entre 0.0 (mínimo) y 1.0 (máximo) ──
    final dataPoints = [0.25, 0.40, 0.30, 0.55, 0.50, 0.85, 0.70];

    // Convierte los valores normalizados a coordenadas de pantalla (Offset)
    final pts = List.generate(dataPoints.length, (i) {
      return Offset(
        leftPad + i * (w / (dataPoints.length - 1)), // X distribuido uniformemente
        h - dataPoints[i] * h,                        // Y invertido (0 = abajo en canvas)
      );
    });

    // ── Área rellena bajo la curva ──
    final fillPath = Path();
    fillPath.moveTo(pts[0].dx, h);      // Empieza en la base del primer punto
    fillPath.lineTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      // Curva cúbica de Bézier para suavizar la línea entre puntos
      final cp1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }
    fillPath.lineTo(pts.last.dx, h); // Baja al borde inferior
    fillPath.close();

    // Pinta el relleno con un degradado vertical naranja → transparente
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [orange.withOpacity(0.25), orange.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // ── Línea de la curva ──
    final linePath = Path();
    linePath.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      // Misma lógica de Bézier para que la línea sea suave
      final cp1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = orange
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke // Solo el borde, sin relleno
        ..strokeCap = StrokeCap.round,
    );

    // ── Puntos circulares sobre cada dato ──
    for (final p in pts) {
      canvas.drawCircle(p, 4, Paint()..color = orange);   // Círculo naranja exterior
      canvas.drawCircle(p, 2.5, Paint()..color = Colors.white); // Punto blanco interior
    }
  }

  /// Retorna false porque los datos de la gráfica son estáticos (no cambian).
  /// Si los datos fueran dinámicos, retornaría true para forzar el repintado.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}