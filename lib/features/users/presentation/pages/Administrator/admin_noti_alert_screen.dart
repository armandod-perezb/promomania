import 'package:flutter/material.dart';
import '../../../../../Core/Routes/app_routes.dart';
import '../../../../../Core/di/app_scope.dart';

/// Pantalla de alertas administrativas y exportacion de datos desde avisos.

// ─────────────────────────────────────────────────────────────────────────────
// PALETA DE COLORES GLOBAL
// Las constantes top-level (fuera de cualquier clase) son accesibles desde
// cualquier widget del archivo sin necesidad de instanciar nada.
// Se usan 'const' para que Dart las evalúe en tiempo de compilación (más rápido).
// ─────────────────────────────────────────────────────────────────────────────
const kOrange      = Color(0xFFFF4422); // Color principal de la marca
const kNavy        = Color(0xFF1A1F36); // Fondo oscuro de cards premium
const kBg          = Color(0xFFF3F4F8); // Fondo gris claro de la pantalla
const kWhite       = Colors.white;
const kTextDark    = Color(0xFF1A1F36); // Texto principal (casi negro)
const kTextMuted   = Color(0xFF9096AF); // Texto secundario/apagado (gris)
const kGreen       = Color(0xFF22C55E); // Verde para tendencias positivas
const kYellowBg    = Color(0xFFFFF8ED); // Fondo ámbar suave (sección auditoría)
const kYellowBorder= Color(0xFFFFD580); // Borde ámbar de la sección auditoría
const kYellowIcon  = Color(0xFFFFAA00); // Ícono ámbar de la sección auditoría
const kBlue        = Color(0xFF3B82F6); // Azul para la card informativa
const kBlueBg      = Color(0xFFEFF6FF); // Fondo azul muy suave
const kBlueBorder  = Color(0xFFBFDBFE); // Borde azul claro
const kDivider     = Color(0xFFF0F1F5); // Color del separador horizontal
const kToggleOn    = Color(0xFFFF4422); // Color del Switch cuando está activo
const kIconBg      = Color(0xFFFFF0EE); // Fondo naranja muy suave para íconos CSV/PDF
const kIconBlueBg  = Color(0xFFEEF0FF); // Fondo azul muy suave para ícono JSON
const kIconBlue    = Color(0xFF6366F1); // Azul índigo para el ícono JSON
const kDownloadBg  = Color(0xFFF5F6FA); // Fondo del botón de descarga

class AdminNotiAlertScreen extends StatefulWidget {
  const AdminNotiAlertScreen({super.key});
  @override
  State<AdminNotiAlertScreen> createState() => _AdminNotiAlertScreenState();
}

class _AdminNotiAlertScreenState extends State<AdminNotiAlertScreen> {
  // Índice del tab activo en la barra de auditoría (0=Actividad, 1=Reportes, 2=Alertas, 3=Exportar)
  int _tab = 2; // Arranca en "Alertas"

  // Índice del tab activo en el bottom nav (4 = Avisos)
  int _nav = 4;

  // Estado del Switch "Incluir datos personales" en la config de exportación
  bool _incl = true;  // Empieza activado

