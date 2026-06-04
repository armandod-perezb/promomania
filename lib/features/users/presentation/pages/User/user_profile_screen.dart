import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../Core/Routes/app_routes.dart';
import '../../../../../Core/di/app_scope.dart';
import '../../../../../features/promotions/domain/entities/promocion.dart';

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
  static const Color _green = Color(0xFF10B981);
  static const Color _lightBg = Color(0xFFF5F6FA);

  int _selectedTab = 0; // 0=Publicaciones 1=Guardados 2=Logros
  int _selectedNavTab = 3; // Perfil activo
  
  List<Promocion> _promocionesPublicadas = [];
  List<Promocion> _promocionesFavoritas = [];
  bool _cargandoPublicadas = false;
  bool _cargandoFavoritas = false;

  @override

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _lightBg,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 320,
                elevation: 0,
                scrolledUnderElevation: 0,
                pinned: true,
                floating: false,
                backgroundColor: _lightBg,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _buildProfileHeroCard(),
                  ),
                ),
                title: innerBoxIsScrolled
                    ? const Text(
                        'Perfil',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF131A2F),
                        ),
                      )
                    : null,
                centerTitle: innerBoxIsScrolled,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: _topCircleButton(
                        icon: Icons.settings_outlined,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.pushNamed(context, AppRoutes.userConfig);
                        },
                      ),
                    ),
                  ),
                ],
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Center(
                    child: _topCircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                ),
                toolbarHeight: 62,
              ),
            ];
          },
          body: ListView(
            padding: const EdgeInsets.all(0),
            children: [
              const SizedBox(height: 12),
              _buildLevelSection(),
              const SizedBox(height: 14),
              _buildMetricsRow(),
              const SizedBox(height: 14),
              _buildQuickActions(),
              const SizedBox(height: 10),
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
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ── Botón circular del top ────────────────────────────────────────────────────

  Widget _topCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }

  Widget _buildProfileHeroCard() {
    final usuario = sessionManager.usuarioActual;
    final nombreCompleto = usuario?.nombre ?? 'Usuario';
    final username = nombreCompleto.toLowerCase().replaceAll(' ', '');
    final email = usuario?.correo ?? '';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: _primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          usuario?.rol == 'admin'
                              ? Icons.admin_panel_settings_rounded
                              : Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nombreCompleto,
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                        if (usuario?.rol == 'admin')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1EC),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFFD5C6),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.admin_panel_settings_outlined,
                                  color: _primary,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'ADMIN',
                                  style: TextStyle(
                                    color: _primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@$username',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8A8FA8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$email\n| Miembro activo | Bogotá',
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB74D), Color(0xFFFF4D2E)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B4A).withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, AppRoutes.userEdit).then((_) {
                    setState(() {});
                  });
                },
                child: const Text(
                  'Editar Perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0xFFF0F1F5), height: 1),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(
                child: _ProfileStat(value: '24', label: 'PROMOS'),
              ),
              Expanded(
                child: _ProfileStat(value: '8.5K', label: 'VISTAS'),
              ),
              Expanded(
                child: _ProfileStat(value: '1.2K', label: 'FANS'),
              ),
              Expanded(
                child: _ProfileStat(value: '345', label: 'SIGUIENDO'),
              ),
            ],
          ),
        ],
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
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pushNamed(context, AppRoutes.userConfig);
            },
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
                Icons.settings_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Nivel y XP ───────────────────────────────────────────────────────────────

  Widget _buildLevelSection() {
    final usuario = sessionManager.usuarioActual;
    final nivel = usuario?.nivel ?? 1;
    final puntuacion = usuario?.puntuacion ?? 0;

    // Calcula cuántos puntos se necesitan para el siguiente nivel
    // Fórmula del backend: 200 * nivel
    final puntosParaSiguiente = 200 * nivel;

    // Calcula el progreso acumulado hasta el nivel actual
    int puntosAcumulados = 0;
    for (int i = 1; i < nivel; i++) {
      puntosAcumulados += 200 * i;
    }

    // Calcula cuántos puntos tiene en el nivel actual
    final puntosEnNivelActual = puntuacion - puntosAcumulados;
    final pct = (puntosEnNivelActual / puntosParaSiguiente).clamp(0.0, 1.0);

    // Etiquetas por nivel
    final Map<int, String> nivelLabels = {
      1: 'Nivel 1 – Principiante',
      2: 'Nivel 2 – Aprendiz',
      3: 'Nivel 3 – Intermedio',
      4: 'Nivel 4 – Avanzado',
      5: 'Nivel 5 – Experto',
      6: 'Nivel 6 – Maestro',
    };

    final nivelLabel = nivelLabels[nivel] ?? 'Nivel $nivel';
    final puntosRestantes = puntosParaSiguiente - puntosEnNivelActual;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFECEFF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFF4D2E), Color(0xFFFFC34D)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nivelLabel,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF131A2F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$puntosRestantes XP para Nivel ${nivel + 1}',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$puntuacion',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: _primary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'XP Total',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE1EA),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD54A), Color(0xFFFF4D2E)],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                child: Text(
                  '${(pct * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }



  // ── Métricas ──────────────────────────────────────────────────────────────────

  Widget _buildMetricsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Row(
        children: [
          _metricCard(
            icon: Icons.visibility_outlined,
            iconColor: const Color(0xFF3B82F6),
            value: '8.5K',
            label: 'VISTAS',
            bgColor: const Color(0xFFEFF6FF),
          ),
          const SizedBox(width: 12),
          _metricCard(
            icon: Icons.favorite_border_rounded,
            iconColor: const Color(0xFFEC4899),
            value: '2.1K',
            label: 'LIKES',
            bgColor: const Color(0xFFFFEEF8),
          ),
          const SizedBox(width: 12),
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
        padding: const EdgeInsets.fromLTRB(14, 20, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFECEFF5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF131A2F),
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: actions.asMap().entries.map((e) {
          final a = e.value;
          return Expanded(
            child: GestureDetector(
              onTap: () => HapticFeedback.lightImpact(),
              child: Container(
                margin: EdgeInsets.only(
                  right: e.key < actions.length - 1 ? 12 : 0,
                ),
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFECEFF5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: a.color,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: a.color.withValues(alpha: 0.28),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(a.icon, color: Colors.white, size: 30),
                        ),
                        if (a.badge != null)
                          Positioned(
                            top: -7,
                            right: -8,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                color: _primary,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                a.badge!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      a.label,
                      style: const TextStyle(
                        fontSize: 18,
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
      ),
    );
  }

  // ── Content tab bar ───────────────────────────────────────────────────────────

  Widget _buildContentTabBar() {
    final tabs = ['Publicaciones', 'Guardados', 'Logros'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F8),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE7E9F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFF6538), Color(0xFFF7BD45)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFFF7A3D,
                              ).withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.2,
                      fontWeight: FontWeight.w800,
                      color: isActive ? Colors.white : const Color(0xFF697184),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
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

  @override
  void initState() {
    super.initState();
    _cargarPromocionesPublicadas();
    _cargarPromocionesFavoritas();
  }

  Future<void> _cargarPromocionesPublicadas() async {
    final usuario = AppScope.sessionManager.usuarioActual;
    if (usuario == null) return;

    setState(() => _cargandoPublicadas = true);
    try {
      final promos = await AppScope.promotionsController.getPromotionsByUser(usuario.id);
      setState(() => _promocionesPublicadas = promos);
    } catch (e) {
      debugPrint('Error al cargar promociones: $e');
    } finally {
      setState(() => _cargandoPublicadas = false);
    }
  }

  Future<void> _cargarPromocionesFavoritas() async {
    final usuario = AppScope.sessionManager.usuarioActual;
    if (usuario == null) return;

    setState(() => _cargandoFavoritas = true);
    try {
      final favoritos = await AppScope.interactionsRepository.getFavoritosByUsuario(usuario.id);
      final promociones = <Promocion>[];
      for (final fav in favoritos) {
        final promo = AppScope.promotionsController.getPromotionByCodeSync(fav.codigoPromocion);
        if (promo != null) {
          promociones.add(promo);
        }
      }
      setState(() => _promocionesFavoritas = promociones);
    } catch (e) {
      debugPrint('Error al cargar favoritos: $e');
    } finally {
      setState(() => _cargandoFavoritas = false);
    }
  }

  Widget _buildPublicaciones() {
    if (_cargandoPublicadas) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(color: _primary),
        ),
      );
    }

    if (_promocionesPublicadas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: const [
              SizedBox(height: 20),
              Text('📢', style: TextStyle(fontSize: 40)),
              SizedBox(height: 10),
              Text(
                'Sin publicaciones',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1F2E),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Publica tu primera promoción',
                style: TextStyle(fontSize: 13, color: Color(0xFF8A8FA8)),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _promocionesPublicadas.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.88,
        ),
        itemBuilder: (context, index) => _buildPromoCard(_promocionesPublicadas[index]),
      ),
    );
  }

  Widget _buildPromoCard(Promocion promo) {
    final fotoUrl = promo.foto ?? 'https://via.placeholder.com/300x300?text=${promo.titulo}';
    
    return GestureDetector(
      onTap: () {
        // Navegar a detalle de promoción si es necesario
        debugPrint('Tap en promoción: ${promo.codigo}');
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              fotoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFF5F6FA),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Color(0xFF8A8FA8),
                  ),
                );
              },
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x22000000), Color(0xB5000000)],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${promo.descuento ?? 0}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 40,
              child: Text(
                promo.titulo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Row(
                children: [
                  const Icon(
                    Icons.remove_red_eye_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${promo.vistas}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${promo.precio.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuardados() {
    if (_cargandoFavoritas) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(color: _primary),
        ),
      );
    }

    if (_promocionesFavoritas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: const [
              SizedBox(height: 20),
              Text('❤️', style: TextStyle(fontSize: 40)),
              SizedBox(height: 10),
              Text(
                'Sin guardados',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1F2E),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Guarda tus promociones favoritas',
                style: TextStyle(fontSize: 13, color: Color(0xFF8A8FA8)),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _promocionesFavoritas.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.88,
        ),
        itemBuilder: (context, index) => _buildPromoCard(_promocionesFavoritas[index]),
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
        title: 'Nivel 1',
        sub: 'Alcanzaste nivel Principiante',
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
        route: AppRoutes.aboutUs,
      ),
      _InfoItem(
        icon: Icons.description_outlined,
        label: 'Términos y Condiciones',
        color: _green,
        route: AppRoutes.termsService,
      ),
      _InfoItem(
        icon: Icons.privacy_tip_outlined,
        label: 'Política de Privacidad',
        color: _primary,
        route: AppRoutes.privacyPolicy,
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
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pushNamed(context, item.route);
      },
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
    final usuario = sessionManager.usuarioActual;

    // Si el usuario es administrador, mostrar la barra de admin (navegación administrativa)
    if (usuario?.rol == 'admin') {
      final items = [
        {'icon': Icons.dashboard, 'label': 'Panel', 'route': AppRoutes.adminDashboard},
        {'icon': Icons.people_outline, 'label': 'Usuarios', 'route': AppRoutes.manageUsers},
        {'icon': Icons.local_offer_outlined, 'label': 'Promos', 'route': AppRoutes.managePromotions},
        {'icon': Icons.storefront_outlined, 'label': 'Comercios', 'route': AppRoutes.manageStores},
        {'icon': Icons.notifications_outlined, 'label': 'Avisos', 'route': AppRoutes.manageNotifications},
      ];

      final currentRoute = ModalRoute.of(context)?.settings.name;
      var selectedIndex = items.indexWhere((it) => it['route'] == currentRoute);
      if (selectedIndex < 0) selectedIndex = 0;

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
            final selected = i == selectedIndex;
            return GestureDetector(
              onTap: () {
                if (i == selectedIndex) return;
                Navigator.pushReplacementNamed(context, items[i]['route'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? _primary.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(items[i]['icon'] as IconData, color: selected ? _primary : const Color(0xFF8A8FA8), size: 22),
                    const SizedBox(height: 3),
                    Text(
                      items[i]['label'] as String,
                      style: TextStyle(
                        color: selected ? _primary : const Color(0xFF8A8FA8),
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

    // Barra de navegación estándar para usuarios
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
                      color: isActive ? _primary.withOpacity(0.1) : Colors.transparent,
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

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF8A8FA8),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    final positions = <Offset>[
      Offset(size.width * 0.18, size.height * 0.30),
      Offset(size.width * 0.42, size.height * 0.18),
      Offset(size.width * 0.56, size.height * 0.64),
      Offset(size.width * 0.72, size.height * 0.28),
      Offset(size.width * 0.78, size.height * 0.72),
      Offset(size.width * 0.87, size.height * 0.46),
    ];
    for (final pos in positions) {
      canvas.drawCircle(pos, 3.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
  final String route;
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _NavTab {
  final IconData icon;
  final String label;
  const _NavTab({required this.icon, required this.label});
}
