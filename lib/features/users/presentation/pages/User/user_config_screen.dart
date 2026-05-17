import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../../Core/Routes/app_routes.dart';
import '../../../../../Core/di/app_scope.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool promosNearby = true;
  bool urgentPromos = true;
  bool emailSummary = false;
  bool vibration = true;
  bool biometrics = true;
  bool privateProfile = false;
  bool backgroundLocation = false;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  // Plan Banner
                  _buildPlanBanner(),
                  const SizedBox(height: 24),

                  // CUENTA
                  _buildSectionTitle('CUENTA'),
                  const SizedBox(height: 8),
                  _buildCard([
                    _buildNavItem(
                      icon: Icons.person_outline,
                      iconColor: const Color(0xFF8E8E93),
                      iconBg: const Color(0xFFE5E5EA),
                      title: 'Editar perfil',
                      subtitle: 'Nombre, foto, bio',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.userEdit),
                    ),
                    _buildDivider(),
                    _buildNavItem(
                      icon: Icons.lock_outline,
                      iconColor: const Color(0xFFFF6B35),
                      iconBg: const Color(0xFFFFEDE6),
                      title: 'Cambiar contraseña',
                      subtitle: 'Última vez hace dos días',
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // NOTIFICACIONES
                  _buildSectionTitle('NOTIFICACIONES'),
                  const SizedBox(height: 8),
                  _buildCard([
                    _buildToggleItem(
                      icon: Icons.location_on_outlined,
                      iconColor: const Color(0xFFFF6B35),
                      iconBg: const Color(0xFFFFEDE6),
                      title: 'Promos cercanas',
                      subtitle: 'Alertas cuando hay una promo cerca',
                      value: promosNearby,
                      onChanged: (v) => setState(() => promosNearby = v),
                    ),
                    _buildDivider(),
                    _buildToggleItem(
                      icon: Icons.warning_amber_outlined,
                      iconColor: const Color(0xFFFF9500),
                      iconBg: const Color(0xFFFFF3E0),
                      title: 'Promos urgentes',
                      subtitle: 'Se acaban en menos de 1h',
                      value: urgentPromos,
                      onChanged: (v) => setState(() => urgentPromos = v),
                    ),
                    _buildDivider(),
                    _buildToggleItem(
                      icon: Icons.email_outlined,
                      iconColor: const Color(0xFF34C759),
                      iconBg: const Color(0xFFE8F8EC),
                      title: 'Resumen por email',
                      subtitle: 'Mejores promos de la semana',
                      value: emailSummary,
                      onChanged: (v) => setState(() => emailSummary = v),
                    ),
                    _buildDivider(),
                    _buildToggleItem(
                      icon: Icons.vibration,
                      iconColor: const Color(0xFFFF6B35),
                      iconBg: const Color(0xFFFFEDE6),
                      title: 'Vibración',
                      subtitle: 'Feedback háptico en acciones',
                      value: vibration,
                      onChanged: (v) => setState(() => vibration = v),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // PRIVACIDAD Y SEGURIDAD
                  _buildSectionTitle('PRIVACIDAD Y SEGURIDAD'),
                  const SizedBox(height: 8),
                  _buildCard([
                    _buildToggleItem(
                      icon: Icons.fingerprint,
                      iconColor: const Color(0xFFFF6B35),
                      iconBg: const Color(0xFFFFEDE6),
                      title: 'Biometría',
                      subtitle: 'Face ID / Huella para entrar',
                      value: biometrics,
                      onChanged: (v) => setState(() => biometrics = v),
                    ),
                    _buildDivider(),
                    _buildToggleItem(
                      icon: Icons.visibility_outlined,
                      iconColor: const Color(0xFF8E8E93),
                      iconBg: const Color(0xFFE5E5EA),
                      title: 'Perfil privado',
                      subtitle: 'Solo tus seguidores te ven',
                      value: privateProfile,
                      onChanged: (v) => setState(() => privateProfile = v),
                    ),
                    _buildDivider(),
                    _buildToggleItem(
                      icon: Icons.my_location_outlined,
                      iconColor: const Color(0xFF8E8E93),
                      iconBg: const Color(0xFFE5E5EA),
                      title: 'Ubicación en segundo plano',
                      subtitle: 'Mejora las sugerencias cercanas',
                      value: backgroundLocation,
                      onChanged: (v) => setState(() => backgroundLocation = v),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // PREFERENCIAS
                  _buildSectionTitle('PREFERENCIAS'),
                  const SizedBox(height: 8),
                  _buildCard([
                    _buildToggleItem(
                      icon: Icons.nightlight_round,
                      iconColor: Colors.white,
                      iconBg: const Color(0xFF1C1C1E),
                      title: 'Modo oscuro',
                      subtitle: 'Temática de la aplicación',
                      value: darkMode,
                      onChanged: (v) => setState(() => darkMode = v),
                    ),
                    _buildDivider(),
                    _buildNavItemWithValue(
                      icon: Icons.language,
                      iconColor: const Color(0xFF30B0C7),
                      iconBg: const Color(0xFFE3F6FA),
                      title: 'Idioma',
                      value: 'Español',
                    ),
                    _buildDivider(),
                    _buildNavItemWithValue(
                      icon: Icons.location_city_outlined,
                      iconColor: const Color(0xFF30B0C7),
                      iconBg: const Color(0xFFE3F6FA),
                      title: 'Ciudad',
                      value: 'Bogotá',
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // AYUDA Y LEGAL
                  _buildSectionTitle('AYUDA Y LEGAL'),
                  const SizedBox(height: 8),
                  _buildCard([
                    _buildNavItem(
                      icon: Icons.help_outline,
                      iconColor: const Color(0xFFFF6B35),
                      iconBg: const Color(0xFFFFEDE6),
                      title: 'Centro de ayuda',
                      subtitle: 'FAQs y tutoriales',
                    ),
                    _buildDivider(),
                    _buildNavItem(
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFF8E8E93),
                      iconBg: const Color(0xFFE5E5EA),
                      title: 'Términos y condiciones',
                    ),
                    _buildDivider(),
                    _buildNavItem(
                      icon: Icons.shield_outlined,
                      iconColor: const Color(0xFF8E8E93),
                      iconBg: const Color(0xFFE5E5EA),
                      title: 'Política de privacidad',
                    ),
                    _buildDivider(),
                    _buildNavItemWithValue(
                      icon: Icons.info_outline,
                      iconColor: const Color(0xFF8E8E93),
                      iconBg: const Color(0xFFE5E5EA),
                      title: 'Sobre Promomania',
                      value: 'v1.0.0',
                      showChevron: false,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ZONA DE PELIGRO
                  _buildSectionTitle('ZONA DE PELIGRO'),
                  const SizedBox(height: 8),
                  _buildCard([
                    _buildDangerItem(
                      icon: Icons.logout,
                      iconColor: const Color(0xFFFF6B35),
                      iconBg: const Color(0xFFFFEDE6),
                      title: 'Cerrar sesión',
                      titleColor: const Color(0xFFFF6B35),
                      onTap: () async {
                        await settingsController.logout();
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.login,
                            (route) => false,
                          );
                        }
                      },
                    ),
                    _buildDivider(),
                    _buildDangerItem(
                      icon: Icons.delete_outline,
                      iconColor: const Color(0xFFFF3B30),
                      iconBg: const Color(0xFFFFE5E5),
                      title: 'Eliminar cuenta',
                      subtitle: 'Esta acción es irreversible',
                      titleColor: const Color(0xFFFF3B30),
                    ),
                  ]),

                  const SizedBox(height: 32),

                  // Bottom Logo
                  _buildBottomLogo(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFF2F2F7),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Configuración',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Personaliza tu experiencia',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Plan Gratuito',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8E8E93).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'FREE',
                        style: TextStyle(
                          color: Color(0xFFAEAEB2),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Activa promos ilimitadas con Pro',
                  style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const [
                Icon(Icons.star, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8E8E93),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }

  Widget _buildIconContainer({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: iconBg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _buildIconContainer(
              icon: icon,
              iconColor: iconColor,
              iconBg: iconBg,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFC7C7CC), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItemWithValue({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String value,
    bool showChevron = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _buildIconContainer(icon: icon, iconColor: iconColor, iconBg: iconBg),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
          ),
          if (showChevron) ...[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Color(0xFFC7C7CC), size: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          _buildIconContainer(icon: icon, iconColor: iconColor, iconBg: iconBg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF6B35),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    String? subtitle,
    required Color titleColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            _buildIconContainer(
              icon: icon,
              iconColor: iconColor,
              iconBg: iconBg,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFC7C7CC), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomLogo() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'PromoMap',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Encuentra. Comparte. Ahorra.',
            style: TextStyle(fontSize: 11, color: Color(0xFF8E8E93)),
          ),
        ],
      ),
    );
  }
}
