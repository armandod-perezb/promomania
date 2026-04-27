import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Core/Routes/app_routes.dart';
import '../main.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS
// ─────────────────────────────────────────────────────────────────────────────

enum _ActivityType { user, promo, store, system }

class _ActivityItem {
  final String actor;
  final String actorInitial;
  final Color actorColor;
  final String action;
  final String title;
  final List<String> details;
  final String time;
  final _ActivityType type;
  final String? badge;
  final Color? badgeColor;

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

class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({super.key});

  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends State<AdminAuditScreen>
    with TickerProviderStateMixin {
  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);
  static const Color _green = Color(0xFF10B981);
  static const Color _blue = Color(0xFF3B82F6);
  static const Color _purple = Color(0xFF8B5CF6);
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _pink = Color(0xFFEC4899);
  static const Color _lightBg = Color(0xFFF5F6FA);

  int _selectedTab = 0; // Actividad/Reportes/Alertas/Exportar
  int _selectedFilter = 0; // Todas/Usuarios/Promos/Comercios
  int _selectedNavTab = 4; // Avisos activo

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

  List<_ActivityItem> get _filtered {
    switch (_selectedFilter) {
      case 1:
        return _activities.where((a) => a.type == _ActivityType.user).toList();
      case 2:
        return _activities.where((a) => a.type == _ActivityType.promo).toList();
      case 3:
        return _activities.where((a) => a.type == _ActivityType.store).toList();
      default:
        return _activities;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _lightBg,
        body: Column(
          children: [
            _buildAdminTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          _buildPageHeader(),
                          _buildPushNotifCard(),
                          const SizedBox(height: 4),
                          _buildStatsRow(),
                          _buildTabBar(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          _buildFilterChips(),
                          _buildActivityHeader(),
                          _buildActivityList(),
                          _buildVerMas(),
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
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ── Admin top bar ─────────────────────────────────────────────────────────────

  Widget _buildAdminTopBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 10,
      ),
      child: Row(
        children: [
          // Logo
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROMOMANIA',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFB0B5CC),
                  letterSpacing: 1.2,
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
          const Spacer(),
          // Campana con badge
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
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
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
        ],
      ),
    );
  }

  // ── Page header ───────────────────────────────────────────────────────────────

  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
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
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
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
            Text(
              'Llega a tus usuarios en tiempo\nreal con mensajes personalizados',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            // Stats row dentro del card
            Row(
              children: [
                _darkStat('4.2K', '↑ +14%', 'Enviadas'),
                _darkStatDivider(),
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

  Widget _darkStat(
    String val,
    String change,
    String label, {
    bool highlight = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(
              color: highlight ? _amber : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            change,
            style: const TextStyle(
              color: Color(0xFF10B981),
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

  Widget _darkStatDivider() =>
      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1));

  // ── Stats row ─────────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    // Solo visible en tab Actividad
    return const SizedBox.shrink();
  }

  // ── Tab bar ───────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    final tabs = [
      _TabDef(icon: Icons.timeline_rounded, label: 'Actividad'),
      _TabDef(icon: Icons.bar_chart_rounded, label: 'Reportes'),
      _TabDef(icon: Icons.warning_amber_rounded, label: 'Alertas', badge: '3'),
      _TabDef(icon: Icons.download_outlined, label: 'Exportar'),
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F1F5), width: 1)),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = _selectedTab == i;
          final t = tabs[i];
          return Expanded(
            child: GestureDetector(
              onTap: () => _onAuditTabTap(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? _primary : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          t.icon,
                          size: 20,
                          color: isActive ? _primary : const Color(0xFFB0B5CC),
                        ),
                        if (t.badge != null)
                          Positioned(
                            top: -4,
                            right: -8,
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
                                t.badge!,
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

  Widget _buildFilterChips() {
    final filters = ['🔵 Todas', '👤 Usuarios', '🏷 Promos', '🏪 Comercios'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (i) {
            final isActive = _selectedFilter == i;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = i);
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
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

  Widget _buildActivityHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
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

  Widget _buildActivityList() {
    final items = _filtered;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return _buildActivityItem(item, isLast: isLast);
        }),
      ),
    );
  }

  Widget _buildActivityItem(_ActivityItem item, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Línea de tiempo
          SizedBox(
            width: 40,
            child: Column(
              children: [
                const SizedBox(height: 2),
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
          // Contenido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
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
                  // Caja del evento
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
                        if (item.details.isNotEmpty) ...[
                          const SizedBox(height: 5),
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

  Widget _buildVerMas() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: Container(
          width: double.infinity,
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

  Widget _buildBottomNav() {
    final tabs = [
      _NavItem(icon: Icons.dashboard_outlined, label: 'Panel'),
      _NavItem(icon: Icons.people_outline_rounded, label: 'Usuarios'),
      _NavItem(icon: Icons.local_offer_outlined, label: 'Promos'),
      _NavItem(icon: Icons.storefront_outlined, label: 'Comercios'),
      _NavItem(icon: Icons.notifications_outlined, label: 'Avisos'),
    ];

    return Container(
      height: 60 + MediaQuery.of(context).padding.bottom,
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
            onTap: () => _onBottomNavTap(i),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 62,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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

  void _onAuditTabTap(int index) {
    if (index == _selectedTab) return;
    HapticFeedback.selectionClick();
    Navigator.pushReplacementNamed(context, _notiRouteForTab(index));
  }

  void _onBottomNavTap(int index) {
    if (index == _selectedNavTab) return;
    HapticFeedback.selectionClick();
    Navigator.pushReplacementNamed(context, _routeForIndex(index));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS AUXILIARES
// ─────────────────────────────────────────────────────────────────────────────

class _TabDef {
  final IconData icon;
  final String label;
  final String? badge;
  const _TabDef({required this.icon, required this.label, this.badge});
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
