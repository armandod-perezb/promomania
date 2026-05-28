// ============================================================================
// ARCHIVO: manage_stores_screen.dart
// PROPÓSITO: Pantalla de gestión CRUD de comercios (supermercados) del panel admin.
//            Permite crear comercios, alternar su estado activo/pausado y eliminarlos.
//            Incluye el modal CrearComercioModal en el mismo archivo.
// PATRÓN: StatefulWidget con AnimatedBuilder sobre ChangeNotifier global.
//         La lógica de datos se delega completamente a promoService.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart';
import '../../../../../Core/Routes/app_routes.dart'; // Rutas nombradas de la app
import '../../../../../Core/di/app_scope.dart'; // Expone promoService (ChangeNotifier global)
import '../../../../../features/promotions/domain/entities/supermercado.dart'; // Entity Supermercado con copyWith

// ============================================================================
// WIDGET PRINCIPAL: ManageStoresScreen
// ============================================================================
class ManageStoresScreen extends StatefulWidget {
  const ManageStoresScreen({super.key});

  @override
  State<ManageStoresScreen> createState() => _ManageStoresScreenState();
}

class _ManageStoresScreenState extends State<ManageStoresScreen> {
  // ── Estado local ────────────────────────────────────────────────────────────
  // Índice del ítem activo en el BottomNav. Valor 3 = "Comercios".
  int _selectedIndex = 3;

  // Constantes de color como static const → compiladas en tiempo de build,
  // accesibles en todos los métodos sin instanciar.
  static const Color primaryOrange = Color(0xFFFF5733);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGray = Color(0xFF8A8A9A);
  static const Color greenAccent = Color(0xFF2ECC71);
  static const Color bgColor = Color(0xFFF5F5F8);

  // Getter reactivo: siempre retorna la lista actualizada de supermercados.
  // Al ser un getter (no una variable), siempre apunta al estado más reciente
  // de promotionsController.getSupermercadosSync() sin necesidad de setState().
  List<Supermercado> get _stores => promotionsController.getSupermercadosSync();

