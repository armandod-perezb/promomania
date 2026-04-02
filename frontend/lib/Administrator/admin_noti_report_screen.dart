import 'package:flutter/material.dart';
import '../Core/Routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const AdminNotiReportScreen(),
    );
  }
}

// ── Colores globales ──────────────────────────────────────────────────────────
const kOrange = Color(0xFFFF4500); // rojo-naranja principal
const kOrangeLight = Color(0xFFFF6633);
const kNavyDark = Color(0xFF1A1F36); // fondo tarjeta oscura
const kNavyCard = Color(0xFF1E2440);
const kBgGray = Color(0xFFF4F5F9); // fondo general
const kWhite = Colors.white;
const kTextDark = Color(0xFF1A1F36);
const kTextGray = Color(0xFF8A8FA8);
const kGreen = Color(0xFF00C48C);
const kYellowBg = Color(0xFFFFF3E0);
const kYellowText = Color(0xFFFF9800);
const kTabActive = Color(0xFF1A1F36);

class AdminNotiReportScreen extends StatefulWidget {
  const AdminNotiReportScreen({super.key});

  @override
  State<AdminNotiReportScreen> createState() => _AdminNotiReportScreenState();
}

class _AdminNotiReportScreenState extends State<AdminNotiReportScreen> {
  int _selectedTab = 1; // Reportes selected
  int _bottomNav = 4; // Avisos selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgGray,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildAuditoriaCard(),
                    const SizedBox(height: 12),
                    _buildPushCard(),
                    const SizedBox(height: 16),
                    _buildTabBar(),
                    const SizedBox(height: 16),
                    _buildActividadHeader(),
                    const SizedBox(height: 8),
                    _buildBarChart(),
                    const SizedBox(height: 16),
                    _buildReporteGrid(),
                    const SizedBox(height: 16),
                    _buildDescargarSection(),
                    const SizedBox(height: 20),
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

  // ── TOP BAR ──────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Logo PM
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
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
          // Bell
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
          // Avatar
          Container(
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
        ],
      ),
    );
  }

  // ── AUDITORÍA CARD ────────────────────────────────────────────────────────────
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
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

  // ── PUSH NOTIFICATION CARD ───────────────────────────────────────────────────
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
          // Header row
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
              // Nueva Campaña button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kOrange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
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
          // Stats row
          Row(
            children: [
              _buildStat('Enviadas', '4.2K', '+12%', true),
              _buildStatDivider(),
              _buildStatCenter('Tasa Apertura', '89%', '+5%', true),
              _buildStatDivider(),
              _buildStat('Clics', '2.8K', '+18%', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white12,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildStat(String label, String value, String trend, bool positive) {
    return Expanded(
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
              Icon(
                positive ? Icons.arrow_upward : Icons.arrow_downward,
                color: kGreen,
                size: 10,
              ),
              Text(trend, style: const TextStyle(color: kGreen, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCenter(
    String label,
    String value,
    String trend,
    bool positive,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_upward, color: kGreen, size: 10),
              Text(trend, style: const TextStyle(color: kGreen, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

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
          final tab = tabs[i];
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
                          tab['icon'] as IconData,
                          size: 20,
                          color: isActive ? kWhite : kTextGray,
                        ),
                        if ((tab['badge'] as int) > 0)
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
                                  '${tab['badge']}',
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
                      tab['label'] as String,
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

  // ── ACTIVIDAD HEADER ──────────────────────────────────────────────────────────
  Widget _buildActividadHeader() {
    return Row(
      children: const [
        Icon(Icons.trending_up, color: kOrange, size: 18),
        SizedBox(width: 6),
        Text(
          'Actividad por Hora',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: kTextDark,
          ),
        ),
      ],
    );
  }

  // ── BAR CHART ─────────────────────────────────────────────────────────────────
  Widget _buildBarChart() {
    // Datos aproximados de la imagen (hora → altura relativa 0-1)
    final data = [
      {'h': '00', 'v': 0.05},
      {'h': '03', 'v': 0.08},
      {'h': '06', 'v': 0.12},
      {'h': '09', 'v': 0.30},
      {'h': '12', 'v': 0.55},
      {'h': '15', 'v': 0.85},
      {'h': '18', 'v': 1.00},
      {'h': '21', 'v': 0.78},
    ];
    const maxH = 120.0;

    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      child: Column(
        children: [
          // Y-axis labels + bars
          SizedBox(
            height: maxH + 30,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('20', style: TextStyle(fontSize: 9, color: kTextGray)),
                    Text('15', style: TextStyle(fontSize: 9, color: kTextGray)),
                    Text('10', style: TextStyle(fontSize: 9, color: kTextGray)),
                    Text('5', style: TextStyle(fontSize: 9, color: kTextGray)),
                    Text('0', style: TextStyle(fontSize: 9, color: kTextGray)),
                  ],
                ),
                const SizedBox(width: 8),
                // Grid lines + bars
                Expanded(
                  child: Stack(
                    children: [
                      // Horizontal grid lines
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            5,
                            (_) => Container(
                              height: 0.5,
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                        ),
                      ),
                      // Bars
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: data.map((d) {
                          final v = d['v'] as double;
                          final h = d['h'] as String;
                          final barH = v * maxH;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 22,
                                height: barH,
                                decoration: BoxDecoration(
                                  color: kOrange,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(5),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                h,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: kTextGray,
                                ),
                              ),
                              Text(
                                'h',
                                style: const TextStyle(
                                  fontSize: 7,
                                  color: kTextGray,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── REPORTE GRID ─────────────────────────────────────────────────────────────
  Widget _buildReporteGrid() {
    final items = [
      {
        'icon': Icons.calendar_today_outlined,
        'color': kOrange,
        'label': 'Reporte Diario',
        'value': '1',
        'valueColor': kOrange,
      },
      {
        'icon': Icons.calendar_month_outlined,
        'color': kNavyDark,
        'label': 'Reporte Semanal',
        'value': '1',
        'valueColor': kTextDark,
      },
      {
        'icon': Icons.people_outline,
        'color': kGreen,
        'label': 'Usuarios Activos',
        'value': '1',
        'valueColor': kGreen,
      },
      {
        'icon': Icons.warning_amber_outlined,
        'color': kOrange,
        'label': 'Errores Sistema',
        'value': '1',
        'valueColor': kOrange,
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: items.map((item) => _buildReporteCard(item)).toList(),
    );
  }

  Widget _buildReporteCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(
            item['icon'] as IconData,
            color: item['color'] as Color,
            size: 22,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['label'] as String,
                style: const TextStyle(fontSize: 10.5, color: kTextGray),
              ),
              const SizedBox(height: 2),
              Text(
                item['value'] as String,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: item['valueColor'] as Color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── DESCARGAR SECTION ─────────────────────────────────────────────────────────
  Widget _buildDescargarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: kOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.file_download_outlined,
                color: kOrange,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Descargar Reportes',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: kTextDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: kOrange,
              foregroundColor: kWhite,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.file_download_outlined, size: 18),
            label: const Text(
              'Descargar Reporte Completo',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
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
