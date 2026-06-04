// ============================================================================
// ARCHIVO: admin_noti_export_screen.dart
// PROPÓSITO: Pantalla de exportación de datos del módulo de avisos.
//            Permite al administrador descargar datos en CSV, JSON o PDF,
//            y configurar opciones como incluir datos personales o comprimir.
// PATRÓN: StatefulWidget con AnimatedBuilder sobre un ChangeNotifier global.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart';
import '../../../../../Core/Routes/app_routes.dart'; // Constantes de rutas nombradas de la app
import '../../../../../Core/di/app_scope.dart'; // Expone `promoService` (ChangeNotifier global)

// ── Paleta de colores a nivel de archivo ─────────────────────────────────────
// Se declaran como `const` fuera de la clase para que el compilador las trate
// como constantes en tiempo de compilación (mayor eficiencia).
const kOrange = Color(0xFFFF4500); // Rojo-naranja principal de la marca
const kNavyDark = Color(
  0xFF1A1F36,
); // Azul marino oscuro para tarjetas y tabs activos
const kBgGray = Color(
  0xFFF4F5F9,
); // Gris claro usado como fondo general del Scaffold
const kWhite = Colors.white; // Blanco para superficies de tarjetas
const kTextDark = Color(0xFF1A1F36); // Color de texto principal (casi negro)
const kTextGray = Color(0xFF8A8FA8); // Color de texto secundario / subtítulos
const kGreen = Color(
  0xFF00C48C,
); // Verde para indicadores positivos (tendencias)
const kYellowBg = Color(
  0xFFFFF3E0,
); // Fondo amarillo suave para la tarjeta de auditoría
const kYellowText = Color(
  0xFFFF9800,
); // Naranja/amarillo para iconos y bordes en auditoría
const kBlueInfo = Color(
  0xFF3B82F6,
); // Azul informativo para la tarjeta de seguridad
const kBlueLightBg = Color(
  0xFFEFF6FF,
); // Fondo azul muy claro para tarjeta informativa
const kToggleOn = Color(
  0xFF22C55E,
); // Verde para el estado activo de los Switch
const kCodeOrange = Color(
  0xFFFF6B35,
); // Naranja alternativo (declarado pero sin uso activo)
const kCodeBlue = Color(
  0xFF6366F1,
); // Azul índigo usado en el ícono de exportar JSON

// ============================================================================
// WIDGET PRINCIPAL: AdminNotiExportScreen
// ============================================================================
/// Pantalla administrativa para configurar exportaciones y reportes de notificaciones.
class AdminNotiExportScreen extends StatefulWidget {
  const AdminNotiExportScreen({super.key});

  @override
  State<AdminNotiExportScreen> createState() => _AdminNotiExportScreenState();
}

/// Estado interno de `AdminNotiExportScreen`; coordina datos, eventos y reconstrucciones de la pantalla.
class _AdminNotiExportScreenState extends State<AdminNotiExportScreen> {
  // ── Estado local ────────────────────────────────────────────────────────────
  // Controla qué tab interna del módulo de avisos está activa (0-3).
  // Valor 3 = "Exportar" → esta misma pantalla.
  int _selectedTab = 3;

  // Controla qué ítem del BottomNavigationBar está activo (0-4).
  // Valor 4 = "Avisos" → módulo actual.
  int _bottomNav = 4;

  // Si es true, el archivo exportado incluirá campos de datos personales
  // del usuario (nombre, email, etc.). Controlado por un Switch.
  bool _incluirDatos = true;

  // Si es true, el archivo exportado se empaquetará en formato comprimido
  // (por ejemplo, .zip) para reducir el tamaño de descarga.
  bool _comprimirArchivo = false;

