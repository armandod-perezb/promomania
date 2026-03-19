import 'package:flutter/material.dart';
import '../Core/Routes/app_routes.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  int _selectedIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const Color primaryOrange = Color(0xFFFF5733);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGray = Color(0xFF8A8A9A);
  static const Color greenAccent = Color(0xFF2ECC71);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color bgColor = Color(0xFFF5F5F8);

  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Diego Morales',
      'email': 'diego@correo.com',
      'role': 'Negocio',
      'status': 'Inactivo',
      'lastActive': 'Hace 1d',
      'joinDate': '3 Mar 2024',
      'color': Color(0xFF3498DB),
      'isActive': false,
    },
    {
      'name': 'Sofía Ramírez',
      'email': 'sofia@correo.com',
      'role': 'Usuario',
      'status': 'Activo',
      'lastActive': 'Hace 4h',
      'joinDate': '20 Feb 2026',
      'color': Color(0xFF9B59B6),
      'isActive': true,
    },
    {
      'name': 'Luis Herrera',
      'email': 'luis@correo.com',
      'role': 'Admin',
      'status': 'Activo',
      'lastActive': 'Hace 20m',
      'joinDate': '1 Ene 2026',
      'color': Color(0xFFFF5733),
      'isActive': true,
    },
    {
      'name': 'Ana Martínez',
      'email': 'ana@correo.com',
      'role': 'Usuario',
      'status': 'Inactivo',
      'lastActive': 'Hace 5d',
      'joinDate': '8 Feb 2026',
      'color': Color(0xFF1A1A2E),
      'isActive': false,
    },
    {
      'name': 'Carlos López',
      'email': 'carlos@correo.com',
      'role': 'Negocio',
      'status': 'Activo',
      'lastActive': 'Hace 1d',
      'joinDate': '10 Ene 2026',
      'color': Color(0xFF2980B9),
      'isActive': true,
    },
    {
      'name': 'María García',
      'email': 'maria@correo.com',
      'role': 'Usuario',
      'status': 'Activo',
      'lastActive': 'Hace 3h',
      'joinDate': '15 Dic 2026',
      'color': Color(0xFFE74C3C),
      'isActive': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((u) {
      final q = _searchQuery.toLowerCase();
      return (u['name'] as String).toLowerCase().contains(q) ||
          (u['email'] as String).toLowerCase().contains(q);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildBreadcrumb(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildTitleRow(),
                    const SizedBox(height: 14),
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    _buildFilterRow(),
                    const SizedBox(height: 16),
                    ..._filteredUsers.map((u) => _buildUserCard(u)),
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
          _topBarIconBtn(Icons.share_outlined),
          const SizedBox(width: 8),
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

  Widget _topBarIconBtn(IconData icon) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: textGray, size: 18),
    );
  }

  // ─── BREADCRUMB ─────────────────────────────────────────────────────────────
  Widget _buildBreadcrumb() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline, color: primaryOrange, size: 14),
                const SizedBox(width: 5),
                const Text(
                  'Usuarios',
                  style: TextStyle(
                    color: primaryOrange,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '6 registros  •  4 activos',
            style: const TextStyle(color: textGray, fontSize: 12),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: textGray, size: 18),
        ],
      ),
    );
  }

  // ─── TITLE ROW ──────────────────────────────────────────────────────────────
  Widget _buildTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestión de Usuarios',
              style: TextStyle(
                color: textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '6 usuarios registrados  •  4 activos',
              style: const TextStyle(color: textGray, fontSize: 12),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showAddUserDialog(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: primaryOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.person_add_outlined, color: Colors.white, size: 15),
                SizedBox(width: 6),
                Text(
                  'Nuevo Usuario',
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

  // ─── SEARCH BAR ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: const TextStyle(color: textDark, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre, email o rol...',
          hintStyle: const TextStyle(color: textGray, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: textGray, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: const Icon(Icons.close, color: textGray, size: 18),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ─── FILTER ROW ─────────────────────────────────────────────────────────────
  Widget _buildFilterRow() {
    return Row(
      children: [
        _filterChip(Icons.tune, 'Filtros'),
        const SizedBox(width: 8),
        _filterChip(Icons.upload_outlined, 'Exportar'),
        const Spacer(),
        _countChip('+4', primaryOrange),
        const SizedBox(width: 6),
        _countChip('+2', const Color(0xFF3498DB)),
        const SizedBox(width: 6),
        Text('activos', style: const TextStyle(color: textGray, fontSize: 12)),
      ],
    );
  }

  Widget _filterChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEF2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textGray),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: textDark,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _countChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ─── USER CARD ──────────────────────────────────────────────────────────────
  Widget _buildUserCard(Map<String, dynamic> user) {
    final bool isActive = user['status'] == 'Activo';
    final Color roleColor = _roleColor(user['role'] as String);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Column(
              children: [
                // Header row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: user['color'] as Color,
                      child: Text(
                        (user['name'] as String)[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user['name'] as String,
                                style: const TextStyle(
                                  color: textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: primaryOrange,
                                size: 14,
                              ),
                            ],
                          ),
                          Text(
                            user['email'] as String,
                            style: const TextStyle(
                              color: textGray,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit_outlined, color: textGray, size: 18),
                  ],
                ),
                const SizedBox(height: 10),
                // Tags row
                Row(
                  children: [
                    _roleTag(user['role'] as String, roleColor),
                    const SizedBox(width: 8),
                    _statusTag(isActive),
                  ],
                ),
                const SizedBox(height: 10),
                // Meta row
                Row(
                  children: [
                    _metaItem(Icons.access_time, user['lastActive'] as String),
                    const SizedBox(width: 16),
                    _metaItem(
                      Icons.calendar_today_outlined,
                      user['joinDate'] as String,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Divider
          Container(height: 1, color: const Color(0xFFF0F0F5)),
          // Action row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                _actionBtn(
                  icon: Icons.history,
                  label: 'Historial',
                  color: textGray,
                  bgColor: const Color(0xFFF5F5F8),
                  onTap: () {},
                ),
                const Spacer(),
                isActive
                    ? _actionBtn(
                        icon: Icons.pause_circle_outline,
                        label: 'Suspender',
                        color: primaryOrange,
                        bgColor: primaryOrange.withOpacity(0.08),
                        onTap: () => _toggleStatus(user),
                      )
                    : _actionBtn(
                        icon: Icons.play_circle_outline,
                        label: 'Activar',
                        color: greenAccent,
                        bgColor: greenAccent.withOpacity(0.08),
                        onTap: () => _toggleStatus(user),
                      ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _confirmDelete(user),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Admin':
        return primaryOrange;
      case 'Negocio':
        return const Color(0xFF3498DB);
      default:
        return const Color(0xFF9B59B6);
    }
  }

  Widget _roleTag(String role, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            role == 'Admin'
                ? Icons.shield_outlined
                : role == 'Negocio'
                ? Icons.storefront_outlined
                : Icons.person_outline,
            color: color,
            size: 11,
          ),
          const SizedBox(width: 3),
          Text(
            role,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusTag(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive
            ? greenAccent.withOpacity(0.1)
            : Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
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
            isActive ? 'Activo' : 'Inactivo',
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

  Widget _metaItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: textGray),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: textGray, fontSize: 11)),
      ],
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ACTIONS ────────────────────────────────────────────────────────────────
  void _toggleStatus(Map<String, dynamic> user) {
    setState(() {
      user['status'] = user['status'] == 'Activo' ? 'Inactivo' : 'Activo';
      user['isActive'] = user['status'] == 'Activo';
    });
  }

  void _confirmDelete(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Eliminar usuario',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Estás seguro de eliminar a ${user['name']}? Esta acción no se puede deshacer.',
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
              setState(() => _users.remove(user));
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

  void _showAddUserDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nuevo Usuario',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: textGray),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _inputField('Nombre completo', Icons.person_outline),
            const SizedBox(height: 12),
            _inputField('Correo electrónico', Icons.email_outlined),
            const SizedBox(height: 12),
            _inputField(
              'Rol (Usuario / Negocio / Admin)',
              Icons.shield_outlined,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Crear Usuario',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: textGray, fontSize: 13),
          prefixIcon: Icon(icon, color: textGray, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
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