  // Estado del Switch "Comprimir archivo" en la config de exportación
  bool _comp = false; // Empieza desactivado

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        // SafeArea respeta el notch y la barra de estado del sistema
        child: Column(
          children: [
            _topBar(),     // Barra de marca superior
            Expanded(
              child: ListView(
                // ListView es más eficiente que SingleChildScrollView + Column
                // porque renderiza solo los items visibles en pantalla.
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                children: [
                  _auditoria(),              // Banner de acceso al centro de auditoría
                  const SizedBox(height: 12),
                  _pushCard(),               // Card oscura con métricas push
                  const SizedBox(height: 14),
                  _tabBar(),                 // Tabs: Actividad/Reportes/Alertas/Exportar
                  const SizedBox(height: 14),
                  // ── Tres tarjetas de exportación (CSV, JSON, PDF) ──
                  _exportCard(
                    iconWidget: const Icon(Icons.picture_as_pdf_outlined, color: kOrange, size: 22),
                    iconBg: kIconBg,
                    title: 'Exportar CSV',
                    sub: 'Datos tabulares para Excel',
                    size: '2.4 MB',
                  ),
                  const SizedBox(height: 10),
                  _exportCard(
                    iconWidget: const Icon(Icons.code, color: kIconBlue, size: 22),
                    iconBg: kIconBlueBg,
                    title: 'Exportar JSON',
                    sub: 'Formato estructurado para APIs',
                    size: '1.8 MB',
                  ),
                  const SizedBox(height: 10),
                  _exportCard(
                    iconWidget: const Icon(Icons.picture_as_pdf_outlined, color: kOrange, size: 22),
                    iconBg: kIconBg,
                    title: 'Exportar PDF',
                    sub: 'Reporte visual completo',
                    size: '880 KB',
                  ),
                  const SizedBox(height: 18),
                  _configCard(), // Toggles de configuración de exportación
                  const SizedBox(height: 14),
                  _infoCard(),   // Nota de seguridad sobre exportaciones
                  const SizedBox(height: 20),
                ],
              ),
            ),
            _bottomNav(), // Barra de navegación inferior fija
          ],
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────────

  /// Barra superior blanca con logo "PM", nombre de la app,
  /// ícono de campana con punto rojo y avatar del admin.
  Widget _topBar() => Container(
    color: kWhite,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        // Logo circular con las iniciales "PM"
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
              style: TextStyle(color: kWhite, fontWeight: FontWeight.bold, fontSize: 11.5),
            ),
          ),
        ),
        const SizedBox(width: 9),
        // Nombre de la app en dos líneas
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'PROMOVANIA',
              style: TextStyle(fontSize: 8.5, color: kTextMuted, letterSpacing: 0.8),
            ),
            Text(
              'Admin Panel',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kTextDark),
            ),
          ],
        ),
        const Spacer(), // Empuja los íconos hacia la derecha
        // ── Campana con punto rojo indicador ──
        Stack(
          children: [
            const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.notifications_outlined, color: kTextMuted, size: 24),
            ),
            // Positioned coloca el punto rojo sobre la esquina superior derecha del ícono
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: kOrange, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Avatar circular con la inicial "A" del admin
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(color: kNavy, shape: BoxShape.circle),
          child: const Center(
            child: Text('A', style: TextStyle(color: kWhite, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
      ],
    ),
  );

  // ── Sección auditoría ─────────────────────────────────────────────────────────

  /// Banner de acceso rápido al centro de auditoría.
  /// Fondo amarillo suave con ícono de portapapeles y flecha "ver más".
  Widget _auditoria() => Container(
    decoration: BoxDecoration(
      color: kYellowBg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kYellowBorder, width: 1),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    child: Row(
      children: [
        // Ícono de auditoría con fondo ámbar translúcido
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: kYellowIcon.withOpacity(0.15),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.assignment_outlined, color: kYellowIcon, size: 21),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Auditor├¡a', // Título de sección
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kTextDark),
            ),
            Text(
              'Centro de reportes y alertas',
              style: TextStyle(fontSize: 11.5, color: kTextMuted),
            ),
          ],
        ),
        const Spacer(),
        const Icon(Icons.chevron_right, color: kTextMuted, size: 22), // Flecha "ver más"
      ],
    ),
  );

  // ── Push card ─────────────────────────────────────────────────────────────────

  /// Card oscura con las métricas de notificaciones push:
  /// enviadas, tasa de apertura y clics.
  Widget _pushCard() => Container(
    decoration: BoxDecoration(color: kNavy, borderRadius: BorderRadius.circular(18)),
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Encabezado: ícono + título + botón "Nueva Campaña" ──
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.notifications_active, color: kWhite, size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Push Notifications',
                      style: TextStyle(color: kWhite, fontWeight: FontWeight.w700, fontSize: 15.5)),
                  Text('Centro de comunicaciones',
                      style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            // Botón de acción (sin navegación implementada aún)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(22)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.send_outlined, color: kWhite, size: 13),
                  SizedBox(width: 5),
                  Text('Nueva Campa├▒a',
                      style: TextStyle(color: kWhite, fontSize: 10.5, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Descripción con opacidad reducida
        const Text(
          'Llega a tus usuarios en tiempo real\ncon mensajes personalizados',
          style: TextStyle(color: Colors.white60, fontSize: 11.5, height: 1.55),
        ),
        const SizedBox(height: 16),
        // ── Fila de 3 métricas ──
        // IntrinsicHeight obliga a todos los hijos a tener la misma altura,
        // necesario para que los divisores verticales lleguen de arriba a abajo.
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

  /// Línea divisora vertical blanca semitransparente entre las métricas.
  Widget _vDivider() => Container(
    width: 1,
    margin: const EdgeInsets.symmetric(horizontal: 10),
    color: Colors.white12, // 12% de opacidad blanca
  );

  /// Mini-stat: etiqueta + valor grande + tendencia con flecha verde.
  /// [center] alinea el contenido al centro (usado en "Tasa Apertura").
  Widget _stat(String label, String val, String trend, {bool center = false}) =>
      Expanded(
        child: Column(
          crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(
              label,
              textAlign: center ? TextAlign.center : TextAlign.start,
              style: const TextStyle(color: Colors.white54, fontSize: 10, height: 1.3),
            ),
            const SizedBox(height: 3),
            Text(val,
                style: const TextStyle(color: kWhite, fontWeight: FontWeight.w800, fontSize: 20)),
            const SizedBox(height: 3),
            // Flecha + porcentaje de crecimiento en verde
            Row(
              mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                const Icon(Icons.arrow_upward, color: kGreen, size: 11),
                Text(trend, style: const TextStyle(color: kGreen, fontSize: 10.5)),
              ],
            ),
          ],
        ),
      );

  // ── Tab bar ───────────────────────────────────────────────────────────────────

  /// Barra de tabs interna del módulo de auditoría.
  /// El tab activo (_tab = 2, Alertas) tiene fondo oscuro; los demás son transparentes.
  /// El badge de Reportes se toma en tiempo real del promoService.
  Widget _tabBar() {
    // Cantidad de reportes activos (dato en vivo del servicio global)
    final reportesBadge = moderationController.getReportesSync().length;

    // Lista de mapas con la definición de cada tab.
    // Se usa Map<String, dynamic> porque los valores tienen tipos distintos.
    final tabs = [
      {'icon': Icons.access_time_outlined,    'label': 'Actividad', 'badge': 0},
      {'icon': Icons.description_outlined,    'label': 'Reportes',  'badge': reportesBadge},
      {'icon': Icons.notifications_outlined,  'label': 'Alertas',   'badge': 1},
      {'icon': Icons.file_upload_outlined,    'label': 'Exportar',  'badge': 0},
    ];

    return Container(
      decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.all(5),
      child: Row(
        // List.generate crea un widget por índice sin escribir cada tab manualmente
        children: List.generate(tabs.length, (i) {
          final active = i == _tab;
          final badge = tabs[i]['badge'] as int;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onNotiTabTap(i), // Navega al sub-módulo correspondiente
              child: AnimatedContainer(
                // AnimatedContainer interpola el color de fondo automáticamente en 200ms
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  // Solo el tab activo tiene fondo oscuro
                  color: active ? kNavy : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Stack permite superponer el badge encima del ícono
                    Stack(
                      clipBehavior: Clip.none, // El badge puede salir del bounds del Stack
                      children: [
                        Icon(
                          tabs[i]['icon'] as IconData,
                          size: 21,
                          color: active ? kWhite : kTextMuted,
                        ),
                        // El badge solo se muestra si su valor es mayor que 0
                        if (badge > 0)
                          Positioned(
                            top: -5,
                            right: -8, // Sale a la derecha del ícono
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 16), // Ancho mínimo
                              height: 16,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
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

  // ── Export card ───────────────────────────────────────────────────────────────

  /// Tarjeta reutilizable para cada formato de exportación (CSV, JSON, PDF).
  /// Recibe el ícono como widget para poder personalizarlo libremente.
  Widget _exportCard({
    required Widget iconWidget, // Widget del ícono (permite cualquier ícono o imagen)
    required Color iconBg,      // Color de fondo del contenedor del ícono
    required String title,      // Nombre del formato (ej. "Exportar CSV")
    required String sub,        // Descripción breve del formato
    required String size,       // Tamaño estimado del archivo
  }) =>
      Container(
        decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            // Cuadrado con ícono del formato
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)),
              child: Center(child: iconWidget),
            ),
            const SizedBox(width: 14),
            // Textos: título, descripción y tamaño
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: kTextDark)),
                  const SizedBox(height: 2),
                  Text(sub, style: const TextStyle(fontSize: 12, color: kTextMuted)),
                  const SizedBox(height: 3),
                  // Tamaño del archivo con opacidad reducida
                  Text(size, style: TextStyle(fontSize: 11, color: kTextMuted.withOpacity(0.75))),
                ],
              ),
            ),
            // Botón de descarga (solo visual; la lógica de descarga se agregaría en onTap)
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: kDownloadBg, borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.file_download_outlined, color: kOrange, size: 21),
            ),
          ],
        ),
      );

  // ── Config card ───────────────────────────────────────────────────────────────

  /// Card con dos Switches para configurar la exportación:
  /// - "Incluir datos personales" (_incl)
  /// - "Comprimir archivo" (_comp)
  Widget _configCard() => Container(
    decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(14)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Encabezado de la card ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: const [
              Icon(Icons.settings_outlined, color: kOrange, size: 19),
              SizedBox(width: 8),
              Text(
                'Configuraci├│n de Exportaci├│n',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: kTextDark),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: kDivider),

        // ── Switch 1: Incluir datos personales ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                child: Text('Incluir datos personales',
                    style: TextStyle(fontSize: 13.5, color: kTextDark)),
              ),
              // Transform.scale reduce el tamaño del Switch al 85%
              // sin afectar el espacio que ocupa en el layout.
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: _incl,
                  // setState() notifica a Flutter que _incl cambió
                  // y reconstruye el widget con el nuevo valor del Switch.
                  onChanged: (v) => setState(() => _incl = v),
                  activeColor: kWhite,              // Color del thumb cuando está ON
                  activeTrackColor: kToggleOn,       // Color del track cuando está ON
                  inactiveThumbColor: Colors.white,  // Color del thumb cuando está OFF
                  inactiveTrackColor: const Color(0xFFDDDEE6), // Color del track OFF
                  // MaterialStateProperty.all aplica el mismo valor a todos los estados
                  trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 1, thickness: 1, color: kDivider),
        ),

        // ── Switch 2: Comprimir archivo ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                child: Text('Comprimir archivo',
                    style: TextStyle(fontSize: 13.5, color: kTextDark)),
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
                  trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    ),
  );

  // ── Info card ─────────────────────────────────────────────────────────────────

  /// Card azul informativa que explica la política de seguridad de exportaciones.
  Widget _infoCard() => Container(
    decoration: BoxDecoration(
      color: kBlueBg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kBlueBorder, width: 1),
    ),
    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinea al tope si el texto es largo
      children: [
        // Ícono de información con fondo azul circular
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
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: kBlue),
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

  // ── Bottom nav ────────────────────────────────────────────────────────────────

  /// Barra de navegación inferior con 5 módulos del panel admin.
  /// El ícono y texto del tab activo (_nav = 4, Avisos) se muestran en naranja.
  Widget _bottomNav() {
    final items = [
      {'icon': Icons.grid_view_outlined,    'label': 'Panel'},
      {'icon': Icons.people_outline,        'label': 'Usuarios'},
      {'icon': Icons.local_offer_outlined,  'label': 'Promos'},
      {'icon': Icons.storefront_outlined,   'label': 'Comercios'},
      {'icon': Icons.notifications_outlined,'label': 'Avisos'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: kWhite,
        boxShadow: [
          // Sombra hacia arriba para separar la barra del contenido
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -3)),
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
                  color: active ? kOrange : kTextMuted, // Naranja si activo, gris si no
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

  // ── Métodos de navegación ─────────────────────────────────────────────────────

  /// Traduce el índice del tab de auditoría a su ruta en AppRoutes.
  String _notiRouteForTab(int index) {
    switch (index) {
      case 0: return AppRoutes.adminNotiActivity;
      case 1: return AppRoutes.adminNotiReport;
      case 2: return AppRoutes.adminNotiAlert;
      default: return AppRoutes.adminNotiExport;
    }
  }

  /// Maneja el tap en los tabs internos de auditoría.
  /// pushReplacementNamed reemplaza la pantalla actual sin apilar una nueva,
  /// evitando que el botón "atrás" regrese al tab anterior.
  void _onNotiTabTap(int index) {
    if (index == _tab) return; // No navega si el tab ya está activo
    Navigator.pushReplacementNamed(context, _notiRouteForTab(index));
  }

  /// Traduce el índice del bottom nav a la ruta del módulo correspondiente.
  String _routeForBottomIndex(int index) {
    switch (index) {
      case 0: return AppRoutes.adminDashboard;
      case 1: return AppRoutes.manageUsers;
      case 2: return AppRoutes.managePromotions;
      case 3: return AppRoutes.manageStores;
      default: return AppRoutes.manageNotifications;
    }
  }

  /// Maneja el tap en la barra de navegación inferior.
  void _onBottomNavTap(int index) {
    if (index == _nav) return; // No navega si ya está en ese módulo
    Navigator.pushReplacementNamed(context, _routeForBottomIndex(index));
  }
}