  // ============================================================================
  // BUILD PRINCIPAL
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder se suscribe a promoService (ChangeNotifier).
    // Cuando promoService llama notifyListeners(), toda la pantalla se reconstruye,
    // reflejando cambios en la lista de comercios (crear, editar, eliminar).
    return Consumer<PromoService>(
      builder: (context, promoService, child) {
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
                        // Título "Comercios" + contador + botón "Nuevo Comercio".
                        _buildTitleRow(),
                        const SizedBox(height: 20),
                        // Spread operator: genera un _buildStoreCard por cada comercio.
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
      },
    );
  }

  // ============================================================================
  // TOP BAR
  // Idéntica estructuralmente a ManagePromotionsScreen.
  // Logo rectangular "AP", nombre de la app, avatar navegable al perfil.
  // ============================================================================
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

  // ============================================================================
  // TITLE ROW
  // A diferencia de ManagePromotionsScreen, aquí el título incluye un subtítulo
  // dinámico con el conteo de comercios: '${_stores.length} comercios registrados'.
  // ============================================================================
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
            // Contador dinámico: se actualiza con cada reconstrucción del widget
            Text(
              '${_stores.length} comercios registrados',
              style: const TextStyle(color: textGray, fontSize: 12),
            ),
          ],
        ),
        // Botón CTA que abre el modal de creación de comercios
        GestureDetector(
          onTap: () => _showCrearComercioModal(),
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

  // Abre el BottomSheet de creación de comercios.
  void _showCrearComercioModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CrearComercioModal(),
    );
  }

  // ============================================================================
  // STORE CARD
  // Tarjeta de cada comercio con:
  //   1. Header: ícono emoji 🏪, nombre, dirección, indicador de estado.
  //   2. Chip de estado: "Activo" (verde) o "Pausado" (naranja).
  //   3. Acciones: Ver Promos (sin implementar), Pausar/Reanudar toggle, Eliminar.
  //
  // LÓGICA DE ESTADO:
  //   isPaused = store.estado != 'activo'
  //   Cualquier valor diferente de 'activo' se considera pausado.
  // ============================================================================
  Widget _buildStoreCard(Supermercado store) {
    // isPaused es true para cualquier estado diferente de 'activo' (ej: 'inactivo')
    final isPaused = store.estado != 'activo';

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
          // ── Header del comercio ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícono del comercio usando emoji (no un Image.asset ni Icon)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('🏪', style: TextStyle(fontSize: 26)),
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
                              store.nombre,
                              style: const TextStyle(
                                color: textDark,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Punto de color: naranja=pausado, verde=activo
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
                      // Dirección: muestra 'Sin dirección' si el campo es null
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
                              store.direccion ?? 'Sin dirección',
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
                      // Chip de estado con color dinámico
                      Row(children: [_statusChip(isPaused)]),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const SizedBox(height: 14),
          // Separador horizontal entre header y acciones
          Container(height: 1, color: const Color(0xFFF0F0F5)),

          // ── Botones de acción ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // "Ver Promos": outline, sin funcionalidad implementada (onTap: () {})
                Expanded(
                  child: _outlineBtn(
                    icon: Icons.local_offer_outlined,
                    label: 'Ver Promos',
                    onTap:
                        () {}, // TODO: Implementar navegación a promos del comercio
                  ),
                ),
                const SizedBox(width: 10),
                // Toggle de estado: muestra "Pausar" si está activo, "Reanudar" si está pausado.
                // El color cambia con la acción disponible (no con el estado actual).
                Expanded(
                  child: _pauseBtn(
                    isPaused: isPaused,
                    onTap: () => _toggleStatus(store),
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

  // ============================================================================
  // TOGGLE STATUS
  // Alterna el estado del comercio entre 'activo' e 'inactivo'.
  // Usa copyWith para inmutabilidad: crea un nuevo objeto Supermercado
  // con solo el campo `estado` modificado.
  // promotionsController.updateSupermercado() persiste el cambio y llama notifyListeners().
  // ============================================================================
  void _toggleStatus(Supermercado store) {
    final updated = store.copyWith(
      estado: store.estado == 'activo' ? 'inactivo' : 'activo',
    );
    promotionsController.updateSupermercado(updated);
    setState(() {}); // Reconstrucción adicional de seguridad
  }

  // ============================================================================
  // CONFIRM DELETE
  // AlertDialog de confirmación. Elimina por store.id (clave primaria entera).
  // A diferencia de Promocion que elimina por código (String),
  // Supermercado usa id (int) como identificador.
  // ============================================================================
  void _confirmDelete(Supermercado store) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Supermercado'),
        content: Text('¿Eliminar "${store.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              promotionsController.deleteSupermercado(
                store.id,
              ); // Elimina por ID entero
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Supermercado eliminado')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // ── WIDGETS AUXILIARES ────────────────────────────────────────────────────────

  // Chip de estado con punto de color y etiqueta.
  // isPaused=true → naranja/Pausado | isPaused=false → verde/Activo
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

  // Botón outline reutilizable para acciones secundarias.
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

  // Botón de pausa/reanudación con colores y texto dinámicos según estado.
  // isPaused=true → verde/Reanudar | isPaused=false → naranja/Pausar
  // El borde también cambia de color para reforzar la acción disponible.
  Widget _pauseBtn({required bool isPaused, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          // Fondo verde si pausado (acción = reanudar), naranja si activo (acción = pausar)
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

  // Botón de eliminar cuadrado fijo 42×42px.
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

  // ============================================================================
  // NAVEGACIÓN
  // ============================================================================
  String _routeForIndex(int index) {
    switch (index) {
      case 0:
        return AppRoutes.adminDashboard;
      case 1:
        return AppRoutes.manageUsers;
      case 2:
        return AppRoutes.managePromotions;
      case 3:
        return AppRoutes.manageStores; // Esta pantalla
      default:
        return AppRoutes.manageNotifications;
    }
  }

  void _onBottomNavTap(int index) {
    if (index == _selectedIndex) return;
    Navigator.pushReplacementNamed(context, _routeForIndex(index));
  }

  // Bottom nav con AnimatedContainer igual al de ManagePromotionsScreen.
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

// ============================================================================
// WIDGET SECUNDARIO: CrearComercioModal
// BottomSheet modal para registrar un nuevo comercio.
// Más simple que CrearPromoModal: solo nombre (obligatorio), dirección y ciudad.
//
// GENERACIÓN DE ID:
//   newId = max(ids existentes) + 1
//   Si la lista está vacía, parte desde id=1.
//   Usa Iterable.reduce() para encontrar el máximo.
//   LIMITACIÓN: No es thread-safe. En producción se debería usar un ID
//   generado por el backend/base de datos.
//
// CAMPOS OPCIONALES:
//   dirección y ciudad se pasan como null si están vacíos,
//   ya que el modelo Supermercado los acepta como nullable.
// ============================================================================
class CrearComercioModal extends StatefulWidget {
  const CrearComercioModal({super.key});

  @override
  State<CrearComercioModal> createState() => _CrearComercioModalState();
}

class _CrearComercioModalState extends State<CrearComercioModal> {
  // Controladores de los tres campos del formulario
  final _nombre = TextEditingController();
  final _direccion = TextEditingController();
  final _ciudad = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    _direccion.dispose();
    _ciudad.dispose();
    super.dispose();
  }

  // ============================================================================
  // CREAR COMERCIO — Lógica de validación y persistencia
  //
  // Generación del ID:
  //   Si no hay supermercados → newId = 1
  //   Si hay supermercados → newId = max(s.id para todo s en lista) + 1
  //   .reduce((a, b) => a > b ? a : b) es equivalente a max() sobre la colección.
  // ============================================================================
  void _crearComercio() {
    if (_nombre.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El nombre es obligatorio')));
      return;
    }

    // Genera un ID incremental basado en el máximo existente
    final newId =
        (promotionsController.getSupermercadosSync().isEmpty
            ? 0
            : promotionsController.getSupermercadosSync()
                  .map((s) => s.id)
                  .reduce((a, b) => a > b ? a : b)) +
        1;

    final nuevoComercio = Supermercado(
      id: newId,
      nombre: _nombre.text,
      // Campo vacío → null (el operador ternario convierte string vacío a null)
      direccion: _direccion.text.isEmpty ? null : _direccion.text,
      ciudad: _ciudad.text.isEmpty ? null : _ciudad.text,
      estado: 'activo', // Todo comercio nuevo inicia como activo
    );

    promotionsController.addSupermercado(nuevoComercio);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comercio creado exitosamente')),
    );

    Navigator.pop(context);
  }

  // ============================================================================
  // BUILD DEL MODAL
  // Ocupa el 60% de la pantalla (menos que CrearPromoModal que ocupa el 75%
  // porque tiene menos campos).
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.60,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Drag handle estándar de BottomSheet
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              children: [
                const Text(
                  'Crear Comercio',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Campo: Nombre (obligatorio) ──────────────────────────────
                const Text(
                  'NOMBRE DEL COMERCIO *',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8A8A9A),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nombre,
                  decoration: InputDecoration(
                    hintText: 'Ej: Supermercado La Esquina',
                    hintStyle: TextStyle(
                      color: Colors.grey.withOpacity(0.5),
                      fontSize: 13,
                    ),
                    // prefixIcon con ícono de storefront para contexto visual
                    prefixIcon: const Icon(
                      Icons.storefront_outlined,
                      color: Color(0xFF8A8A9A),
                      size: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFEEEEF2)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Campo: Dirección (opcional) ──────────────────────────────
                const Text(
                  'DIRECCIÓN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8A8A9A),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _direccion,
                  decoration: InputDecoration(
                    hintText: 'Calle 123 #45-67',
                    hintStyle: TextStyle(
                      color: Colors.grey.withOpacity(0.5),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF8A8A9A),
                      size: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFEEEEF2)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Campo: Ciudad (opcional) ─────────────────────────────────
                const Text(
                  'CIUDAD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8A8A9A),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _ciudad,
                  decoration: InputDecoration(
                    hintText: 'Bogotá',
                    hintStyle: TextStyle(
                      color: Colors.grey.withOpacity(0.5),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.location_city_outlined,
                      color: Color(0xFF8A8A9A),
                      size: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFEEEEF2)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Botones del formulario ────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF8A8A9A),
                          side: const BorderSide(color: Color(0xFFEEEEF2)),
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
                    // Botón principal con flex:2 para ocupar más espacio visual
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _crearComercio,
                        icon: const Icon(Icons.add_outlined, size: 18),
                        label: const Text(
                          'Crear Comercio',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5733),
                          foregroundColor: Colors.white,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
