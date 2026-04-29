// ============================================================================
// ARCHIVO: manage_promotions_screen.dart
// PROPÓSITO: Pantalla de gestión CRUD completa de promociones del panel admin.
//            Permite crear, editar, aprobar/rechazar y eliminar promociones.
//            Incluye el modal CrearPromoModal como widget independiente en el
//            mismo archivo.
// PATRÓN: StatefulWidget con AnimatedBuilder sobre ChangeNotifier global.
//         Lógica de negocio delegada a promoService (servicio global).
// ============================================================================

import 'package:flutter/material.dart';
import '../Core/Routes/app_routes.dart'; // Rutas nombradas de la app
import '../main.dart';                   // Expone promoService y sessionManager
import '../models/promocion.dart';       // Modelo de datos Promocion con copyWith

// ── Paleta de colores como static const (dentro de la clase de estado) ───────
// Se definen como static const para que sean accesibles sin instancia y el
// compilador las trate como constantes de compilación.

// ============================================================================
// WIDGET PRINCIPAL: ManagePromotionsScreen
// ============================================================================
class ManagePromotionsScreen extends StatefulWidget {
  const ManagePromotionsScreen({super.key});

  @override
  State<ManagePromotionsScreen> createState() => _ManagePromotionsScreenState();
}

class _ManagePromotionsScreenState extends State<ManagePromotionsScreen> {

  // ── Estado local ────────────────────────────────────────────────────────────
  // Índice del ítem activo en el BottomNav. Valor 2 = "Promos".
  int _selectedIndex = 2;

  // Constantes de color declaradas como static const dentro de la clase de
  // estado. Esto las hace accesibles en todos los métodos sin necesidad de
  // pasarlas como parámetros.
  static const Color primaryOrange = Color(0xFFFF5733); // Naranja principal
  static const Color textDark      = Color(0xFF1A1A2E); // Texto oscuro principal
  static const Color textGray      = Color(0xFF8A8A9A); // Texto secundario
  static const Color greenAccent   = Color(0xFF2ECC71); // Verde para estados activos
  static const Color bgColor       = Color(0xFFF5F5F8); // Fondo general

  // Getter que delega al servicio global para obtener la lista reactiva
  // de promociones. Al ser un getter, siempre retorna el estado más reciente.
  List<Promocion> get _promos => promoService.promociones;

