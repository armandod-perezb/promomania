import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../Core/Routes/app_routes.dart';
import '../../../../../main.dart';
import '../../../domain/entities/usuario.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA EDITAR PERFIL
// ─────────────────────────────────────────────────────────────────────────────

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);
  static const Color _green = Color(0xFF10B981);
  static const Color _lightBg = Color(0xFFF5F6FA);

  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _professionCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _neighborhoodCtrl;
  late TextEditingController _instagramCtrl;
  late TextEditingController _websiteCtrl;

  static const int _bioMax = 140;

  // Intereses seleccionados
  final Set<String> _selectedInterests = {'Comida', 'Tech', 'Deportes'};
  final List<String> _allInterests = [
    'Comida',
    'Tech',
    'Moda',
    'Deportes',
    'Belleza',
    'Salud',
    'Viajes',
    'Hogar',
    'Mascotas',
    'Ocio',
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final usuario = sessionManager.usuarioActual;

    _nameCtrl = TextEditingController(text: usuario?.nombre ?? 'Usuario');
    _usernameCtrl = TextEditingController(
      text: usuario?.nombre.toLowerCase().replaceAll(' ', '') ?? '',
    );
    _professionCtrl = TextEditingController(text: 'Profesional');
    _bioCtrl = TextEditingController(text: '');
    _emailCtrl = TextEditingController(text: usuario?.correo ?? '');
    _phoneCtrl = TextEditingController(text: '');
    _cityCtrl = TextEditingController(text: 'Bogotá D.C.');
    _neighborhoodCtrl = TextEditingController(text: '');
    _instagramCtrl = TextEditingController(text: '');
    _websiteCtrl = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _professionCtrl.dispose();
    _bioCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _instagramCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    setState(() => _isSaving = true);

    try {
      final usuario = sessionManager.usuarioActual;
      if (usuario != null) {
        final usuarioActualizado = usuario.copyWith(
          nombre: _nameCtrl.text,
          correo: _emailCtrl.text,
        );
        await sessionManager.actualizarUsuario(usuarioActualizado);
        promoService.updateUsuario(usuarioActualizado);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Perfil actualizado exitosamente!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

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
                    _buildProfileHero(),
                    const SizedBox(height: 8),
                    _buildSection(
                      icon: Icons.badge_outlined,
                      title: 'Identidad pública',
                      child: _buildIdentidadSection(),
                    ),
                    const SizedBox(height: 8),
                    _buildSection(
                      icon: Icons.person_outline_rounded,
                      title: 'Sobre mí',
                      child: _buildSobreMiSection(),
                    ),
                    const SizedBox(height: 8),
                    _buildSection(
                      icon: Icons.contact_phone_outlined,
                      title: 'Contacto',
                      child: _buildContactoSection(),
                    ),
                    const SizedBox(height: 8),
                    _buildSection(
                      icon: Icons.location_on_outlined,
                      title: 'Ubicación',
                      child: _buildUbicacionSection(),
                    ),
                    const SizedBox(height: 8),
                    _buildSection(
                      icon: Icons.link_rounded,
                      title: 'Redes & links',
                      trailing: _optionalBadge(),
                      child: _buildRedesSection(),
                    ),
                    const SizedBox(height: 8),
                    _buildSection(
                      icon: Icons.interests_outlined,
                      title: 'Mis intereses',
                      trailing: _counterBadge(
                        '${_selectedInterests.length} sel.',
                      ),
                      child: _buildInteresesSection(),
                    ),
                    const SizedBox(height: 8),
                    _buildSection(
                      icon: Icons.manage_accounts_outlined,
                      title: 'Cuenta',
                      child: _buildCuentaSection(),
                    ),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
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
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 18,
      ),
      child: Row(
        children: [
          _buildTopCircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          _buildTopCircleButton(
            icon: Icons.settings_outlined,
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pushNamed(context, AppRoutes.userConfig);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.04),
          border: Border.all(color: Colors.white.withOpacity(0.14), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
  }

  // ── Hero con foto de perfil ────────────────────────────────────────────────────

  Widget _buildProfileHero() {
    final usuario = sessionManager.usuarioActual;
    final nombreCompleto = usuario?.nombre ?? 'Usuario';
    final username = nombreCompleto.toLowerCase().replaceAll(' ', '');

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Foto de portada
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Portada
              Container(
                height: 120,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A1F2E), Color(0xFF2D1B3D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decoración de fondo
                    Positioned(
                      right: 20,
                      top: 10,
                      child: Text(
                        '🎨',
                        style: TextStyle(
                          fontSize: 60,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Cambiar portada',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Avatar superpuesto
              Positioned(
                bottom: -36,
                left: 20,
                child: Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B4A), Color(0xFFFF4D2E)],
                        ),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.3),
                            blurRadius: 10,
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
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Info bajo el avatar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 46, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            nombreCompleto,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1F2E),
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF3B82F6),
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '@$username',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF8A8FA8),
                            ),
                          ),
                          const Text(
                            ' · ',
                            style: TextStyle(color: Color(0xFFB0B5CC)),
                          ),
                          const Text(
                            'Bogotá',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF8A8FA8),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('🇨🇴', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _amber.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFF59E0B),
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Nivel 5',
                                  style: TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8A8FA8).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.bolt_rounded,
                                  color: Color(0xFF8A8FA8),
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Plan Free',
                                  style: TextStyle(
                                    color: Color(0xFF8A8FA8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Donut de completitud
                Column(
                  children: [
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: 0.13,
                            strokeWidth: 5,
                            backgroundColor: const Color(0xFFF0F1F5),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              _primary,
                            ),
                          ),
                          const Text(
                            '13%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1F2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'COMPLETO',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8A8FA8),
                        letterSpacing: 0.5,
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

  static const Color _amber = Color(0xFFF59E0B);

  // ── Sección genérica ──────────────────────────────────────────────────────────

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1F2E),
                  ),
                ),
                if (trailing != null) ...[const Spacer(), trailing],
              ],
            ),
          ),
          child,
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Identidad pública ─────────────────────────────────────────────────────────

  Widget _buildIdentidadSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildLabeledField(
            label: 'NOMBRE COMPLETO',
            controller: _nameCtrl,
            hint: 'Tu nombre real',
            prefixIcon: Icons.person_outline_rounded,
            hint2: 'Así te verán en tus publicaciones',
          ),
          const SizedBox(height: 14),
          _buildLabeledField(
            label: 'USUARIO',
            controller: _usernameCtrl,
            hint: 'nombre_usuario',
            prefixIcon: Icons.alternate_email_rounded,
            hint2: 'Solo minúsculas, números, puntos y guión bajo',
            suffixIcon: Icons.check_circle_rounded,
            suffixColor: _green,
          ),
          const SizedBox(height: 14),
          _buildLabeledField(
            label: 'PROFESIÓN U OFICIO',
            controller: _professionCtrl,
            hint: 'Ej. Emprendedor, Diseñador, Foodie...',
            prefixIcon: Icons.work_outline_rounded,
            hint2: 'Ej. Emprendedor, Diseñador, Foodie...',
          ),
        ],
      ),
    );
  }

  // ── Sobre mí ──────────────────────────────────────────────────────────────────

  Widget _buildSobreMiSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BIOGRAFÍA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8A8FA8),
                  letterSpacing: 0.8,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${_bioCtrl.text.length}/$_bioMax',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF8A8FA8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.crop_square_rounded,
                    color: Color(0xFFB0B5CC),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _bioCtrl,
            maxLines: 4,
            maxLength: _bioMax,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1F2E)),
            decoration: InputDecoration(
              hintText: 'Cuéntanos qué tipo de promos publicas o buscas...',
              hintStyle: const TextStyle(
                color: Color(0xFFCDD0DB),
                fontSize: 13.5,
              ),
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFF5F6FA),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFE8EAF0),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFE8EAF0),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _primary, width: 1.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Contacto ──────────────────────────────────────────────────────────────────

  Widget _buildContactoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabeledField(
            label: 'CORREO ELECTRÓNICO',
            controller: _emailCtrl,
            hint: 'correo@ejemplo.com',
            prefixIcon: Icons.mail_outline_rounded,
            suffixIcon: Icons.check_circle_rounded,
            suffixColor: _green,
            hint2: 'Verificado · Para cambiar ve a Configuración',
            readOnly: true,
          ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CELULAR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8A8FA8),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Prefijo país
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE8EAF0),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: const [
                        Text('🇨🇴', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text(
                          '+57',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1F2E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1A1F2E),
                      ),
                      decoration: InputDecoration(
                        hintText: '3XX XXX XXXX',
                        hintStyle: const TextStyle(
                          color: Color(0xFFCDD0DB),
                          fontSize: 13.5,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF5F6FA),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8EAF0),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8EAF0),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: _primary,
                            width: 1.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Text(
                '3XX XXX XXXX',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF8A8FA8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Ubicación ─────────────────────────────────────────────────────────────────

  Widget _buildUbicacionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CIUDAD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8A8FA8),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE8EAF0),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        child: Text(
                          'Bogotá D.C.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1F2E),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF8A8FA8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _buildLabeledField(
              label: 'BARRIO / SECTOR',
              controller: _neighborhoodCtrl,
              hint: 'Chapinero',
              prefixIcon: Icons.location_on_outlined,
            ),
          ),
        ],
      ),
    );
  }

  // ── Redes & links ─────────────────────────────────────────────────────────────

  Widget _buildRedesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Instagram
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'INSTAGRAM',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8A8FA8),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _instagramCtrl,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1F2E)),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFE1306C),
                            Color(0xFFF77737),
                            Color(0xFF833AB4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                  suffixText: '@juanperez_co',
                  suffixStyle: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB0B5CC),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F6FA),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFE8EAF0),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFE8EAF0),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _primary, width: 1.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Sitio web
          _buildLabeledField(
            label: '',
            controller: _websiteCtrl,
            hint: 'Sitio web o tienda',
            prefixIcon: Icons.language_rounded,
            hint2: 'Tu tienda, catálogo o portafolio online',
            prefixIconColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  // ── Intereses ─────────────────────────────────────────────────────────────────

  Widget _buildInteresesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'El algoritmo te muestra promos de las categorías que elijas',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF8A8FA8)),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allInterests.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(interest);
                    } else {
                      _selectedInterests.add(interest);
                    }
                  });
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? _primary : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected ? _primary : const Color(0xFFE8EAF0),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _primary.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        interest,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF5A5F72),
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Cuenta ────────────────────────────────────────────────────────────────────

  Widget _buildCuentaSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _accountRow(
            icon: Icons.bolt_rounded,
            iconColor: _amber,
            iconBg: _amber.withOpacity(0.1),
            label: 'Plan activo',
            value: 'Gratuito',
            actionLabel: 'Mejorar',
            actionColor: _primary,
          ),
          const SizedBox(height: 10),
          _accountRow(
            icon: Icons.lock_outline_rounded,
            iconColor: const Color(0xFF8B5CF6),
            iconBg: const Color(0xFF8B5CF6).withOpacity(0.1),
            label: 'Contraseña',
            value: '••••••••',
            actionLabel: 'Cambiar',
            actionColor: const Color(0xFF5A5F72),
          ),
          const SizedBox(height: 10),
          _accountRow(
            icon: Icons.shield_outlined,
            iconColor: _green,
            iconBg: _green.withOpacity(0.1),
            label: 'Cuenta verificada',
            value: '',
            actionLabel: 'Sí',
            actionColor: _green,
          ),
        ],
      ),
    );
  }

  Widget _accountRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required String actionLabel,
    required Color actionColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EAF0), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1F2E),
              ),
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF8A8FA8),
                letterSpacing: 2,
              ),
            ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8EAF0), width: 1.2),
              ),
              child: Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: actionColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    Color? prefixIconColor,
    String? hint2,
    IconData? suffixIcon,
    Color? suffixColor,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8A8FA8),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onChanged: (_) => setState(() {}),
          style: TextStyle(
            fontSize: 14,
            color: readOnly ? const Color(0xFF8A8FA8) : const Color(0xFF1A1F2E),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFCDD0DB),
              fontSize: 13.5,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: prefixIconColor ?? const Color(0xFFB0B5CC),
                    size: 18,
                  )
                : null,
            suffixIcon: suffixIcon != null
                ? Icon(
                    suffixIcon,
                    color: suffixColor ?? const Color(0xFFB0B5CC),
                    size: 20,
                  )
                : null,
            filled: true,
            fillColor: readOnly
                ? const Color(0xFFF0F1F5)
                : const Color(0xFFF5F6FA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE8EAF0),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE8EAF0),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _primary, width: 1.8),
            ),
          ),
        ),
        if (hint2 != null) ...[
          const SizedBox(height: 5),
          Text(
            hint2,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF8A8FA8)),
          ),
        ],
      ],
    );
  }

  Widget _optionalBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F1F5),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Text(
      'Opcional',
      style: TextStyle(
        fontSize: 11,
        color: Color(0xFF8A8FA8),
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _counterBadge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: _primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        color: _primary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  // ── Botón Guardar ─────────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            disabledBackgroundColor: _primary.withOpacity(0.5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Guardar cambios',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
