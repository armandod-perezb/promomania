// ============================================================================
// ARCHIVO: admin_noti_report_screen.dart
// PROPÓSITO: Pantalla de reportes del módulo de avisos.
//            Muestra métricas de actividad por hora (gráfico de barras),
//            estadísticas de reportes del sistema, y permite descargar
//            un reporte consolidado.
// PATRÓN: StatefulWidget con AnimatedBuilder sobre un ChangeNotifier global.
// ============================================================================

import 'package:flutter/material.dart';
import '../Core/Routes/app_routes.dart'; // Constantes de rutas nombradas
import '../main.dart'; // Expone `promoService` (ChangeNotifier global)

// ── Paleta de colores a nivel de archivo ─────────────────────────────────────
// Se declaran como `const` fuera de cualquier clase para ser constantes
// en tiempo de compilación — mejor rendimiento que definirlas como variables.
const kOrange = Color(0xFFFF4500);       // Naranja principal de la marca
const kOrangeLight = Color(0xFFFF6633); // Naranja más claro (declarado, uso futuro)
const kNavyDark = Color(0xFF1A1F36);    // Azul marino oscuro para tarjetas y tabs activos
const kNavyCard = Color(0xFF1E2440);    // Variante del navy (declarado, uso futuro)
const kBgGray = Color(0xFFF4F5F9);      // Gris claro para el fondo general
const kWhite = Colors.white;            // Blanco para superficies de tarjetas
const kTextDark = Color(0xFF1A1F36);    // Texto principal (casi negro)
const kTextGray = Color(0xFF8A8FA8);    // Texto secundario / subtítulos
const kGreen = Color(0xFF00C48C);       // Verde para tendencias positivas
const kYellowBg = Color(0xFFFFF3E0);   // Fondo amarillo para la tarjeta de auditoría
const kYellowText = Color(0xFFFF9800); // Color de íconos y bordes en auditoría
const kTabActive = Color(0xFF1A1F36);  // Color de tab activo (igual a kNavyDark)

// ============================================================================
// WIDGET PRINCIPAL: AdminNotiReportScreen
// ============================================================================
class AdminNotiReportScreen extends StatefulWidget {
  const AdminNotiReportScreen({super.key});

  @override
  State<AdminNotiReportScreen> createState() => _AdminNotiReportScreenState();
}

class _AdminNotiReportScreenState extends State<AdminNotiReportScreen> {

  // ── Estado local ────────────────────────────────────────────────────────────
  // Índice del tab activo dentro del módulo de avisos.
  // Valor 1 = "Reportes" → esta misma pantalla.
  int _selectedTab = 1;

  // Índice del ítem activo en el BottomNavigationBar.
  // Valor 4 = "Avisos" → módulo actual.
  int _bottomNav = 4;