  // ============================================================================
  // BUILD PRINCIPAL
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder se suscribe a promoService (ChangeNotifier).
    // Cada vez que promoService llama notifyListeners(), esta pantalla
    // se reconstruye, actualizando la lista de promociones automáticamente.
    return AnimatedBuilder(
      animation: promoService,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                // Barra superior con logo, nombre de la app y avatar.
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título "Promociones" + botón "Nueva Promo".
                        _buildTitleRow(),
                        const SizedBox(height: 20),
                        // Spread operator (...) para insertar todas las tarjetas
                        // de promoción como widgets hijos directos del Column.
                        // Cada Promocion del getter _promos genera un _buildPromoCard.
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
      },
    );
  }

  // ============================================================================
  // TOP BAR
  // Logo rectangular "AP" (Admin Panel), nombre de la app y avatar navegable.
  // A diferencia de las pantallas de avisos, usa BorderRadius en lugar de
  // BoxShape.circle para el logo.
  // ============================================================================
  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Logo "AP" con esquinas redondeadas (no circular)
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
          // Avatar del admin → navega al perfil
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
  // Fila con el título de sección y el botón CTA "Nueva Promo".
  // Al tocar el botón, se abre un BottomSheet con CrearPromoModal.
  // ============================================================================
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
        // Botón naranja que abre el modal de creación
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

  // Abre el BottomSheet de creación de promociones.
  // isScrollControlled: true permite que el modal ocupe más del 50% de pantalla.
  // backgroundColor: transparent para que el Container interior maneje el fondo.
  void _showCrearPromoModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CrearPromoModal(),
    );
  }

  // ============================================================================
  // PROMO CARD
  // Tarjeta completa de una promoción con secciones:
  //   1. Header: badge de descuento, título, supermercado, fechas y estado.
  //   2. Código promocional: fondo oscuro con QR decorativo.
  //   3. Stats: canjes (fijo en 0), vistas (dinámico), conversión (fija en 0%).
  //   4. Acciones: Editar, Aprobar/Aprobada, Eliminar.
  // ============================================================================
  Widget _buildPromoCard(Promocion promo) {
    // Una promo es activa solo cuando su estado es exactamente 'aprobada'.
    final bool isActive = promo.estado == 'aprobada';
    // Muestra 0% si el campo descuento es null (campo opcional en el modelo).
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
          // ── Sección 1: Header de la tarjeta ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge cuadrado con el porcentaje de descuento
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
                // Columna de información: título, supermercado, fechas
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              promo.titulo,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis, // Trunca si es muy largo
                              style: const TextStyle(
                                color: textDark,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Badge de estado: verde=Activa, rojo=Expirada
                          _statusBadge(isActive),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Identificador del supermercado asociado
                      Row(
                        children: [
                          const Icon(Icons.storefront_outlined, size: 13, color: textGray),
                          const SizedBox(width: 4),
                          Text(
                            'Supermercado #${promo.idSupermercado}',
                            style: const TextStyle(color: textGray, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Rango de vigencia de la promoción
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 12, color: textGray),
                          const SizedBox(width: 4),
                          Text(
                            '${promo.fechaInicio} → ${promo.fechaFin}',
                            style: const TextStyle(color: textGray, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Sección 2: Código promocional ─────────────────────────────────
          // Fondo oscuro con el código en letras grandes y un ícono de QR decorativo.
          _buildCodeSection(promo.codigo),

          // ── Sección 3: Estadísticas de la promo ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                _statItem('0', 'Canjes'),         // Hardcoded: aún sin implementar
                _verticalDivider(),
                _statItem(promo.vistas.toString(), 'Vistas'), // Dinámico desde el modelo
                _verticalDivider(),
                _conversionStat(0),               // Hardcoded: cálculo pendiente
              ],
            ),
          ),

          // ── Sección 4: Botones de acción ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Botón outline para editar: abre AlertDialog con campos de edición
                Expanded(
                  child: _outlineBtn(
                    icon: Icons.edit_outlined,
                    label: 'Editar',
                    onTap: () => _editPromo(promo),
                  ),
                ),
                const SizedBox(width: 10),
                // Botón sólido que actúa como toggle de aprobación:
                // Si está aprobada → muestra "Aprobada" y permite revertir a 'rechazada'
                // Si no está aprobada → muestra "Aprobar" y permite cambiar a 'aprobada'
                Expanded(
                  child: isActive
                      ? _solidBtn(
                          icon: Icons.check_circle_outline,
                          label: 'Aprobada',
                          onTap: () => _changeStatus(promo, 'rechazada'),
                        )
                      : _solidBtn(
                          icon: Icons.check_circle_outline,
                          label: 'Aprobar',
                          onTap: () => _changeStatus(promo, 'aprobada'),
                        ),
                ),
                const SizedBox(width: 10),
                // Botón de eliminar con fondo rojo translúcido
                _deleteBtn(onTap: () => _confirmDelete(promo)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // CHANGE STATUS
  // Actualiza el estado de una promoción en el servicio global.
  // Usa el patrón copyWith para crear un objeto nuevo con el campo modificado,
  // preservando inmutabilidad. Llama setState() para forzar reconstrucción local
  // además de la que hace AnimatedBuilder.
  // ============================================================================
  void _changeStatus(Promocion promo, String nuevoEstado) {
    final updated = promo.copyWith(estado: nuevoEstado);
    promoService.updatePromocion(updated); // Persiste en el servicio y notifica
    setState(() {}); // Reconstrucción adicional por seguridad
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Promoción: $nuevoEstado')),
    );
  }

  // ============================================================================
  // EDIT PROMO
  // Abre un AlertDialog con dos TextField para editar título y descripción.
  // Usa TextEditingController inicializados con los valores actuales de la promo.
  // Al guardar, actualiza via promoService.updatePromocion() con copyWith.
  // NOTA: Los controladores no tienen dispose() aquí porque el dialog
  // gestiona su propio ciclo de vida al cerrarse.
  // ============================================================================
  void _editPromo(Promocion promo) {
    final tituloCtrl  = TextEditingController(text: promo.titulo);
    final descCtrl    = TextEditingController(text: promo.descripcion ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Promoción'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = promo.copyWith(
                titulo:      tituloCtrl.text,
                descripcion: descCtrl.text,
              );
              promoService.updatePromocion(updated);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Promoción actualizada')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // CONFIRM DELETE
  // Muestra un AlertDialog de confirmación antes de eliminar.
  // Usa promoService.deletePromocion(promo.codigo) — el código es el
  // identificador primario de la promoción en el modelo de datos.
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
            onPressed: () {
              promoService.deletePromocion(promo.codigo); // Elimina por código
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

  // ── WIDGETS AUXILIARES DE LA TARJETA ─────────────────────────────────────────

  // Badge de estado: verde con "Activa" o rojo con "Expirada".
  // Incluye un punto de color como indicador visual adicional.
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
          // Punto de color como indicador de estado
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

  // Sección del código promocional con fondo oscuro (textDark).
  // El ícono de QR es decorativo: no genera ni lee códigos reales.
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
              // Código en mayúsculas con letterSpacing para legibilidad
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
          // Ícono QR decorativo — sin funcionalidad de generación de QR real
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  // Columna de estadística individual (Canjes / Vistas).
  // Expanded para que cada columna ocupe el mismo espacio horizontal.
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

  // Separador vertical entre columnas de estadísticas.
  Widget _verticalDivider() {
    return Container(width: 1, height: 36, color: const Color(0xFFEEEEF2));
  }

  // Columna de conversión en porcentaje con color verde.
  // El valor `pct` es fijo en 0 — pendiente de implementar cálculo real.
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
          const Text('Conversión', style: TextStyle(color: textGray, fontSize: 12)),
        ],
      ),
    );
  }

  // Botón con borde (outline) para acciones secundarias como "Editar".
  // Recibe ícono, texto y callback como parámetros requeridos.
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

  // Botón sólido (fondo oscuro) para acciones primarias como "Aprobar".
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

  // Botón de eliminar: cuadrado fijo de 42×42px con fondo rojo translúcido.
  // No es Expanded, por eso tiene dimensiones fijas y no ocupa espacio flexible.
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
  // NAVEGACIÓN — BOTTOM NAV
  // Mapea índice a ruta y navega usando pushReplacementNamed.
  // ============================================================================
  String _routeForIndex(int index) {
    switch (index) {
      case 0: return AppRoutes.adminDashboard;
      case 1: return AppRoutes.manageUsers;
      case 2: return AppRoutes.managePromotions; // Esta pantalla
      case 3: return AppRoutes.manageStores;
      default: return AppRoutes.manageNotifications;
    }
  }

  void _onBottomNavTap(int index) {
    if (index == _selectedIndex) return;
    Navigator.pushReplacementNamed(context, _routeForIndex(index));
  }

  // ============================================================================
  // BOTTOM NAV
  // A diferencia de las pantallas de avisos, este BottomNav usa AnimatedContainer
  // con una duración de 200ms para animar el fondo del ítem seleccionado.
  // El ítem activo tiene un fondo naranja con 12% de opacidad.
  // ============================================================================
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.dashboard_outlined,    'label': 'Panel'},
      {'icon': Icons.people_outline,        'label': 'Usuarios'},
      {'icon': Icons.local_offer_outlined,  'label': 'Promos'},
      {'icon': Icons.storefront_outlined,   'label': 'Comercios'},
      {'icon': Icons.notifications_outlined,'label': 'Avisos'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x10000000), blurRadius: 12, offset: Offset(0, -2)),
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
              // Animación de 200ms al cambiar el estado del ítem
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                // Fondo naranja translúcido en el ítem activo
                color: selected ? primaryOrange.withOpacity(0.12) : Colors.transparent,
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
                      fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
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
// WIDGET SECUNDARIO: CrearPromoModal
// BottomSheet modal para crear nuevas promociones.
// Es un StatefulWidget independiente dentro del mismo archivo para mantener
// cohesión con la pantalla que lo invoca.
//
// CAMPOS DEL FORMULARIO:
//   - codigo (String, obligatorio): identificador único de la promo
//   - titulo (String, obligatorio): nombre de la promoción
//   - descripcion (String, opcional): detalles adicionales
//   - precio (double, obligatorio): precio base del producto
//   - descuento (int, opcional): porcentaje de descuento
//   - estado: siempre inicia en 'pendiente'
//
// VALIDACIÓN: Se verifica que código, título y precio no estén vacíos antes
// de crear el objeto Promocion.
// ============================================================================
class CrearPromoModal extends StatefulWidget {
  const CrearPromoModal({super.key});

