import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA CENTRO DE AYUDA
// ─────────────────────────────────────────────────────────────────────────────

/// Pantalla de centro de ayuda con preguntas y canales de soporte.
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

/// Estado interno de `HelpCenterScreen`; coordina datos, eventos y reconstrucciones de la pantalla.
class _HelpCenterScreenState extends State<HelpCenterScreen> {
  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);
  static const Color _lightBg = Color(0xFFF5F6FA);

  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  final List<_HelpTopic> _topics = const [
    _HelpTopic(
      icon: Icons.location_on_outlined,
      label: 'Explorar y buscar',
      color: Color(0xFFFF4D2E),
      bgColor: Color(0xFFFFF1EF),
    ),
    _HelpTopic(
      icon: Icons.favorite_border_rounded,
      label: 'Favoritos',
      color: Color(0xFFEC4899),
      bgColor: Color(0xFFFDF2F8),
    ),
    _HelpTopic(
      icon: Icons.storefront_outlined,
      label: 'Publicar promoción',
      color: Color(0xFF3B82F6),
      bgColor: Color(0xFFEFF6FF),
    ),
    _HelpTopic(
      icon: Icons.shield_outlined,
      label: 'Cuenta y seguridad',
      color: Color(0xFF10B981),
      bgColor: Color(0xFFECFDF5),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 16),
              _buildBackButton(),
              const SizedBox(height: 24),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 28),
              _buildSupportCard(),
              const SizedBox(height: 32),
              _buildTopicsSection(),
              const SizedBox(height: 40),
              _buildFooterLinks(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Botón retroceso ───────────────────────────────────────────────────────────

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _lightBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF1A1F2E),
            size: 20,
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Cómo podemos\nayudarte?',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1F2E),
              height: 1.15,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Encuentra respuestas o contacta con soporte',
            style: TextStyle(fontSize: 14, color: Color(0xFF8A8FA8)),
          ),
        ],
      ),
    );
  }

  // ── Barra de búsqueda ─────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: _searchCtrl,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1F2E)),
        decoration: InputDecoration(
          hintText: 'Buscar ayuda...',
          hintStyle: const TextStyle(color: Color(0xFFB0B5CC), fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFFB0B5CC),
            size: 20,
          ),
          filled: true,
          fillColor: _lightBg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ── Tarjeta de soporte ────────────────────────────────────────────────────────

  Widget _buildSupportCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: _darkBg,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: _darkBg.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            const Text(
              'Habla con soporte',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Estamos disponibles para ayudarte ahora',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),

            // Chat en vivo
            GestureDetector(
              onTap: () => HapticFeedback.lightImpact(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    // Ícono chat
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Info
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chat en vivo',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1F2E),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Conecta en segundos',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8A8FA8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge Activo
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Activo',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Email soporte
            GestureDetector(
              onTap: () => HapticFeedback.lightImpact(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Ícono email
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.mail_outline_rounded,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'soporte@promomap.co',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Respuesta en 24h',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withOpacity(0.3),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Temas de ayuda ────────────────────────────────────────────────────────────

  Widget _buildTopicsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temas de ayuda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1F2E),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.4,
            children: _topics.map((t) => _buildTopicCard(t)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(_HelpTopic topic) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        decoration: BoxDecoration(
          color: topic.bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: topic.color.withOpacity(0.15), width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: topic.color.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(topic.icon, color: topic.color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              topic.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1F2E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────────

  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Términos de uso',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF8A8FA8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: () {},
          child: const Text(
            'Privacidad',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF8A8FA8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODELO
// ─────────────────────────────────────────────────────────────────────────────

/// Modelo interno para representar un tema del centro de ayuda.
class _HelpTopic {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _HelpTopic({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });
}