  // ============================================================================
  // BUILD PRINCIPAL
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder escucha a `promoService` (un ChangeNotifier).
    // Cada vez que promoService llama a notifyListeners(), este widget
    // se reconstruye automáticamente. Esto permite que el badge de
    // "Reportes" en el TabBar sea siempre dinámico y actualizado.
    return Consumer<PromoService>(
      builder: (context, promoService, child) {
        return Scaffold(
          backgroundColor: kBgGray, // Fondo gris claro general
          body: SafeArea(
            // SafeArea evita que el contenido quede detrás del notch
            // o la barra de estado del sistema operativo.
            child: Column(
              children: [
                // Barra superior fija con logo, nombre y acciones de usuario.
                _buildTopBar(),

                // Área scrolleable principal.
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        // Tarjeta de acceso rápido a auditoría.
                        _buildAuditoriaCard(),
                        const SizedBox(height: 12),
                        // Resumen de métricas de campañas push (datos estáticos).
                        _buildPushCard(),
                        const SizedBox(height: 16),
                        // Tabs internas: Actividad / Reportes / Alertas / Exportar.
                        _buildTabBar(),
                        const SizedBox(height: 16),
                        // Tarjeta de exportación en formato CSV.
                        _buildExportCard(
                          icon: Icons.table_chart_outlined,
                          iconColor: kOrange,
                          title: 'Exportar CSV',
                          subtitle: 'Datos tabulares para Excel',
                          size: '2.4 MB',
                        ),
                        const SizedBox(height: 10),
                        // Tarjeta de exportación en formato JSON.
                        _buildExportCard(
                          icon: Icons.code,
                          iconColor: kCodeBlue,
                          title: 'Exportar JSON',
                          subtitle: 'Formato estructurado para APIs',
                          size: '1.8 MB',
                        ),
                        const SizedBox(height: 10),
                        // Tarjeta de exportación en formato PDF.
                        _buildExportCard(
                          icon: Icons.picture_as_pdf_outlined,
                          iconColor: kOrange,
                          title: 'Exportar PDF',
                          subtitle: 'Reporte visual completo',
                          size: '880 KB',
                        ),
                        const SizedBox(height: 16),
                        // Opciones de configuración del archivo de exportación.
                        _buildConfigCard(),
                        const SizedBox(height: 12),
                        // Tarjeta informativa sobre seguridad y retención de datos.
                        _buildInfoCard(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Barra de navegación inferior fija (5 módulos del panel admin).
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
  // Barra superior blanca con: logo circular PM, nombre de la app,
  // ícono de notificación con badge decorativo, y avatar del admin.
  // ============================================================================
  Widget _buildTopBar() {
    return Container(
      color: kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Logo circular con las iniciales "PM" (Promovania)
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
          // Nombre y subtítulo de la aplicación
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROMOVANIA',
                style: TextStyle(
                  fontSize: 9,
                  color: kTextGray,
                  letterSpacing: 1, // Espaciado de letras para efecto de marca
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
          const Spacer(), // Empuja los íconos de acción hacia la derecha
          // Ícono de campana con badge naranja (punto decorativo, no dinámico)
          Stack(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: kTextGray,
                size: 24,
              ),
              // Badge rojo/naranja posicionado en la esquina superior derecha
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

          // Avatar del administrador: navega al perfil al hacer tap
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
                  'A', // Inicial del usuario administrador
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

  // ============================================================================
  // AUDITORÍA CARD
  // Tarjeta de acceso rápido al centro de reportes y alertas.
  // Fondo amarillo suave con borde semitransparente. Sin onTap implementado.
  // ============================================================================
  Widget _buildAuditoriaCard() {
    return Container(
      decoration: BoxDecoration(
        color: kYellowBg,
        borderRadius: BorderRadius.circular(12),
        // Borde naranja con 30% de opacidad para efecto sutil
        border: Border.all(color: kYellowText.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Ícono con fondo cuadrado redondeado
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
          // Título y subtítulo de la sección
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
          // Flecha indicadora de navegación (chevron)
          const Icon(Icons.chevron_right, color: kTextGray),
        ],
      ),
    );
  }

  // ============================================================================
  // PUSH CARD
  // Tarjeta oscura (kNavyDark) con métricas de campañas push.
  // NOTA: Los valores (4.2K, 89%, 2.8K) son datos estáticos / hardcoded.
  // En producción deberían venir de promoService o un repositorio de datos.
  // ============================================================================
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
          // Fila superior: ícono + título + botón acción
          Row(
            children: [
              // Ícono de notificaciones con fondo naranja
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
              // Título y subtítulo del módulo
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
              // Botón "Nueva Campaña" — decorativo, sin acción implementada
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
          // Descripción del módulo
          const Text(
            'Llega a tus usuarios en tiempo real\ncon mensajes personalizados',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // Fila de métricas: 3 estadísticas separadas por divisores verticales
          Row(
            children: [
              _buildStat('Enviadas', '4.2K', '+12%'),
              _buildDivider(),
              // El método center centra el contenido horizontalmente
              _buildStatCenter('Tasa\nApertura', '89%', '+5%'),
              _buildDivider(),
              _buildStat('Clics', '2.8K', '+18%'),
            ],
          ),
        ],
      ),
    );
  }

  // Divisor vertical semitransparente entre métricas
  Widget _buildDivider() => Container(
    width: 1,
    height: 40,
    color: Colors.white12,
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );

  // Columna de métrica alineada a la IZQUIERDA
  // Parámetros: etiqueta, valor numérico, porcentaje de tendencia
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
        // Indicador de tendencia con flecha e ícono verde
        Row(
          children: [
            const Icon(Icons.arrow_upward, color: kGreen, size: 10),
            Text(trend, style: const TextStyle(color: kGreen, fontSize: 10)),
          ],
        ),
      ],
    ),
  );

  // Columna de métrica alineada al CENTRO (para la métrica del medio)
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

  // ============================================================================
  // TAB BAR
  // Barra de navegación interna del módulo de avisos con 4 tabs.
  // El badge de "Reportes" es dinámico: lee moderationController.getReportesSync().length.
  // Al tocar un tab diferente al activo, hace pushReplacementNamed()
  // para evitar acumulación en el stack de navegación.
  // ============================================================================
  Widget _buildTabBar() {
    // Badge dinámico: cantidad actual de reportes registrados
    final reportesBadge = moderationController.getReportesSync().length;

    // Lista de tabs con su ícono, etiqueta y badge numérico
    final tabs = [
      {'icon': Icons.bar_chart_outlined, 'label': 'Actividad', 'badge': 0},
      {
        'icon': Icons.description_outlined,
        'label': 'Reportes',
        'badge': reportesBadge,
      },
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
        // Genera un widget por cada tab usando List.generate
        children: List.generate(tabs.length, (i) {
          final isActive = i == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onNotiTabTap(i), // Navega al tab seleccionado
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  // Tab activo → fondo oscuro; inactivo → transparente
                  color: isActive ? kNavyDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    // Stack permite superponer el badge sobre el ícono
                    Stack(
                      clipBehavior:
                          Clip.none, // Permite que el badge sobresalga
                      children: [
                        Icon(
                          tabs[i]['icon'] as IconData,
                          size: 20,
                          color: isActive ? kWhite : kTextGray,
                        ),
                        // Badge numérico naranja (solo si badge > 0)
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
                    // Etiqueta del tab con estilo condicional
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

  // ============================================================================
  // EXPORT CARD
  // Widget parametrizado y reutilizable para mostrar una opción de exportación.
  // El botón de descarga (file_download_outlined) no tiene onTap implementado.
  // ============================================================================
  Widget _buildExportCard({
    required IconData icon, // Ícono representativo del formato
    required Color iconColor, // Color del ícono y su fondo semitransparente
    required String title, // Nombre del formato: "Exportar CSV", etc.
    required String subtitle, // Descripción del uso del formato
    required String size, // Tamaño estimado del archivo resultante
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          // Caja del ícono con fondo semitransparente del color del formato
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
          // Información textual: título, subtítulo y tamaño estimado
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
                // Tamaño del archivo con opacidad reducida (dato secundario)
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
          // Botón de descarga — sin funcionalidad implementada aún
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

  // ============================================================================
  // CONFIG CARD
  // Tarjeta con dos Switch para configurar el archivo de exportación.
  // Cada Switch llama a setState() para actualizar el estado local del widget.
  // Los colores de los Switch se definen manualmente (no usan ThemeData)
  // para mayor control visual explícito.
  // ============================================================================
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
          // Encabezado de la tarjeta
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

          // Opción 1: Incluir datos personales
          // Vinculado a _incluirDatos → se persiste solo durante la sesión
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
                activeColor: kToggleOn, // Thumb activo: verde
                activeTrackColor: kToggleOn.withOpacity(
                  0.35,
                ), // Track activo: verde translúcido
                inactiveThumbColor:
                    Colors.grey.shade400, // Thumb inactivo: gris
                inactiveTrackColor:
                    Colors.grey.shade200, // Track inactivo: gris claro
              ),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F5)),
          const SizedBox(height: 4),

          // Opción 2: Comprimir archivo
          // Vinculado a _comprimirArchivo → afectaría el formato del archivo final
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

  // ============================================================================
  // INFO CARD
  // Tarjeta puramente informativa con fondo azul claro.
  // Informa que los archivos se exportan de forma cifrada y se eliminan en 24h.
  // Sin interactividad.
  // ============================================================================
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
          // Ícono de información con fondo circular azul claro
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

  // ============================================================================
  // BOTTOM NAV
  // Barra inferior fija con 5 módulos del panel de administración.
  // El ítem activo se resalta con kOrange. Al tocar otro ítem,
  // pushReplacementNamed() cambia de módulo sin apilar rutas.
  // ============================================================================
  Widget _buildBottomNav() {
    // Definición de los 5 ítems del menú inferior
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

  // ============================================================================
  // NAVEGACIÓN INTERNA — TABS DE AVISOS
  // Mapea el índice del tab a la ruta nombrada correspondiente.
  // ============================================================================
  String _notiRouteForTab(int index) {
    switch (index) {
      case 0:
        return AppRoutes.adminNotiActivity; // Pantalla de actividad
      case 1:
        return AppRoutes.adminNotiReport; // Pantalla de reportes
      case 2:
        return AppRoutes.adminNotiAlert; // Pantalla de alertas
      default:
        return AppRoutes.adminNotiExport; // Esta misma pantalla (Exportar)
    }
  }

  // Ejecuta navegación solo si el tab destino es diferente al actual.
  // Usa pushReplacementNamed para no apilar la misma clase de ruta.
  void _onNotiTabTap(int index) {
    if (index == _selectedTab) return;
    Navigator.pushReplacementNamed(context, _notiRouteForTab(index));
  }

  // ============================================================================
  // NAVEGACIÓN GLOBAL — BOTTOM NAV
  // Mapea el índice del bottom nav a la ruta principal del módulo.
  // ============================================================================
  String _routeForBottomIndex(int index) {
    switch (index) {
      case 0:
        return AppRoutes.adminDashboard; // Panel general
      case 1:
        return AppRoutes.manageUsers; // Gestión de usuarios
      case 2:
        return AppRoutes.managePromotions; // Gestión de promociones
      case 3:
        return AppRoutes.manageStores; // Gestión de comercios
      default:
        return AppRoutes.manageNotifications; // Módulo de avisos
    }
  }

  void _onBottomNavTap(int index) {
    if (index == _bottomNav) return;
    Navigator.pushReplacementNamed(context, _routeForBottomIndex(index));
  }
}
