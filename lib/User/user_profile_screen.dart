import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Core/Routes/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA DE PERFIL
// ─────────────────────────────────────────────────────────────────────────────

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);
  static const Color _green = Color(0xFF10B981);
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _lightBg = Color(0xFFF5F6FA);

  int _selectedTab = 0; // 0=Publicaciones 1=Guardados 2=Logros
  int _selectedNavTab = 3; // Perfil activo

  // Actividad semanal (L M X J V S D)
  final List<double> _weekActivity = [0.2, 0.6, 0.4, 0.9, 0.7, 1.0, 0.3];
  final List<String> _weekDays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _lightBg,
        body: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Fondo blanco para la sección principal
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [_buildProfileCard(), _buildStatsRow()],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Nivel y XP
                    Container(color: Colors.white, child: _buildLevelSection()),
                    const SizedBox(height: 8),
                    // Actividad semanal + métricas
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [_buildWeeklyActivity(), _buildMetricsRow()],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Acciones rápidas
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: _buildQuickActions(),
                    ),
                    const SizedBox(height: 8),
                    // Tabs + contenido
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [_buildContentTabBar(), _buildTabContent()],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Información
                    Container(color: Colors.white, child: _buildInfoSection()),
                    const SizedBox(height: 8),
                    // Footer
                    _buildFooter(),
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

  // ── Top bar ───────────────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1F2E), Color(0xFF2D1B3D), Color(0xFF1A2E3A)],
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.settings_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ── Profile card ──────────────────────────────────────────────────────────────

  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B4A), Color(0xFFFF4D2E)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'JP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  // Indicador online
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Juan Pérez',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A1F2E),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B4A), Color(0xFFFF4D2E)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                color: Colors.white,
                                size: 11,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'PRO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '@juanperez',
                      style: TextStyle(fontSize: 13, color: Color(0xFF8A8FA8)),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Apasionado por las mejores ofertas\n| Nivel 5 Experto | Bogotá.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF5A5F72),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Botón editar perfil
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () => HapticFeedback.lightImpact(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Editar Perfil',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    final stats = [
      _Stat('24', 'PROMOS'),
      _Stat('8.5K', 'VISTAS'),
      _Stat('1.2K', 'FANS'),
      _Stat('345', 'SIGUIENDO'),
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF0F1F5), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: stats.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          return Expanded(
            child: Container(
              decoration: i < stats.length - 1
                  ? const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Color(0xFFF0F1F5), width: 1),
                      ),
                    )
                  : null,
              child: Column(
                children: [
                  Text(
                    s.value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    s.label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF8A8FA8),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
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

  // ── Nivel y XP ───────────────────────────────────────────────────────────────

  Widget _buildLevelSection() {
    const currentXP = 1250.0;
    const nextXP = 1600.0;
    const pct = currentXP / nextXP;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.star_rounded, color: _amber, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Nivel 5 – Experto',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1F2E),
                      ),
                    ),
                    Text(
                      '750 XP para Nivel 6',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8A8FA8)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    '1,250',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),
                  Text(
                    'XP Total',
                    style: TextStyle(fontSize: 11, color: Color(0xFF8A8FA8)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: const Color(0xFFF0F1F5),
              valueColor: AlwaysStoppedAnimation<Color>(_amber),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Text(
                '82.5%',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF8A8FA8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Actividad semanal ─────────────────────────────────────────────────────────

  Widget _buildWeeklyActivity() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Actividad Semanal',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1F2E),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 14,
                    color: Color(0xFF8A8FA8),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '7 días',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF8A8FA8)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final h = _weekActivity[i];
              final isToday = i == 5; // sábado = hoy simulado
              return Column(
                children: [
                  SizedBox(
                    height: 48,
                    width: 28,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 400 + i * 50),
                          curve: Curves.easeOutCubic,
                          width: 20,
                          height: 48 * h,
                          decoration: BoxDecoration(
                            color: isToday
                                ? _primary
                                : _primary.withOpacity(0.2 + h * 0.4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _weekDays[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                      color: isToday ? _primary : const Color(0xFFB0B5CC),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Métricas ──────────────────────────────────────────────────────────────────

  Widget _buildMetricsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          _metricCard(
            icon: Icons.visibility_outlined,
            iconColor: const Color(0xFF3B82F6),
            value: '8.5K',
            label: 'VISTAS',
            bgColor: const Color(0xFFEFF6FF),
          ),
          const SizedBox(width: 10),
          _metricCard(
            icon: Icons.favorite_border_rounded,
            iconColor: _primary,
            value: '2.1K',
            label: 'LIKES',
            bgColor: const Color(0xFFFFF1EF),
          ),
          const SizedBox(width: 10),
          _metricCard(
            icon: Icons.share_outlined,
            iconColor: _green,
            value: '456',
            label: 'SHARES',
            bgColor: const Color(0xFFECFDF5),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A1F2E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9.5,
                color: Color(0xFF8A8FA8),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Acciones rápidas ──────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        icon: Icons.notifications_outlined,
        label: 'Alertas',
        color: const Color(0xFF3B82F6),
        bgColor: const Color(0xFFEFF6FF),
        badge: '3',
      ),
      _QuickAction(
        icon: Icons.history_rounded,
        label: 'Historial',
        color: _green,
        bgColor: const Color(0xFFECFDF5),
        badge: null,
      ),
      _QuickAction(
        icon: Icons.headset_mic_outlined,
        label: 'Soporte',
        color: _primary,
        bgColor: const Color(0xFFFFF1EF),
        badge: null,
      ),
    ];

    return Row(
      children: actions.asMap().entries.map((e) {
        final a = e.value;
        return Expanded(
          child: GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Container(
              margin: EdgeInsets.only(
                right: e.key < actions.length - 1 ? 10 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: a.bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(a.icon, color: a.color, size: 26),
                      if (a.badge != null)
                        Positioned(
                          top: -6,
                          right: -10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              a.badge!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Content tab bar ───────────────────────────────────────────────────────────

  Widget _buildContentTabBar() {
    final tabs = ['Publicaciones', 'Guardados', 'Logros'];

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F1F5), width: 1)),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTab = i);
                HapticFeedback.selectionClick();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? _primary : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                    color: isActive ? _primary : const Color(0xFFB0B5CC),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildPublicaciones();
      case 1:
        return _buildGuardados();
      case 2:
        return _buildLogros();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPublicaciones() {
    final posts = [
      _PostItem(
        title: '50% OFF Nike',
        category: 'Deportes',
        categoryColor: const Color(0xFF3B82F6),
        views: '1,234',
        likes: '89',
        emoji: '👟',
      ),
      _PostItem(
        title: '2x1 Burgers',
        category: 'Comida',
        categoryColor: _primary,
        views: '892',
        likes: '56',
        emoji: '🍔',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.2,
        children: posts.map((p) => _buildPostCard(p)).toList(),
      ),
    );
  }

  Widget _buildPostCard(_PostItem p) {
    return Container(
      decoration: BoxDecoration(
        color: p.categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          Center(child: Text(p.emoji, style: const TextStyle(fontSize: 40))),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: p.categoryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                p.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Row(
              children: [
                Text(
                  p.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1F2E),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          Positioned(
            bottom: 28,
            left: 8,
            child: Row(
              children: [
                const Icon(
                  Icons.visibility_outlined,
                  size: 11,
                  color: Color(0xFF8A8FA8),
                ),
                const SizedBox(width: 3),
                Text(
                  p.views,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8A8FA8),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.favorite_border_rounded,
                  size: 11,
                  color: Color(0xFF8A8FA8),
                ),
                const SizedBox(width: 3),
                Text(
                  p.likes,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8A8FA8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuardados() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          children: const [
            SizedBox(height: 20),
            Text('❤️', style: TextStyle(fontSize: 40)),
            SizedBox(height: 10),
            Text(
              'Tus guardados',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1F2E),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Accede desde "Mis Favoritos"',
              style: TextStyle(fontSize: 13, color: Color(0xFF8A8FA8)),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogros() {
    final badges = [
      _Badge(
        emoji: '🏆',
        title: 'Primera promo',
        sub: 'Publicaste tu primera promo',
        done: true,
      ),
      _Badge(
        emoji: '🔥',
        title: 'En racha',
        sub: '7 días activo seguidos',
        done: true,
      ),
      _Badge(
        emoji: '⭐',
        title: 'Nivel 5',
        sub: 'Alcanzaste nivel Experto',
        done: true,
      ),
      _Badge(
        emoji: '👑',
        title: 'Top Creator',
        sub: '1K seguidores',
        done: false,
      ),
      _Badge(
        emoji: '💎',
        title: 'Nivel 6',
        sub: 'Alcanza nivel Maestro',
        done: false,
      ),
      _Badge(
        emoji: '🚀',
        title: 'Viral',
        sub: '10K vistas en una promo',
        done: false,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: badges.map((b) => _buildBadgeCard(b)).toList(),
      ),
    );
  }

  Widget _buildBadgeCard(_Badge b) {
    return Container(
      decoration: BoxDecoration(
        color: b.done ? const Color(0xFFFFF8E1) : const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: b.done ? const Color(0xFFFFE082) : const Color(0xFFE8EAF0),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            b.emoji,
            style: TextStyle(
              fontSize: 28,
              color: b.done ? null : const Color(0xFFCDD0DB),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            b.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: b.done ? const Color(0xFF1A1F2E) : const Color(0xFFB0B5CC),
            ),
          ),
          if (!b.done)
            const Padding(
              padding: EdgeInsets.only(top: 3),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 12,
                color: Color(0xFFCDD0DB),
              ),
            ),
        ],
      ),
    );
  }

  // ── Información ───────────────────────────────────────────────────────────────

  Widget _buildInfoSection() {
    final items = [
      _InfoItem(
        icon: Icons.info_outline_rounded,
        label: 'Acerca de PromoMap',
        color: const Color(0xFF8A8FA8),
      ),
      _InfoItem(
        icon: Icons.description_outlined,
        label: 'Términos y Condiciones',
        color: _green,
      ),
      _InfoItem(
        icon: Icons.privacy_tip_outlined,
        label: 'Política de Privacidad',
        color: _primary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: _primary, size: 16),
              SizedBox(width: 6),
              Text(
                'Información',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1F2E),
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildInfoRow(item)).toList(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF5F6FA), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1F2E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFB0B5CC),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(
            'PromoMap v1.0.0',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB0B5CC),
            ),
          ),
          SizedBox(height: 4),
          Text(
            '© 2025, Inc. Derechos reservados.',
            style: TextStyle(fontSize: 11, color: Color(0xFFCDD0DB)),
          ),
        ],
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────────

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
                      i == 3 && isActive ? Icons.person_rounded : tabs[i].icon,
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

class _Stat {
  final String value;
  final String label;
  const _Stat(this.value, this.label);
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final String? badge;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    this.badge,
  });
}

class _PostItem {
  final String title;
  final String category;
  final Color categoryColor;
  final String views;
  final String likes;
  final String emoji;
  const _PostItem({
    required this.title,
    required this.category,
    required this.categoryColor,
    required this.views,
    required this.likes,
    required this.emoji,
  });
}

class _Badge {
  final String emoji;
  final String title;
  final String sub;
  final bool done;
  const _Badge({
    required this.emoji,
    required this.title,
    required this.sub,
    required this.done,
  });
}

class _InfoItem {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class _NavTab {
  final IconData icon;
  final String label;
  const _NavTab({required this.icon, required this.label});
}
