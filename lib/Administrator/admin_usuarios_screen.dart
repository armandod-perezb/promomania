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
          onTap: () => _showCrearUsuarioModal(),
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

  void _showCrearUsuarioModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CrearUsuarioModal(),
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

const kOrange = Color(0xFFFF4422);
const kOrangeSoft = Color(0xFFFF6644);
const kNavy = Color(0xFF1A1F36);
const kBg = Color(0xFFF3F4F8);
const kWhite = Colors.white;
const kTextDark = Color(0xFF1A1F36);
const kMuted = Color(0xFF9096AF);
const kBorder = Color(0xFFE8E9F0);
const kGreen = Color(0xFF22C55E);
const kGreenBg = Color(0xFFDCFCE7);
const kLabelBlue = Color(0xFF6366F1);
const kChipBg = Color(0xFFFFF0EE);
const kChipBord = Color(0xFFFFCCC5);
const kPreviewBg = Color(0xFF1E2440);

class CrearUsuarioModal extends StatefulWidget {
  const CrearUsuarioModal({super.key});

  @override
  State<CrearUsuarioModal> createState() => _CrearUsuarioModalState();
}

class _CrearUsuarioModalState extends State<CrearUsuarioModal> {
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _passConf = TextEditingController();
  final _telefono = TextEditingController();
  final _numDoc = TextEditingController();
  final _fechaNac = TextEditingController();
  final _ciudad = TextEditingController();
  final _direccion = TextEditingController();

