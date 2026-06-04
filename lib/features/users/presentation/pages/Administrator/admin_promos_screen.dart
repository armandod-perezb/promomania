import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart';
import '../../../../../Core/Routes/app_routes.dart';
import '../../../../../Core/di/app_scope.dart';
import '../../../../../features/promotions/domain/entities/promocion.dart';
import '../../../../../features/promotions/presentation/widgets/modals/crear_promo_modal.dart';
import '../../../../../features/promotions/presentation/widgets/modals/editar_promo_modal.dart';

/// Pantalla administrativa para revisar, aprobar y mantener promociones.
class ManagePromotionsScreen extends StatefulWidget {
  const ManagePromotionsScreen({super.key});

  @override
  State<ManagePromotionsScreen> createState() => _ManagePromotionsScreenState();
}

/// Estado interno de `ManagePromotionsScreen`; coordina datos, eventos y reconstrucciones de la pantalla.
class _ManagePromotionsScreenState extends State<ManagePromotionsScreen> {
  int _selectedIndex = 2;
  // Estado de carga para mostrar loader mientras se cargan datos
  bool _isLoading = true;

  static const Color primaryOrange = Color(0xFFFF5733);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGray = Color(0xFF8A8A9A);
  static const Color greenAccent = Color(0xFF2ECC71);
  static const Color bgColor = Color(0xFFF5F5F8);
  static const Color yellowAccent = Color(0xFFF39C12); // Para 'pendiente'

  List<Promocion> get _promos => promoService.promociones;

  @override
  void initState() {
    super.initState();
    // Cargar datos al entrar a la pantalla
    _loadData();
  }