  // ============================================================================
  // BUILD PRINCIPAL
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder escucha a `promoService` (ChangeNotifier).
    // Cuando promoService llama notifyListeners(), el árbol de widgets
    // se reconstruye automáticamente. Esto mantiene los badges y métricas
    // de reportes siempre sincronizados con el estado global.
    return AnimatedBuilder(
      animation: promoService,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: kBgGray,
          body: SafeArea(
            child: Column(
              children: [
                // Barra superior institucional fija.
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        // Acceso rápido al centro de auditoría.
                        _buildAuditoriaCard(),
                        const SizedBox(height: 12),
                        // Métricas de campañas push con datos estáticos.
                        _buildPushCard(),
                        const SizedBox(height: 16),
                        // Tabs internas del módulo: Actividad / Reportes / Alertas / Exportar.
                        _buildTabBar(),
                        const SizedBox(height: 16),
                        // Título de la sección del gráfico.
                        _buildActividadHeader(),
                        const SizedBox(height: 8),
                        // Gráfico de barras de actividad por hora (datos hardcoded).
                        _buildBarChart(),
                        const SizedBox(height: 16),
                        // Grid 2×2 con métricas dinámicas de reportes.
                        _buildReporteGrid(),
                        const SizedBox(height: 16),
                        // Botón para descargar el reporte consolidado.
                        _buildDescargarSection(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                // Barra de navegación inferior fija.
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
  // Idéntica a la de AdminNotiExportScreen. Contiene logo, nombre de la app,
  // ícono de notificación con badge decorativo, y avatar navegable al perfil.
  // ============================================================================
  Widget _buildTopBar() {
    return Container(
      color: kWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Logo circular "PM"
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: kOrange, shape: BoxShape.circle),
            child: const Center(
              child: Text(
                'PM',
                style: TextStyle(color: kWhite, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Nombre y subtítulo de la app
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'PROMOVANIA',
                style: TextStyle(fontSize: 9, color: kTextGray, letterSpacing: 1),
              ),
              Text(
                'Admin Panel',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kTextDark),
              ),
            ],
          ),
          const Spacer(),
          // Campana con badge de punto naranja (decorativo, no dinámico)
          Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: kTextGray, size: 24),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: kOrange, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // Avatar del admin → navega a userProfile
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.userProfile),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(color: kOrange, shape: BoxShape.circle),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(color: kWhite, fontWeight: FontWeight.bold, fontSize: 13),
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
  // Tarjeta de acceso al centro de reportes con fondo amarillo suave.
  // Visualmente idéntica a la de la pantalla de exportación.
  // Sin onTap implementado actualmente.
  // ============================================================================
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
            child: const Icon(Icons.assignment_outlined, color: kYellowText, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Auditoría',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kTextDark),
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

  // ============================================================================
  // PUSH NOTIFICATION CARD
  // Tarjeta oscura con métricas estáticas de campañas push.
  // NOTA: Los valores (4.2K, 89%, 2.8K) son hardcoded.
  // En producción deben obtenerse desde promoService o un repositorio.
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
          Row(
            children: [
              // Ícono del módulo de notificaciones
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
                      style: TextStyle(color: kWhite, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      'Centro de comunicaciones',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Botón "Nueva Campaña" — decorativo, sin onTap implementado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: kOrange, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: const [
                    Icon(Icons.send, color: kWhite, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Nueva Campaña',
                      style: TextStyle(color: kWhite, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Llega a tus usuarios en tiempo real\ncon mensajes personalizados',
            style: TextStyle(color: Colors.white60, fontSize: 11.5, height: 1.5),
          ),
          const SizedBox(height: 16),
          // Fila de métricas estadísticas
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

  // Divisor vertical entre las columnas de métricas de la push card
  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white12,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  // Columna de métrica alineada a la IZQUIERDA con soporte para tendencia positiva/negativa
  // `positive` determina el ícono de la flecha (up/down), aunque actualmente
  // siempre se muestra verde independientemente de este parámetro.
  Widget _buildStat(String label, String value, String trend, bool positive) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: kWhite, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              // Flecha según dirección de la tendencia
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

  // Columna de métrica alineada al CENTRO (para el valor del medio)
  Widget _buildStatCenter(String label, String value, String trend, bool positive) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(color: kWhite, fontWeight: FontWeight.bold, fontSize: 18),
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

  // ============================================================================
  // TAB BAR
  // Barra de 4 tabs para navegar por las secciones del módulo de avisos.
  // El badge de "Reportes" es DINÁMICO: depende de promoService.getReportes().
  // El de "Alertas" tiene valor fijo de 1 (hardcoded).
  // Usa pushReplacementNamed para evitar acumulación de rutas en el stack.
  // ============================================================================
  Widget _buildTabBar() {
    // Dato dinámico: número de reportes activos en el servicio global
    final reportesBadge = promoService.getReportes().length;

    final tabs = [
      {'icon': Icons.bar_chart_outlined,     'label': 'Actividad', 'badge': 0},
      {'icon': Icons.description_outlined,   'label': 'Reportes',  'badge': reportesBadge},
      {'icon': Icons.notifications_outlined, 'label': 'Alertas',   'badge': 1}, // Hardcoded
      {'icon': Icons.file_upload_outlined,   'label': 'Exportar',  'badge': 0},
    ];

    return Container(
      decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(12)),
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
                        // Badge numérico naranja solo si badge > 0
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
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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
  // ACTIVIDAD HEADER
  // Título de la sección del gráfico de barras. Puramente decorativo.
  // ============================================================================
  Widget _buildActividadHeader() {
    return Row(
      children: const [
        Icon(Icons.trending_up, color: kOrange, size: 18),
        SizedBox(width: 6),
        Text(
          'Actividad por Hora',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kTextDark),
        ),
      ],
    );
  }

  // ============================================================================
  // BAR CHART — Gráfico de barras de actividad por hora
  //
  // IMPLEMENTACIÓN: Construido con widgets Flutter puros (sin librerías externas
  // como fl_chart o charts_flutter). Usa un Stack para superponer las líneas
  // de cuadrícula sobre las barras.
  //
  // DATOS: Hardcoded como lista de mapas con hora ('h') y valor relativo ('v').
  // El valor 'v' es un double de 0 a 1 que se multiplica por maxH (120px)
  // para obtener la altura real de cada barra.
  //
  // LIMITACIÓN: No es interactivo (sin tooltips ni selección de barras).
  // Los datos son estáticos y no vienen de promoService.
  // ============================================================================
  Widget _buildBarChart() {
    // Datos de actividad por franja horaria. 'v' es valor normalizado (0.0 a 1.0).
    final data = [
      {'h': '00', 'v': 0.05}, // Madrugada: actividad mínima
      {'h': '03', 'v': 0.08},
      {'h': '06', 'v': 0.12}, // Amanecer: actividad baja
      {'h': '09', 'v': 0.30}, // Mañana: inicio de actividad
      {'h': '12', 'v': 0.55}, // Mediodía: actividad media-alta
      {'h': '15', 'v': 0.85}, // Tarde: pico secundario
      {'h': '18', 'v': 1.00}, // Tarde-noche: pico máximo de actividad
      {'h': '21', 'v': 0.78}, // Noche: descenso gradual
    ];

    // Altura máxima en píxeles que puede alcanzar una barra (v = 1.0)
    const maxH = 120.0;

    return Container(
      decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      child: Column(
        children: [
          SizedBox(
            height: maxH + 30, // +30px para acomodar las etiquetas de hora debajo
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Eje Y: etiquetas de valores (estáticas, representativas)
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('20', style: TextStyle(fontSize: 9, color: kTextGray)),
                    Text('15', style: TextStyle(fontSize: 9, color: kTextGray)),
                    Text('10', style: TextStyle(fontSize: 9, color: kTextGray)),
                    Text('5',  style: TextStyle(fontSize: 9, color: kTextGray)),
                    Text('0',  style: TextStyle(fontSize: 9, color: kTextGray)),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      // Capa 1: Líneas horizontales de cuadrícula
                      // Se posicionan con Positioned.fill para cubrir todo el área
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            5, // 5 líneas para 5 niveles del eje Y
                            (_) => Container(height: 0.5, color: Colors.grey.withOpacity(0.2)),
                          ),
                        ),
                      ),
                      // Capa 2: Barras del gráfico con etiquetas de hora
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: data.map((d) {
                          final v = d['v'] as double;
                          final h = d['h'] as String;
                          final barH = v * maxH; // Altura real de la barra en px
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Barra naranja con bordes redondeados en la parte superior
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
                              // Etiqueta de hora bajo cada barra
                              Text(h, style: const TextStyle(fontSize: 9, color: kTextGray)),
                              Text('h', style: const TextStyle(fontSize: 7, color: kTextGray)),
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

  // ============================================================================
  // REPORTE GRID — Grid 2×2 con métricas dinámicas de reportes
  //
  // DATOS DINÁMICOS: Todos los valores se calculan en tiempo real desde
  // promoService.getReportes(), que retorna la lista actual de reportes.
  //
  // Métricas calculadas:
  //   - Total: reportes.length
  //   - Pendientes: filtrado por estado == 'pendiente'
  //   - Usuarios únicos reportando: Set de idUsuario (elimina duplicados)
  //   - Revisados/Descartados: filtrado por estado == 'revisado' y 'descartado'
  // ============================================================================
  Widget _buildReporteGrid() {
    final reportes = promoService.getReportes(); // Lista completa de reportes

    // Cálculos derivados de la lista de reportes
    final reportesPendientes  = reportes.where((r) => r.estado == 'pendiente').length;
    final reportesRevisados   = reportes.where((r) => r.estado == 'revisado').length;
    // .toSet() elimina IDs duplicados → cuenta usuarios únicos
    final usuariosReportando  = reportes.map((r) => r.idUsuario).toSet().length;
    final reportesDescartados = reportes.where((r) => r.estado == 'descartado').length;

    // Configuración de cada tarjeta del grid (ícono, color, etiqueta, valor)
    final items = [
      {
        'icon': Icons.calendar_today_outlined,
        'color': kOrange,
        'label': 'Reportes Totales',
        'value': '${reportes.length}',
        'valueColor': kOrange,
      },
      {
        'icon': Icons.calendar_month_outlined,
        'color': kNavyDark,
        'label': 'Pendientes',
        'value': '$reportesPendientes',
        'valueColor': kTextDark,
      },
      {
        'icon': Icons.people_outline,
        'color': kGreen,
        'label': 'Usuarios Reportando',
        'value': '$usuariosReportando',
        'valueColor': kGreen,
      },
      {
        'icon': Icons.warning_amber_outlined,
        'color': kOrange,
        'label': 'Revisados/Descartados',
        // Muestra ambos valores en formato "X/Y"
        'value': '$reportesRevisados/$reportesDescartados',
        'valueColor': kOrange,
      },
    ];

    return GridView.count(
      crossAxisCount: 2,       // 2 columnas
      shrinkWrap: true,         // Adapta su altura al contenido (dentro de scroll)
      physics: const NeverScrollableScrollPhysics(), // Sin scroll propio (scroll del padre)
      mainAxisSpacing: 10,      // Separación vertical entre tarjetas
      crossAxisSpacing: 10,     // Separación horizontal entre tarjetas
      childAspectRatio: 2.4,    // Relación ancho/alto de cada celda del grid
      children: items.map((item) => _buildReporteCard(item)).toList(),
    );
  }

  // Tarjeta individual del grid de reportes.
  // Recibe un Map con la configuración visual y el valor a mostrar.
  Widget _buildReporteCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Ícono representativo de la métrica
          Icon(item['icon'] as IconData, color: item['color'] as Color, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Etiqueta descriptiva de la métrica (texto pequeño)
              Text(
                item['label'] as String,
                style: const TextStyle(fontSize: 10.5, color: kTextGray),
              ),
              const SizedBox(height: 2),
              // Valor numérico grande con color específico por métrica
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

  // ============================================================================
  // DESCARGAR SECTION
  // Sección con un botón ElevatedButton para descargar el reporte completo.
  // El onPressed está vacío () {} → funcionalidad pendiente de implementar.
  // En producción debería llamar a un servicio de generación/descarga de PDF.
  // ============================================================================
  Widget _buildDescargarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de la sección
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: kOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.file_download_outlined, color: kOrange, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              'Descargar Reportes',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kTextDark),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Botón de descarga que ocupa el ancho completo
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {}, // TODO: Implementar lógica de descarga de reporte
            style: ElevatedButton.styleFrom(
              backgroundColor: kOrange,
              foregroundColor: kWhite,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0, // Sin sombra para un look flat
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

  // ============================================================================
  // BOTTOM NAV
  // Barra inferior fija idéntica a la de AdminNotiExportScreen.
  // 5 módulos del panel admin. Ítem activo resaltado con kOrange.
  // ============================================================================
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.grid_view_outlined,    'label': 'Panel'},
      {'icon': Icons.people_outline,        'label': 'Usuarios'},
      {'icon': Icons.local_offer_outlined,  'label': 'Promos'},
      {'icon': Icons.store_outlined,        'label': 'Comercios'},
      {'icon': Icons.notifications_outlined,'label': 'Avisos'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: kWhite,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
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
  // Mapea índice de tab a ruta nombrada del módulo de avisos.
  // ============================================================================
  String _notiRouteForTab(int index) {
    switch (index) {
      case 0: return AppRoutes.adminNotiActivity; // Pantalla de actividad
      case 1: return AppRoutes.adminNotiReport;   // Esta pantalla (Reportes)
      case 2: return AppRoutes.adminNotiAlert;    // Pantalla de alertas
      default: return AppRoutes.adminNotiExport;  // Pantalla de exportación
    }
  }

  // Solo navega si el tab destino es diferente al activo.
  void _onNotiTabTap(int index) {
    if (index == _selectedTab) return;
    Navigator.pushReplacementNamed(context, _notiRouteForTab(index));
  }

  // ============================================================================
  // NAVEGACIÓN GLOBAL — BOTTOM NAV
  // Mapea índice del bottom nav a la ruta principal de cada módulo admin.
  // ============================================================================
  String _routeForBottomIndex(int index) {
    switch (index) {
      case 0: return AppRoutes.adminDashboard;
      case 1: return AppRoutes.manageUsers;
      case 2: return AppRoutes.managePromotions;
      case 3: return AppRoutes.manageStores;
      default: return AppRoutes.manageNotifications;
    }
  }

  void _onBottomNavTap(int index) {
    if (index == _bottomNav) return;
    Navigator.pushReplacementNamed(context, _routeForBottomIndex(index));
  }
}