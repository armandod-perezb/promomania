import 'package:flutter/material.dart';
import '../Core/Routes/app_routes.dart';
import '../main.dart';

/// Pantalla de alertas administrativas y exportacion de datos desde avisos.

const kOrange = Color(0xFFFF4422);
const kNavy = Color(0xFF1A1F36);
const kBg = Color(0xFFF3F4F8);
const kWhite = Colors.white;
const kTextDark = Color(0xFF1A1F36);
const kTextMuted = Color(0xFF9096AF);
const kGreen = Color(0xFF22C55E);
const kYellowBg = Color(0xFFFFF8ED);
const kYellowBorder = Color(0xFFFFD580);
const kYellowIcon = Color(0xFFFFAA00);
const kBlue = Color(0xFF3B82F6);
const kBlueBg = Color(0xFFEFF6FF);
const kBlueBorder = Color(0xFFBFDBFE);
const kDivider = Color(0xFFF0F1F5);
const kToggleOn = Color(0xFFFF4422);
const kIconBg = Color(0xFFFFF0EE);
const kIconBlueBg = Color(0xFFEEF0FF);
const kIconBlue = Color(0xFF6366F1);
const kDownloadBg = Color(0xFFF5F6FA);

class AdminNotiAlertScreen extends StatefulWidget {
  const AdminNotiAlertScreen({super.key});
  @override
  State<AdminNotiAlertScreen> createState() => _AdminNotiAlertScreenState();
}