  /// Carga datos desde el backend
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await promoService.reinitializeFromApi();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PromoService>(
      builder: (context, promoService, child) {
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryOrange,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: primaryOrange,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTitleRow(),
                                const SizedBox(height: 20),
                                if (_promos.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 40),
                                    child: Center(
                                      child: Text(
                                        'No se encontraron promociones',
                                        style: TextStyle(
                                          color: textGray,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ..._promos.map((p) => _buildPromoCard(p)),
                              ],
                            ),
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
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.userProfile),
            child: Container(
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
          ),
        ],
      ),
    );
  }

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
          onTap: () => _showCrearPromoModal(),
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

  void _showCrearPromoModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CrearPromoModal(),
    );
  }

  void _showEditarPromoModal(Promocion promo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditarPromoModal(promocion: promo),
    );
  }

  // ============================================================================
  // PROMO CARD — con badge de estado tri-color y botones aprobar/rechazar
  // ============================================================================
  Widget _buildPromoCard(Promocion promo) {
    final badge = '${promo.descuento ?? 0}%';

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
          // ── Header ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge de descuento
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: primaryOrange,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          height: 1.1,
                        ),
                      ),
                      const Text(
                        'OFF',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              promo.titulo,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: textDark,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // ── BADGE DE ESTADO TRI-COLOR ──────────────────────
                          // aprobada → verde | pendiente → amarillo | rechazada → rojo
                          _estadoBadge(promo.estado),
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
                            'Supermercado #${promo.idSupermercado}',
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
                            promo.tipoVigencia == 'permanente'
                                ? 'Permanente'
                                : '${promo.fechaInicio ?? '-'} → ${promo.fechaFin ?? '-'}',
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
                            Icons.label_outline,
                            size: 12,
                            color: textGray,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            promo.condicionProducto,
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

          // ── Código promocional ───────────────────────────────────────────────
          _buildCodeSection(promo.codigo),

          // ── Stats ────────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                _statItem('0', 'Canjes'),
                _verticalDivider(),
                _statItem(promo.vistas.toString(), 'Vistas'),
                _verticalDivider(),
                _conversionStat(0),
              ],
            ),
          ),

          // ── Botones de acción ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Fila 1: Editar + Eliminar
                Row(
                  children: [
                    Expanded(
                      child: _outlineBtn(
                        icon: Icons.edit_outlined,
                        label: 'Editar',
                        onTap: () => _editPromo(promo),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _deleteBtn(onTap: () => _confirmDelete(promo)),
                  ],
                ),
                const SizedBox(height: 10),
                // Fila 2: Aprobar / Rechazar — cambia según estado actual
                _buildApprovalButtons(promo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // BADGE DE ESTADO TRI-COLOR
  // verde   → aprobada
  // amarillo→ pendiente
  // rojo    → rechazada (o cualquier otro valor)
  // ============================================================================
  Widget _estadoBadge(String estado) {
    Color color;
    String label;
    IconData icon;

    switch (estado) {
      case 'aprobada':
        color = greenAccent;
        label = 'Aprobada';
        icon = Icons.check_circle_outline;
        break;
      case 'pendiente':
        color = yellowAccent;
        label = 'Pendiente';
        icon = Icons.hourglass_top_outlined;
        break;
      default: // 'rechazada'
        color = Colors.red;
        label = 'Rechazada';
        icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // BOTONES DE APROBACIÓN — lógica según estado actual
  //
  //  pendiente  → [✓ Aprobar]  [✗ Rechazar]
  //  aprobada   → [✗ Rechazar] (ya aprobada, solo puede revertirse)
  //  rechazada  → [✓ Aprobar]  (ya rechazada, solo puede reaprobarse)
  // ============================================================================
  Widget _buildApprovalButtons(Promocion promo) {
    switch (promo.estado) {
      case 'pendiente':
        // Ambos botones visibles: el admin decide
        return Row(
          children: [
            Expanded(
              child: _aprobarBtn(onTap: () => _changeStatus(promo, 'aprobada')),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _rechazarBtn(
                onTap: () => _changeStatus(promo, 'rechazada'),
              ),
            ),
          ],
        );

      case 'aprobada':
        // Solo mostrar opción de revocar aprobación
        return _rechazarBtn(
          label: 'Revocar aprobación',
          onTap: () => _changeStatus(promo, 'rechazada'),
        );

      default: // 'rechazada'
        // Solo mostrar opción de aprobar nuevamente
        return _aprobarBtn(
          label: 'Aprobar de nuevo',
          onTap: () => _changeStatus(promo, 'aprobada'),
        );
    }
  }

  // Botón verde "Aprobar"
  Widget _aprobarBtn({String label = 'Aprobar', required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: greenAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 15,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Botón rojo "Rechazar"
  Widget _rechazarBtn({
    String label = 'Rechazar',
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel_outlined, size: 15, color: Colors.red),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // CHANGE STATUS
  // ============================================================================
  Future<void> _changeStatus(Promocion promo, String nuevoEstado) async {
    final updated = promo.copyWith(estado: nuevoEstado);
    try {
      await promotionsController.updatePromotion(updated);
      setState(() {});
      if (!mounted) return;
      final msg = nuevoEstado == 'aprobada'
          ? '✓ Promoción aprobada'
          : '✗ Promoción rechazada';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar estado: $e')),
      );
    }
  }

  // ============================================================================
  // EDIT PROMO
  // ============================================================================
  void _editPromo(Promocion promo) {
    _showEditarPromoModal(promo);
  }

  // ============================================================================
  // CONFIRM DELETE
  // ============================================================================
  void _confirmDelete(Promocion promo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Promoción'),
        content: Text('¿Eliminar "${promo.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await promotionsController.deletePromotion(promo.codigo);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No se pudo eliminar: $e')),
                );
                return;
              }
              if (!mounted || !ctx.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Promoción eliminada')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // ── Widgets auxiliares ───────────────────────────────────────────────────────

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

  Widget _verticalDivider() =>
      Container(width: 1, height: 36, color: const Color(0xFFEEEEF2));

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

  // ── Navegación ───────────────────────────────────────────────────────────────

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
