import 'package:flutter/material.dart';
import '../Core/Routes/app_routes.dart';
import '../main.dart';

/// Pantalla para configurar y ejecutar exportaciones desde el modulo de avisos.

// ── Colores ───────────────────────────────────────────────────────────────────
const kOrange = Color(0xFFFF4500);
const kNavyDark = Color(0xFF1A1F36);
const kBgGray = Color(0xFFF4F5F9);
const kWhite = Colors.white;
const kTextDark = Color(0xFF1A1F36);
const kTextGray = Color(0xFF8A8FA8);
const kGreen = Color(0xFF00C48C);
const kYellowBg = Color(0xFFFFF3E0);
const kYellowText = Color(0xFFFF9800);
const kBlueInfo = Color(0xFF3B82F6);
const kBlueLightBg = Color(0xFFEFF6FF);
const kToggleOn = Color(0xFF22C55E);
const kCodeOrange = Color(0xFFFF6B35);
const kCodeBlue = Color(0xFF6366F1);

class AdminNotiExportScreen extends StatefulWidget {
  const AdminNotiExportScreen({super.key});

  @override
  State<AdminNotiExportScreen> createState() => _AdminNotiExportScreenState();
}

class _AdminNotiExportScreenState extends State<AdminNotiExportScreen> {
  // Estado local de la navegacion y preferencias de exportacion.
  int _selectedTab = 3; // Exportar activo
  int _bottomNav = 4; // Avisos activo
  // Define si se adjunta informacion adicional (metadatos, trazas, etc.).
  bool _incluirDatos = true;
  // Si esta activo, el archivo se empaqueta para reducir tamano.
  bool _comprimirArchivo = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: promoService,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: kBgGray,
          body: SafeArea(
            child: Column(
              children: [
                // Cabecera fija del modulo de avisos.
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        // Contexto de auditoria para ubicar al administrador.
                        _buildAuditoriaCard(),
                        const SizedBox(height: 12),
                        // Resumen de comunicaciones push para referencia rapida.
                        _buildPushCard(),
                        const SizedBox(height: 16),
                        // Tabs internas del centro de avisos.
                        _buildTabBar(),
                        const SizedBox(height: 16),
                        // Tarjetas de salida por formato.
                        _buildExportCard(
                          icon: Icons.table_chart_outlined,
                          iconColor: kOrange,
                          title: 'Exportar CSV',
                          subtitle: 'Datos tabulares para Excel',
                          size: '2.4 MB',
                        ),
                        const SizedBox(height: 10),
                        _buildExportCard(
                          icon: Icons.code,
                          iconColor: kCodeBlue,
                          title: 'Exportar JSON',
                          subtitle: 'Formato estructurado para APIs',
                          size: '1.8 MB',
                        ),
                        const SizedBox(height: 10),
                        _buildExportCard(
                          icon: Icons.picture_as_pdf_outlined,
                          iconColor: kOrange,
                          title: 'Exportar PDF',
                          subtitle: 'Reporte visual completo',
                          size: '880 KB',
                        ),
                        const SizedBox(height: 16),
                        // Configuracion de como se construye el archivo final.
                        _buildConfigCard(),
                        const SizedBox(height: 12),
                        // Bloque informativo sobre destino y uso de exportaciones.
                        _buildInfoCard(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                _buildBottomNav(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── TOP BAR ──────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
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
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROMOVANIA',
                style: TextStyle(
                  fontSize: 9,
                  color: kTextGray,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Admin Panel',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kTextDark,
                ),
              ),
            ],
          ),
          const Spacer(),
          Stack(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: kTextGray,
                size: 24,
              ),
              Positioned(
                top: 0,
                right: 0,
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
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.userProfile),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: kOrange,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    color: kWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── AUDITORÍA ─────────────────────────────────────────────────────────────────
  Widget _buildAuditoriaCard() {
    return Container(
      decoration: BoxDecoration(
        color: kYellowBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kYellowText.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kYellowText.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: kYellowText,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Auditoría',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: kTextDark,
                ),
              ),
              Text(
                'Centro de reportes y alertas',
                style: TextStyle(fontSize: 11, color: kTextGray),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: kTextGray),
        ],
      ),
    );
  }

  // ── PUSH CARD ─────────────────────────────────────────────────────────────────
  Widget _buildPushCard() {
    return Container(
      decoration: BoxDecoration(
        color: kNavyDark,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kOrange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications, color: kWhite, size: 20),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Centro de comunicaciones',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kOrange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.send, color: kWhite, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Nueva Campaña',
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 10,
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
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStat('Enviadas', '4.2K', '+12%'),
              _buildDivider(),
              _buildStatCenter('Tasa\nApertura', '89%', '+5%'),
              _buildDivider(),
              _buildStat('Clics', '2.8K', '+18%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(
    width: 1,
    height: 40,
    color: Colors.white12,
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );

  Widget _buildStat(String label, String value, String trend) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: kWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.arrow_upward, color: kGreen, size: 10),
            Text(trend, style: const TextStyle(color: kGreen, fontSize: 10)),
          ],
        ),
      ],
    ),
  );

  Widget _buildStatCenter(String label, String value, String trend) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: kWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_upward, color: kGreen, size: 10),
            Text(trend, style: const TextStyle(color: kGreen, fontSize: 10)),
          ],
        ),
      ],
    ),
  );

  // ── TAB BAR ──────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    final tabs = [
      {'icon': Icons.bar_chart_outlined, 'label': 'Actividad', 'badge': 0},
      {'icon': Icons.description_outlined, 'label': 'Reportes', 'badge': 0},
      {'icon': Icons.notifications_outlined, 'label': 'Alertas', 'badge': 1},
      {'icon': Icons.file_upload_outlined, 'label': 'Exportar', 'badge': 0},
    ];

    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = i == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onNotiTabTap(i),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? kNavyDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          tabs[i]['icon'] as IconData,
                          size: 20,
                          color: isActive ? kWhite : kTextGray,
                        ),
                        if ((tabs[i]['badge'] as int) > 0)
                          Positioned(
                            top: -4,
                            right: -6,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: kOrange,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${tabs[i]['badge']}',
                                  style: const TextStyle(
                                    color: kWhite,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tabs[i]['label'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isActive ? kWhite : kTextGray,
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

  // ── EXPORT CARD ───────────────────────────────────────────────────────────────
  Widget _buildExportCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String size,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          // Icon box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11.5, color: kTextGray),
                ),
                const SizedBox(height: 4),
                Text(
                  size,
                  style: TextStyle(
                    fontSize: 11,
                    color: kTextGray.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Download icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kBgGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.file_download_outlined,
              color: kTextGray,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ── CONFIG CARD ───────────────────────────────────────────────────────────────
  Widget _buildConfigCard() {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: const [
              Icon(Icons.settings_outlined, color: kOrange, size: 18),
              SizedBox(width: 8),
              Text(
                'Configuración de Exportación',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: kTextDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Row 1 — Incluir datos personales
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Incluir datos personales',
                  style: TextStyle(fontSize: 13, color: kTextDark),
                ),
              ),
              Switch(
                value: _incluirDatos,
                onChanged: (v) => setState(() => _incluirDatos = v),
                activeColor: kToggleOn,
                activeTrackColor: kToggleOn.withOpacity(0.35),
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade200,
              ),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F5)),
          const SizedBox(height: 4),
          // Row 2 — Comprimir archivo
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Comprimir archivo',
                  style: TextStyle(fontSize: 13, color: kTextDark),
                ),
              ),
              Switch(
                value: _comprimirArchivo,
                onChanged: (v) => setState(() => _comprimirArchivo = v),
                activeColor: kToggleOn,
                activeTrackColor: kToggleOn.withOpacity(0.35),
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade200,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── INFO CARD ─────────────────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: kBlueLightBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBlueInfo.withOpacity(0.25)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kBlueInfo.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline, color: kBlueInfo, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exportaciones Seguras',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: kBlueInfo,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Todos los datos se exportan de forma encriptada y se eliminan automáticamente después de 24 horas.',
                  style: TextStyle(
                    fontSize: 12,
                    color: kTextGray,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM NAV ────────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.grid_view_outlined, 'label': 'Panel'},
      {'icon': Icons.people_outline, 'label': 'Usuarios'},
      {'icon': Icons.local_offer_outlined, 'label': 'Promos'},
      {'icon': Icons.store_outlined, 'label': 'Comercios'},
      {'icon': Icons.notifications_outlined, 'label': 'Avisos'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: kWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isActive = i == _bottomNav;
          return GestureDetector(
            onTap: () => _onBottomNavTap(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  items[i]['icon'] as IconData,
                  size: 22,
                  color: isActive ? kOrange : kTextGray,
                ),
                const SizedBox(height: 3),
                Text(
                  items[i]['label'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? kOrange : kTextGray,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
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
    if (index == _selectedTab) return;
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
    if (index == _bottomNav) return;
    Navigator.pushReplacementNamed(context, _routeForBottomIndex(index));
  }
}