class _AdminNotiAlertScreenState extends State<AdminNotiAlertScreen> {
  // Controla la pestana activa y el estado de opciones de exportacion.
  int _tab = 2; // Alertas activo
  int _nav = 4; // Avisos activo
  // Incluye metadata complementaria al exportar reportes.
  bool _incl = true;
  // Permite comprimir el archivo final para bajar peso de descarga.
  bool _comp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // Cabecera de marca y estado de notificaciones.
            _topBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                children: [
                  // Bloque contextual del centro de auditoria.
                  _auditoria(),
                  const SizedBox(height: 12),
                  // Tarjeta de rendimiento de campañas push.
                  _pushCard(),
                  const SizedBox(height: 14),
                  // Navegacion secundaria entre actividad, reportes, alertas y exportar.
                  _tabBar(),
                  const SizedBox(height: 14),
                  // Accesos rapidos a formatos de exportacion.
                  _exportCard(
                    iconWidget: const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: kOrange,
                      size: 22,
                    ),
                    iconBg: kIconBg,
                    title: 'Exportar CSV',
                    sub: 'Datos tabulares para Excel',
                    size: '2.4 MB',
                  ),
                  const SizedBox(height: 10),
                  _exportCard(
                    iconWidget: const Icon(
                      Icons.code,
                      color: kIconBlue,
                      size: 22,
                    ),
                    iconBg: kIconBlueBg,
                    title: 'Exportar JSON',
                    sub: 'Formato estructurado para APIs',
                    size: '1.8 MB',
                  ),
                  const SizedBox(height: 10),
                  _exportCard(
                    iconWidget: const Icon(
                      Icons.picture_as_pdf_outlined,
                      color: kOrange,
                      size: 22,
                    ),
                    iconBg: kIconBg,
                    title: 'Exportar PDF',
                    sub: 'Reporte visual completo',
                    size: '880 KB',
                  ),
                  const SizedBox(height: 18),
                  // Parametros de generacion del archivo.
                  _configCard(),
                  const SizedBox(height: 14),
                  // Nota de ayuda sobre alcance y uso de las exportaciones.
                  _infoCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            _bottomNav(),
          ],
        ),
      ),
    );
  }

  
  Widget _topBar() => Container(
    color: kWhite,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        // Logo
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: kOrange,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'PM',
              style: TextStyle(
                color: kWhite,
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'PROMOVANIA',
              style: TextStyle(
                fontSize: 8.5,
                color: kTextMuted,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              'Admin Panel',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Bell badge
        Stack(
          children: [
            const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                Icons.notifications_outlined,
                color: kTextMuted,
                size: 24,
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: kOrange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Avatar
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(color: kNavy, shape: BoxShape.circle),
          child: const Center(
            child: Text(
              'A',
              style: TextStyle(
                color: kWhite,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // ÔöÇÔöÇÔöÇ AUDITOR├ìA ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ
  Widget _auditoria() => Container(
    decoration: BoxDecoration(
      color: kYellowBg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kYellowBorder, width: 1),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: kYellowIcon.withOpacity(0.15),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.assignment_outlined,
            color: kYellowIcon,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Auditor├¡a',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: kTextDark,
              ),
            ),
            Text(
              'Centro de reportes y alertas',
              style: TextStyle(fontSize: 11.5, color: kTextMuted),
            ),
          ],
        ),
        const Spacer(),
        const Icon(Icons.chevron_right, color: kTextMuted, size: 22),
      ],
    ),
  );

  // ÔöÇÔöÇÔöÇ PUSH CARD ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ
  Widget _pushCard() => Container(
    decoration: BoxDecoration(
      color: kNavy,
      borderRadius: BorderRadius.circular(18),
    ),
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kOrange,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: kWhite,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Push Notifications',
                    style: TextStyle(
                      color: kWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                  Text(
                    'Centro de comunicaciones',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            // Bot├│n Nueva Campa├▒a
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: kOrange,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.send_outlined, color: kWhite, size: 13),
                  SizedBox(width: 5),
                  Text(
                    'Nueva Campa├▒a',
                    style: TextStyle(
                      color: kWhite,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Llega a tus usuarios en tiempo real\ncon mensajes personalizados',
          style: TextStyle(color: Colors.white60, fontSize: 11.5, height: 1.55),
        ),
        const SizedBox(height: 16),
        // Stats
        IntrinsicHeight(
          child: Row(
            children: [
              _stat('Enviadas', '4.2K', '+12%'),
              _vDivider(),
              _stat('Tasa\nApertura', '89%', '+5%', center: true),
              _vDivider(),
              _stat('Clics', '2.8K', '+18%'),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _vDivider() => Container(
    width: 1,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    color: Colors.white12,
  );

  Widget _stat(String label, String val, String trend, {bool center = false}) =>
      Expanded(
        child: Column(
          crossAxisAlignment: center
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Text(
              label,
              textAlign: center ? TextAlign.center : TextAlign.start,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              val,
              style: const TextStyle(
                color: kWhite,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: center
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                const Icon(Icons.arrow_upward, color: kGreen, size: 11),
                Text(
                  trend,
                  style: const TextStyle(color: kGreen, fontSize: 10.5),
                ),
              ],
            ),
          ],
        ),
      );

  // ÔöÇÔöÇÔöÇ TAB BAR ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ
  Widget _tabBar() {
    // badges: Actividad=0, Reportes=8, Alertas=1, Exportar=0
    final tabs = [
      {'icon': Icons.access_time_outlined, 'label': 'Actividad', 'badge': 0},
      {'icon': Icons.description_outlined, 'label': 'Reportes', 'badge': 8},
      {'icon': Icons.notifications_outlined, 'label': 'Alertas', 'badge': 1},
      {'icon': Icons.file_upload_outlined, 'label': 'Exportar', 'badge': 0},
    ];

    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(5),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = i == _tab;
          final badge = tabs[i]['badge'] as int;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onNotiTabTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: active ? kNavy : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          tabs[i]['icon'] as IconData,
                          size: 21,
                          color: active ? kWhite : kTextMuted,
                        ),
                        if (badge > 0)
                          Positioned(
                            top: -5,
                            right: -8,
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 16),
                              height: 16,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color: kOrange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '$badge',
                                  style: const TextStyle(
                                    color: kWhite,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tabs[i]['label'] as String,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                        color: active ? kWhite : kTextMuted,
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

  // ÔöÇÔöÇÔöÇ EXPORT CARD ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ
  Widget _exportCard({
    required Widget iconWidget,
    required Color iconBg,
    required String title,
    required String sub,
    required String size,
  }) => Container(
    decoration: BoxDecoration(
      color: kWhite,
      borderRadius: BorderRadius.circular(14),
    ),
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
    child: Row(
      children: [
        // Icon
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(child: iconWidget),
        ),
        const SizedBox(width: 14),
        // Texts
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: const TextStyle(fontSize: 12, color: kTextMuted),
              ),
              const SizedBox(height: 3),
              Text(
                size,
                style: TextStyle(
                  fontSize: 11,
                  color: kTextMuted.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ),
        // Download button
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: kDownloadBg,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.file_download_outlined,
            color: kOrange,
            size: 21,
          ),
        ),
      ],
    ),
  );

  // ÔöÇÔöÇÔöÇ CONFIG CARD ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ
  Widget _configCard() => Container(
    decoration: BoxDecoration(
      color: kWhite,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: const [
              Icon(Icons.settings_outlined, color: kOrange, size: 19),
              SizedBox(width: 8),
              Text(
                'Configuraci├│n de Exportaci├│n',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: kTextDark,
                ),
              ),
            ],
          ),
        ),
        // Divider
        const Divider(height: 1, thickness: 1, color: kDivider),
        // Toggle 1
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Incluir datos personales',
                  style: TextStyle(fontSize: 13.5, color: kTextDark),
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: _incl,
                  onChanged: (v) => setState(() => _incl = v),
                  activeColor: kWhite,
                  activeTrackColor: kToggleOn,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFDDDEE6),
                  trackOutlineColor: MaterialStateProperty.all(
                    Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Divider
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 1, thickness: 1, color: kDivider),
        ),
        // Toggle 2
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Comprimir archivo',
                  style: TextStyle(fontSize: 13.5, color: kTextDark),
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: _comp,
                  onChanged: (v) => setState(() => _comp = v),
                  activeColor: kWhite,
                  activeTrackColor: kToggleOn,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFDDDEE6),
                  trackOutlineColor: MaterialStateProperty.all(
                    Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    ),
  );

  // ÔöÇÔöÇÔöÇ INFO CARD ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ
  Widget _infoCard() => Container(
    decoration: BoxDecoration(
      color: kBlueBg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kBlueBorder, width: 1),
    ),
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: kBlue.withOpacity(0.13),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.info_outline, color: kBlue, size: 19),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exportaciones Seguras',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: kBlue,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Todos los datos se exportan de forma encriptada y se '
                'eliminan autom├íticamente despu├®s de 24 horas.',
                style: TextStyle(fontSize: 12, color: kTextMuted, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ÔöÇÔöÇÔöÇ BOTTOM NAV ÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇÔöÇ
  Widget _bottomNav() {
    final items = [
      {'icon': Icons.grid_view_outlined, 'label': 'Panel'},
      {'icon': Icons.people_outline, 'label': 'Usuarios'},
      {'icon': Icons.local_offer_outlined, 'label': 'Promos'},
      {'icon': Icons.storefront_outlined, 'label': 'Comercios'},
      {'icon': Icons.notifications_outlined, 'label': 'Avisos'},
    ];
    return Container(
      decoration: const BoxDecoration(
        color: kWhite,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = i == _nav;
          return GestureDetector(
            onTap: () => _onBottomNavTap(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  items[i]['icon'] as IconData,
                  size: 23,
                  color: active ? kOrange : kTextMuted,
                ),
                const SizedBox(height: 3),
                Text(
                  items[i]['label'] as String,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: active ? kOrange : kTextMuted,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
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

  void _onNotiTabTap(int index) {
    if (index == _tab) return;
    Navigator.pushReplacementNamed(context, _notiRouteForTab(index));
  }

  String _routeForBottomIndex(int index) {
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

  void _onBottomNavTap(int index) {
    if (index == _nav) return;
    Navigator.pushReplacementNamed(context, _routeForBottomIndex(index));
  }
}
