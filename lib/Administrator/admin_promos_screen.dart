import 'package:flutter/material.dart';
import '../Core/Routes/app_routes.dart';

class ManagePromotionsScreen extends StatefulWidget {
  const ManagePromotionsScreen({super.key});

  @override
  State<ManagePromotionsScreen> createState() => _ManagePromotionsScreenState();
}

class _ManagePromotionsScreenState extends State<ManagePromotionsScreen> {
  int _selectedIndex = 2;

  static const Color primaryOrange = Color(0xFFFF5733);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGray = Color(0xFF8A8A9A);
  static const Color greenAccent = Color(0xFF2ECC71);
  static const Color bgColor = Color(0xFFF5F5F8);

  final List<Map<String, dynamic>> _promos = [
    {
      'badge': '2x1',
      'badgeLabel': 'OFF',
      'title': '2x1 en Pizzas Familiar',
      'store': 'Pizza Express',
      'dateRange': '1 Mar → 16 Mar',
      'code': 'PIZZA2X1',
      'status': 'Activa',
      'canjes': 64,
      'vistas': 546,
      'conversion': 48,
      'badgeColor': Color(0xFFFF5733),
    },
    {
      'badge': '50%',
      'badgeLabel': 'OFF',
      'title': '50% en Zapatillas',
      'store': 'Sport Zone',
      'dateRange': '20 Feb → 28 Feb',
      'code': 'NIKE50',
      'status': 'Expirada',
      'canjes': 145,
      'vistas': 444,
      'conversion': 37,
      'badgeColor': Color(0xFFFF5733),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleRow(),
                    const SizedBox(height: 20),
                    ..._promos.map((p) => _buildPromoCard(p)),
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

  // ─── TOP BAR ────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryOrange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'AP',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROMOSPACE',
                  style: TextStyle(
                    color: textGray,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: textDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TITLE ROW ──────────────────────────────────────────────────────────────
  Widget _buildTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Promociones',
          style: TextStyle(
            color: textDark,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: primaryOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add, color: Colors.white, size: 16),
                SizedBox(width: 5),
                Text(
                  'Nueva Promo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── PROMO CARD ─────────────────────────────────────────────────────────────
  Widget _buildPromoCard(Map<String, dynamic> promo) {
    final bool isActive = promo['status'] == 'Activa';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top section ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: promo['badgeColor'] as Color,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        promo['badge'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        promo['badgeLabel'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              promo['title'] as String,
                              style: const TextStyle(
                                color: textDark,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _statusBadge(isActive),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.storefront_outlined,
                            size: 13,
                            color: textGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            promo['store'] as String,
                            style: const TextStyle(
                              color: textGray,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: textGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            promo['dateRange'] as String,
                            style: const TextStyle(
                              color: textGray,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Promo code section ───────────────────────────────
          _buildCodeSection(promo['code'] as String),

          // ── Stats row ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                _statItem(promo['canjes'].toString(), 'Canjes'),
                _verticalDivider(),
                _statItem(promo['vistas'].toString(), 'Vistas'),
                _verticalDivider(),
                _conversionStat(promo['conversion'] as int),
              ],
            ),
          ),

          // ── Action buttons ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: _outlineBtn(
                    icon: Icons.edit_outlined,
                    label: 'Editar',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _solidBtn(
                    icon: Icons.bar_chart_rounded,
                    label: 'Analíticas',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 10),
                _deleteBtn(onTap: () => _confirmDelete(promo)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? greenAccent.withOpacity(0.1)
            : Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isActive ? greenAccent : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Activa' : 'Expirada',
            style: TextStyle(
              color: isActive ? greenAccent : Colors.red,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeSection(String code) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: textDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CÓDIGO PROMOCIONAL',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                code,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: textGray, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 36, color: const Color(0xFFEEEEF2));
  }

  Widget _conversionStat(int pct) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$pct%',
            style: const TextStyle(
              color: greenAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Conversión',
            style: TextStyle(color: textGray, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _outlineBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E8), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: textDark),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _solidBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: textDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deleteBtn({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
      ),
    );
  }

  // ─── DELETE CONFIRM ─────────────────────────────────────────────────────────
  void _confirmDelete(Map<String, dynamic> promo) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Eliminar promoción',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Deseas eliminar "${promo['title']}"? Esta acción no se puede deshacer.',
          style: const TextStyle(color: textGray, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: textGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              setState(() => _promos.remove(promo));
              Navigator.pop(context);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
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

  void _onBottomNavTap(int index) {
    if (index == _selectedIndex) return;
    Navigator.pushReplacementNamed(context, _routeForIndex(index));
  }

  // ─── BOTTOM NAV ─────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.dashboard_outlined, 'label': 'Panel'},
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
            onTap: () => _onBottomNavTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? primaryOrange.withOpacity(0.12)
                    : Colors.transparent,
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
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.normal,
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