  @override
  State<CrearPromoModal> createState() => _CrearPromoModalState();
}

class _CrearPromoModalState extends State<CrearPromoModal> {

  // ── Controladores de texto ──────────────────────────────────────────────────
  // Cada campo del formulario tiene su propio TextEditingController.
  // Se liberan en dispose() para evitar memory leaks.
  final _titulo      = TextEditingController();
  final _descripcion = TextEditingController();
  final _precio      = TextEditingController();
  final _descuento   = TextEditingController();
  final _codigo      = TextEditingController();

  // Estado inicial de la promoción al crear: siempre 'pendiente'.
  // El admin debe aprobarla manualmente desde la pantalla principal.
  String _estado = 'pendiente';

  @override
  void dispose() {
    // Libera todos los controladores al destruir el widget.
    // IMPORTANTE: Omitir esto causaría memory leaks en apps de larga duración.
    _titulo.dispose();
    _descripcion.dispose();
    _precio.dispose();
    _descuento.dispose();
    _codigo.dispose();
    super.dispose();
  }

  // ============================================================================
  // CREAR PROMOCIÓN — Lógica de validación y persistencia
  //
  // Flujo:
  //   1. Valida campos obligatorios (título, código, precio). Muestra SnackBar si falla.
  //   2. Construye objeto Promocion con valores del formulario.
  //   3. Llama promoService.addPromocion() para persistir y notificar.
  //   4. Cierra el modal con Navigator.pop().
  //
  // Conversión de tipos:
  //   - precio: String → double con double.tryParse() || 0.0 (fallback seguro)
  //   - descuento: String → int con int.tryParse() → puede ser null (campo opcional)
  //   - idUsuario: se obtiene de sessionManager.usuarioActual?.id ?? 1 (fallback)
  // ============================================================================
  void _crearPromocion() {
    // Validación secuencial de campos obligatorios
    if (_titulo.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es obligatorio')),
      );
      return;
    }
    if (_codigo.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El código es obligatorio')),
      );
      return;
    }
    if (_precio.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El precio es obligatorio')),
      );
      return;
    }

    // Construcción del objeto Promocion con valores del formulario
    final nuevaPromo = Promocion(
      codigo:            _codigo.text,
      titulo:            _titulo.text,
      descripcion:       _descripcion.text,
      precio:            double.tryParse(_precio.text) ?? 0.0, // Conversión segura
      descuento:         int.tryParse(_descuento.text),         // null si está vacío
      condicionProducto: 'nuevo',      // Valor por defecto hardcoded
      tipoVigencia:      'por_fecha',  // Valor por defecto hardcoded
      estado:            _estado,      // Siempre 'pendiente' al crear
      vistas:            0,            // Inicia sin vistas
      idUsuario:         sessionManager.usuarioActual?.id ?? 1, // ID del admin actual
      idSupermercado:    1,            // Hardcoded: debería ser seleccionable
      idCategoria:       1,            // Hardcoded: debería ser seleccionable
      idTipoPromocion:   1,            // Hardcoded: debería ser seleccionable
    );

    promoService.addPromocion(nuevaPromo); // Persiste y dispara notifyListeners()

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Promoción creada exitosamente')),
    );

    Navigator.pop(context); // Cierra el BottomSheet
  }

  // ============================================================================
  // BUILD DEL MODAL
  // Ocupa el 75% de la altura de la pantalla.
  // Usa BorderRadius.vertical para redondear solo la parte superior.
  // El indicador de arrastre (línea gris) sigue la convención de Material Design.
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    return Container(
      // 75% de la altura total de la pantalla
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        // Solo esquinas superiores redondeadas (patrón estándar de BottomSheet)
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Indicador de arrastre (drag handle): convención visual de BottomSheet
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // ListView para scroll interno del formulario
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              children: [
                const Text(
                  'Crear Promoción',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Campo: Código (obligatorio) ──────────────────────────────
                const Text(
                  'CÓDIGO *',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8A8A9A),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _codigo,
                  decoration: InputDecoration(
                    hintText: 'PROMO2024',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFEEEEF2)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Campo: Título (obligatorio) ──────────────────────────────
                const Text(
                  'TÍTULO *',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8A8A9A),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _titulo,
                  decoration: InputDecoration(
                    hintText: 'Descuento especial en frutas',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFEEEEF2)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Campo: Descripción (opcional, 3 líneas) ──────────────────
                const Text(
                  'DESCRIPCIÓN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8A8A9A),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _descripcion,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Detalles de la promoción...',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFEEEEF2)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Fila: Precio y Descuento (lado a lado) ───────────────────
                // Usa Row con dos Expanded para dividir el espacio equitativamente.
                Row(
                  children: [
                    // Campo precio: teclado numérico, obligatorio
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PRECIO *',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8A8A9A),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _precio,
                            keyboardType: TextInputType.number, // Teclado numérico
                            decoration: InputDecoration(
                              hintText: '19.99',
                              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 13),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFEEEEF2)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Campo descuento: opcional, int
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DESCUENTO %',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF8A8A9A),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _descuento,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '20',
                              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 13),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFEEEEF2)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Botones de acción del formulario ─────────────────────────
                Row(
                  children: [
                    // Cancelar: 1/3 del espacio (flex:1)
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
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Crear: 2/3 del espacio (flex:2) — mayor prominencia visual
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _crearPromocion,
                        icon: const Icon(Icons.add_outlined, size: 18),
                        label: const Text(
                          'Crear Promoción',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5733),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0, // Sin sombra: look flat
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