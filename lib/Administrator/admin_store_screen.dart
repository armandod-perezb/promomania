import 'package:flutter/material.dart';
import '../Core/Routes/app_routes.dart';

class ManageStoresScreen extends StatefulWidget {
  const ManageStoresScreen({super.key});

  @override
  State<ManageStoresScreen> createState() => _ManageStoresScreenState();
}

class _ManageStoresScreenState extends State<ManageStoresScreen> {
  int _selectedIndex = 3;

  static const Color primaryOrange = Color(0xFFFF5733);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGray = Color(0xFF8A8A9A);
  static const Color greenAccent = Color(0xFF2ECC71);
  static const Color blueAccent = Color(0xFF3498DB);
  static const Color bgColor = Color(0xFFF5F5F8);

  final List<Map<String, dynamic>> _stores = [
    {
      'name': 'Pizza Express',
      'address': 'Cra. 5 #20-10, El Prado',
      'category': 'Restaurante',
      'status': 'Activo',
      'isPaused': false,
      'promos': 8,
      'canje': 83,
      'vistas': 272,
      'phone': '+57 4 567 8901',
      'email': 'pedidos@pizzaexpress.co',
      'iconColor': Color(0xFFFF5733),
      'iconBg': Color(0xFFFFF0ED),
      'iconLabel': '🍕',
      'categoryColor': Color(0xFFFF5733),
    },
    {
      'name': 'TechStore Bogotá',
      'address': 'Cra. 7 #12-34, Centro Histórico',
      'category': 'Tecnología',
      'status': 'Activo',
      'isPaused': false,
      'promos': 12,
      'canje': 20,
      'vistas': 589,
      'phone': '+57 1 234 5678',
      'email': 'info@techstore.co',
      'iconColor': Color(0xFF3498DB),
      'iconBg': Color(0xFFEBF5FB),
      'iconLabel': '📱',
      'categoryColor': Color(0xFF3498DB),
    },
    {
      'name': 'Sport Zone',
      'address': 'Cl. 72 #11-09, Chapinero',
      'category': 'Deportes',
      'status': 'Activo',
      'isPaused': false,
      'promos': 15,
      'canje': 65,
      'vistas': 410,
      'phone': '+57 1 987 6543',
      'email': 'ventas@sportzone.co',
      'iconColor': Color(0xFF2ECC71),
      'iconBg': Color(0xFFE8F8F0),
      'iconLabel': '👟',
      'categoryColor': Color(0xFF2ECC71),
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
                    ..._stores.map((s) => _buildStoreCard(s)),
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
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comercios',
              style: TextStyle(
                color: textDark,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_stores.length} comercios registrados',
              style: const TextStyle(color: textGray, fontSize: 12),
            ),
          ],
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
                  'Nuevo Comercio',
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

  // ─── STORE CARD ─────────────────────────────────────────────────────────────
  Widget _buildStoreCard(Map<String, dynamic> store) {
    final bool isPaused = store['isPaused'] as bool;

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
          // ── Header ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Store icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: store['iconBg'] as Color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      store['iconLabel'] as String,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              store['name'] as String,
                              style: const TextStyle(
                                color: textDark,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isPaused ? Colors.orange : greenAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: textGray,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              store['address'] as String,
                              style: const TextStyle(
                                color: textGray,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          _categoryChip(
                            store['category'] as String,
                            store['categoryColor'] as Color,
                          ),
                          const SizedBox(width: 8),
                          _statusChip(isPaused),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Stats row ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _statItem(
                  value: store['promos'].toString(),
                  label: 'Promos',
                  color: textDark,
                ),
                _verticalDivider(),
                _statItem(
                  value: '${store['canje']}%',
                  label: 'Canje',
                  color: greenAccent,
                ),
                _verticalDivider(),
                _statItem(
                  value: store['vistas'].toString(),
                  label: 'Vistas',
                  color: blueAccent,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Contact row ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _contactItem(
                    icon: Icons.phone_outlined,
                    text: store['phone'] as String,
                  ),
                ),
                Container(width: 1, height: 16, color: const Color(0xFFEEEEF2)),
                Expanded(
                  child: _contactItem(
                    icon: Icons.email_outlined,
                    text: store['email'] as String,
                    align: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFF0F0F5)),

          // ── Action buttons ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: _outlineBtn(
                    icon: Icons.local_offer_outlined,
                    label: 'Ver Promos',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _pauseBtn(
                    isPaused: isPaused,
                    onTap: () => setState(() => store['isPaused'] = !isPaused),
                  ),
                ),
                const SizedBox(width: 10),
                _deleteBtn(onTap: () => _confirmDelete(store)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statusChip(bool isPaused) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPaused
            ? Colors.orange.withOpacity(0.1)
            : greenAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isPaused ? Colors.orange : greenAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isPaused ? 'Pausado' : 'Activo',
            style: TextStyle(
              color: isPaused ? Colors.orange : greenAccent,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
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
    return Container(width: 1, height: 38, color: const Color(0xFFEEEEF2));
  }

  Widget _contactItem({
    required IconData icon,
    required String text,
    TextAlign align = TextAlign.left,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: align == TextAlign.right
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (align == TextAlign.left) ...[
            Icon(icon, size: 14, color: textGray),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              text,
              style: const TextStyle(color: textGray, fontSize: 11),
              overflow: TextOverflow.ellipsis,
              textAlign: align,
            ),
          ),
          if (align == TextAlign.right) ...[
            const SizedBox(width: 5),
            Icon(icon, size: 14, color: textGray),
          ],
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

  Widget _pauseBtn({required bool isPaused, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isPaused
              ? greenAccent.withOpacity(0.08)
              : const Color(0xFFFFF8F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPaused
                ? greenAccent.withOpacity(0.3)
                : Colors.orange.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPaused ? Icons.play_circle_outline : Icons.pause_circle_outline,
              size: 15,
              color: isPaused ? greenAccent : Colors.orange,
            ),
            const SizedBox(width: 6),
            Text(
              isPaused ? 'Reanudar' : 'Pausar',
              style: TextStyle(
                color: isPaused ? greenAccent : Colors.orange,
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
  void _confirmDelete(Map<String, dynamic> store) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Eliminar comercio',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Deseas eliminar "${store['name']}"? Esta acción no se puede deshacer.',
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
              setState(() => _stores.remove(store));
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