  bool _showPass = false;
  bool _showPassC = false;
  bool _usuarioActive = true;
  String _rol = 'Usuario';
  String _tipoDoc = 'CC';
  String? _genero;

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _pass.dispose();
    _passConf.dispose();
    _telefono.dispose();
    _numDoc.dispose();
    _fechaNac.dispose();
    _ciudad.dispose();
    _direccion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Container(
      height: mq.size.height * 0.95,
      decoration: const BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: kBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kOrange, kOrangeSoft],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_add_outlined,
                    color: kWhite,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crear Usuario',
                      style: TextStyle(
                        color: kWhite,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Completa los datos del nuevo usuario',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close, color: kWhite, size: 18),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              children: [
                _sectionHeader(
                  Icons.person_outline,
                  'Informacion Basica',
                  'Obligatorio',
                  labelColor: kOrange,
                ),
                const SizedBox(height: 12),
                _fieldLabel('NOMBRE COMPLETO *'),
                _inputField(
                  _nombre,
                  'Maria Garcia Lopez',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                _fieldLabel('CORREO ELECTRONICO *'),
                _inputField(
                  _email,
                  'maria.garcia@ejemplo.com',
                  icon: Icons.email_outlined,
                  keyType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _fieldLabel('CONTRASENA *'),
                _inputField(
                  _pass,
                  'Minimo 8 caracteres',
                  icon: Icons.lock_outline,
                  obscure: !_showPass,
                  suffix: IconButton(
                    icon: Icon(
                      _showPass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: kMuted,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _showPass = !_showPass),
                  ),
                ),
                const SizedBox(height: 12),
                _fieldLabel('CONFIRMAR CONTRASENA *'),
                _inputField(
                  _passConf,
                  'Repite la contrasena',
                  icon: Icons.lock_outline,
                  obscure: !_showPassC,
                  suffix: IconButton(
                    icon: Icon(
                      _showPassC
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: kMuted,
                      size: 18,
                    ),
                    onPressed: () => setState(() => _showPassC = !_showPassC),
                  ),
                ),
                const SizedBox(height: 12),
                _fieldLabel('TELEFONO'),
                _inputField(
                  _telefono,
                  '+57 300 123 4567',
                  icon: Icons.phone_outlined,
                  keyType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('TIPO DOC.'),
                          _dropdownField(
                            value: _tipoDoc,
                            items: const ['CC', 'CE', 'PA', 'NIT'],
                            onChanged: (v) =>
                                setState(() => _tipoDoc = v ?? 'CC'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('NUMERO'),
                          _inputField(
                            _numDoc,
                            '1234567890',
                            icon: Icons.badge_outlined,
                            keyType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('FECHA NAC.'),
                          _inputField(
                            _fechaNac,
                            'DD/MM/AAAA',
                            icon: Icons.cake_outlined,
                            keyType: TextInputType.datetime,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('GENERO'),
                          _dropdownField(
                            value: _genero,
                            hint: 'Seleccionar',
                            items: const ['Masculino', 'Femenino', 'Otro'],
                            onChanged: (v) => setState(() => _genero = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _sectionHeader(
                  Icons.location_on_outlined,
                  'Ubicacion',
                  null,
                  labelColor: kGreen,
                ),
                const SizedBox(height: 12),
                _fieldLabel('CIUDAD'),
                _inputField(_ciudad, '', icon: Icons.location_city_outlined),
                const SizedBox(height: 12),
                _fieldLabel('DIRECCION'),
                _inputField(
                  _direccion,
                  'Calle 123 #45-67, Apto 101',
                  icon: Icons.home_outlined,
                ),
                const SizedBox(height: 20),
                _sectionHeader(
                  Icons.shield_outlined,
                  'Permisos y Estado',
                  null,
                  labelColor: kLabelBlue,
                ),
                const SizedBox(height: 12),
                _fieldLabel('ROL DEL USUARIO *'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _roleChip(
                      'Usuario',
                      Icons.person_outline,
                      active: _rol == 'Usuario',
                      onTap: () => setState(() => _rol = 'Usuario'),
                    ),
                    const SizedBox(width: 10),
                    _roleChip(
                      'Admin',
                      Icons.admin_panel_settings_outlined,
                      active: _rol == 'Admin',
                      onTap: () => setState(() => _rol = 'Admin'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: kGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.toggle_on_outlined,
                          color: kGreen,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estado del Usuario',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: kTextDark,
                            ),
                          ),
                          Text(
                            'Usuario activo al crearse',
                            style: TextStyle(fontSize: 11, color: kMuted),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _usuarioActive = !_usuarioActive),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _usuarioActive
                                ? kGreenBg
                                : const Color(0xFFF3F4F8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _usuarioActive ? kGreen : kBorder,
                            ),
                          ),
                          child: Text(
                            _usuarioActive ? 'Activo' : 'Inactivo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _usuarioActive ? kGreen : kMuted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _fieldLabel('VISTA PREVIA'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: kPreviewBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: kOrange.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: kOrange,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nombre.text.isEmpty ? 'Sin nombre' : _nombre.text,
                            style: const TextStyle(
                              color: kWhite,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _email.text.isEmpty ? 'Sin correo' : _email.text,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: kOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _rol,
                          style: const TextStyle(
                            color: kWhite,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kMuted,
                          side: const BorderSide(color: kBorder),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.person_add_outlined, size: 18),
                        label: const Text(
                          'Crear Usuario',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kOrange,
                          foregroundColor: kWhite,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    IconData icon,
    String title,
    String? badge, {
    required Color labelColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: labelColor, size: 18),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14.5,
            color: kTextDark,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: kOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: kOrange,
              ),
            ),
          ),
        ],
        const Spacer(),
        Container(height: 1, width: 60, color: kBorder),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: kMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController ctrl,
    String hint, {
    IconData? icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyType,
        style: const TextStyle(fontSize: 13.5, color: kTextDark),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: kMuted.withOpacity(0.7), fontSize: 13),
          prefixIcon: icon != null ? Icon(icon, color: kMuted, size: 18) : null,
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 13,
          ),
          isDense: true,
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String? value,
    String? hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint ?? items.first,
            style: TextStyle(color: kMuted.withOpacity(0.7), fontSize: 13),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: kMuted, size: 18),
          style: const TextStyle(fontSize: 13.5, color: kTextDark),
          items: items
              .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _roleChip(
    String label,
    IconData icon, {
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: active ? kChipBg : kWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? kChipBord : kBorder,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: active ? kOrange : kMuted, size: 22),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: active ? kOrange : kMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
