import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  static const Color primaryOrange = Color(0xFFFF5733);
  static const Color lightOrange = Color(0xFFFF7755);
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGray = Color(0xFF8A8A9A);
  static const Color greenAccent = Color(0xFF2ECC71);
  static const Color greenLight = Color(0xFFE8F8F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildMetricsGrid(),
                    const SizedBox(height: 16),
                    _buildWeeklyRevenueChart(),
                    const SizedBox(height: 16),
                    _buildTopUsers(),
                    const SizedBox(height: 16),
                    _buildTopStores(),
                    const SizedBox(height: 16),
                    _buildGeoDistribution(),
                    const SizedBox(height: 16),
                    _buildRecentActivity(),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryOrange, lightOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar
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
                  _headerIconBtn(Icons.notifications_outlined),
                  const SizedBox(width: 10),
                  Container(
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
          // Stats row
          Row(
            children: [
              _headerStat(Icons.people_outline, '6', 'Usuarios', '+1 hoy'),
              const SizedBox(width: 12),
              _headerStat(Icons.confirmation_number_outlined, '140', 'Tickets', '+7 hoy'),
              const SizedBox(width: 12),
              _headerStat(Icons.attach_money, '\$4.2M', 'Revenue', '+18%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIconBtn(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _headerStat(IconData icon, String value, String label, String badge) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white70, size: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── METRICS GRID ────────────────────────────────────────────────────────────
  Widget _buildMetricsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  icon: Icons.show_chart,
                  iconColor: primaryOrange,
                  iconBg: const Color(0xFFFFF0ED),
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
                  iconBg: textDark,
                  iconColorOverride: Colors.white,
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
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  icon: Icons.storefront,
                  iconColor: greenAccent,
                  iconBg: greenLight,
                  value: '4',
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

  Widget _metricCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    Color? iconColorOverride,
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
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColorOverride ?? iconColor,
                  size: 20,
                ),
              ),
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
          Text(
            sublabel,
            style: const TextStyle(
              color: textGray,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ─── WEEKLY REVENUE CHART ────────────────────────────────────────────────────
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
                      style: const TextStyle(
                        color: textGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
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
            SizedBox(
              height: 120,
              child: CustomPaint(
                painter: _LineChartPainter(),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']
                  .map((d) => Text(
                        d,
                        style: const TextStyle(
                          color: textGray,
                          fontSize: 11,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TOP USERS ───────────────────────────────────────────────────────────────
  Widget _buildTopUsers() {
    final users = [
      {'name': 'Luis Herrera', 'tickets': '39 tickets', 'badge': '+12%', 'color': primaryOrange},
      {'name': 'Carlos López', 'tickets': '54 tickets', 'badge': '+8%', 'color': const Color(0xFF3498DB)},
      {'name': 'Sofía Ramírez', 'tickets': '37 tickets', 'badge': '+15%', 'color': greenAccent},
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
                      child: const Icon(Icons.person_outline, color: primaryOrange, size: 18),
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
                const Icon(Icons.chevron_right, color: textGray),
              ],
            ),
            const SizedBox(height: 16),
            ...users.map((u) => _userRow(
                  name: u['name'] as String,
                  sub: u['tickets'] as String,
                  badge: u['badge'] as String,
                  color: u['color'] as Color,
                )),
          ],
        ),
      ),
    );
  }

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
          CircleAvatar(
            radius: 20,
            backgroundColor: color,
            child: Text(
              name[0],
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
                Text(
                  sub,
                  style: const TextStyle(color: textGray, fontSize: 12),
                ),
              ],
            ),
          ),
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
  Widget _buildTopStores() {
    final stores = [
      {'name': 'Sport Zone', 'city': 'Cali', 'count': '15', 'badge': '+23%'},
      {'name': 'TechStore', 'city': 'Bogotá', 'count': '12', 'badge': '+18%'},
      {'name': 'Pizza Express', 'city': 'Medellín', 'count': '8', 'badge': '+10%'},
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
                      child: const Icon(Icons.storefront_outlined, color: primaryOrange, size: 18),
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
            ...stores.map((s) => _storeRow(
                  name: s['name']!,
                  city: s['city']!,
                  count: s['count']!,
                  badge: s['badge']!,
                )),
          ],
        ),
      ),
    );
  }

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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: textDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                name[0],
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
          Text(
            count,
            style: const TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
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
  Widget _buildGeoDistribution() {
    final cities = [
      {'city': 'Bogotá', 'stores': '12 tiendas', 'users': '245 usuarios', 'pct': 0.40, 'color': primaryOrange},
      {'city': 'Medellín', 'stores': '8 tiendas', 'users': '189 usuarios', 'pct': 0.27, 'color': const Color(0xFF2C3E50)},
      {'city': 'Cali', 'stores': '6 tiendas', 'users': '156 usuarios', 'pct': 0.20, 'color': greenAccent},
      {'city': 'Barranquilla', 'stores': '4 tiendas', 'users': '98 usuarios', 'pct': 0.13, 'color': const Color(0xFFF5A623)},
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
                  child: const Icon(Icons.location_on_outlined, color: greenAccent, size: 18),
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
            ...cities.map((c) => _geoRow(
                  city: c['city'] as String,
                  stores: c['stores'] as String,
                  users: c['users'] as String,
                  pct: c['pct'] as double,
                  color: c['color'] as Color,
                )),
          ],
        ),
      ),
    );
  }

  Widget _geoRow({
    required String city,
    required String stores,
    required String users,
    required double pct,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              Row(
                children: [
                  Text(
                    '$stores  •  $users',
                    style: const TextStyle(color: textGray, fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(pct * 100).toInt()}%',
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
  Widget _buildRecentActivity() {
    final activities = [
      {
        'text': 'María García',
        'action': 'canjeó',
        'detail': '2×1 Pizzas',
        'time': 'hace 2h',
        'color': greenAccent,
        'icon': Icons.swap_horiz,
      },
      {
        'text': 'Carlos López',
        'action': 'creó',
        'detail': '30% Laptops HP',
        'time': 'hace 5h',
        'color': const Color(0xFF3498DB),
        'icon': Icons.add_circle_outline,
      },
      {
        'text': 'Ana Martínez',
        'action': 'vio',
        'detail': '50% Zapatillas',
        'time': 'hace 10h',
        'color': textGray,
        'icon': Icons.visibility_outlined,
      },
      {
        'text': 'Sistema',
        'action': 'expiró',
        'detail': 'Oferta Flash',
        'time': 'hace 15h',
        'color': const Color(0xFFF5A623),
        'icon': Icons.timer_off_outlined,
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
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: textDark),
                children: [
                  TextSpan(
                    text: name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' $action '),
                  TextSpan(
                    text: detail,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(color: textGray, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ─── QUICK ACTIONS ────────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: textDark,
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
                _quickActionBtn(
                  icon: Icons.person_add_outlined,
                  label: 'Nuevo\nUsuario',
                  color: primaryOrange,
                ),
                _quickActionBtn(
                  icon: Icons.local_offer_outlined,
                  label: 'Crear\nPromo',
                  color: greenAccent,
                ),
                _quickActionBtn(
                  icon: Icons.notifications_outlined,
                  label: 'Notificar',
                  color: const Color(0xFFF5A623),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionBtn({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
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
            height: 1.3,
          ),
        ),
      ],
    );
  }

  // ─── BOTTOM NAV ──────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.dashboard, 'label': 'Panel'},
      {'icon': Icons.people_outline, 'label': 'Usuarios'},
      {'icon': Icons.local_offer_outlined, 'label': 'Promos'},
      {'icon': Icons.storefront_outlined, 'label': 'Comercios'},
      {'icon': Icons.notifications_outlined, 'label': 'Avisos'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = i == _selectedIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? primaryOrange.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[i]['icon'] as IconData,
                    color: selected ? primaryOrange : textGray,
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
class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const orange = Color(0xFFFF5733);

    // Y-axis labels
    final yLabelStyle = TextStyle(color: Colors.grey.shade400, fontSize: 10);
    final yLabels = ['\$3.2\nM', '\$2.4\nM', '\$1.6\nM', '\$0.8\nM', '\$0.0\nM'];
    for (int i = 0; i < yLabels.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: yLabels[i], style: yLabelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, i * (size.height / 4) - 6));
    }

    const leftPad = 40.0;
    final w = size.width - leftPad;
    final h = size.height;

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = i * h / 4;
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);
    }

    // Data points (normalized 0-1)
    final dataPoints = [0.25, 0.40, 0.30, 0.55, 0.50, 0.85, 0.70];
    final pts = List.generate(dataPoints.length, (i) {
      return Offset(
        leftPad + i * (w / (dataPoints.length - 1)),
        h - dataPoints[i] * h,
      );
    });

    // Fill
    final fillPath = Path();
    fillPath.moveTo(pts[0].dx, h);
    fillPath.lineTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      final cp1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }
    fillPath.lineTo(pts.last.dx, h);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [orange.withOpacity(0.25), orange.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePath = Path();
    linePath.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      final cp1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = orange
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Dots
    for (final p in pts) {
      canvas.drawCircle(p, 4, Paint()..color = orange);
      canvas.drawCircle(p, 2.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}