import 'package:flutter/material.dart';
import '../../../../../Core/di/app_scope.dart';

/// Vista resumida del dashboard para revisar KPIs generales rapidamente.
class AdminDashboardSimplifiedScreen extends StatefulWidget {
  const AdminDashboardSimplifiedScreen({super.key});

  @override
  State<AdminDashboardSimplifiedScreen> createState() =>
      _AdminDashboardSimplifiedScreenState();
}

class _AdminDashboardSimplifiedScreenState
    extends State<AdminDashboardSimplifiedScreen> {
  // Construye un resumen de usuarios, promociones y actividad agregada.
  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder escucha a promoService (ChangeNotifier).
    // Cada vez que los datos cambian, Flutter reconstruye solo este widget
    // sin necesidad de llamar setState() manualmente.
    return AnimatedBuilder(
      animation: promoService,
      builder: (context, _) {
        // Se obtienen copias de las listas actuales del servicio global.
        // Estas llamadas devuelven los datos en tiempo real almacenados en memoria.
        final usuarios = promoService.getUsuarios();
        final promociones = promoService.getPromociones();
        final supermercados = promoService.getSupermercados();
        final comentarios = promoService.getComentarios();

        // ── Cálculo de estadísticas derivadas ──
        // .where() filtra la lista por condición y .length cuenta los resultados.
        final promocionesAprobadas = promociones
            .where((p) => p.estado == 'aprobada')
            .length;
        final promocionesPendientes = promociones
            .where((p) => p.estado == 'pendiente')
            .length;
        final promocionesRechazadas = promociones
            .where((p) => p.estado == 'rechazada')
            .length;

        // .fold() recorre toda la lista acumulando un valor.
        // Aquí suma el campo 'vistas' de cada promoción para obtener el total global.
        final totalVistas = promociones.fold<int>(
          0,
          (sum, p) => sum + p.vistas,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Panel de Administración'),
            elevation: 0, // Sin sombra bajo el AppBar
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Cuadrícula 2×2 de KPIs principales ──
                // GridView.count crea una cuadrícula con un número fijo de columnas.
                // shrinkWrap: true hace que ocupe solo el espacio que necesita
                // (necesario porque está dentro de un SingleChildScrollView).
                // NeverScrollableScrollPhysics evita conflicto de scroll entre
                // el GridView y el SingleChildScrollView que lo contiene.
                GridView.count(
                  crossAxisCount: 2,                              // 2 columnas
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),  // Sin scroll propio
                  mainAxisSpacing: 12,                            // Espacio vertical entre cards
                  crossAxisSpacing: 12,                           // Espacio horizontal entre cards
                  children: [
                    _StatCard(
                      title: 'Usuarios',
                      value: usuarios.length.toString(),          // Dato en tiempo real
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      title: 'Promociones',
                      value: promociones.length.toString(),       // Dato en tiempo real
                      icon: Icons.local_offer,
                      color: Colors.orange,
                    ),
                    _StatCard(
                      title: 'Supermercados',
                      value: supermercados.length.toString(),     // Dato en tiempo real
                      icon: Icons.store,
                      color: Colors.green,
                    ),
                    _StatCard(
                      title: 'Comentarios',
                      value: comentarios.length.toString(),       // Dato en tiempo real
                      icon: Icons.comment,
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Sección: desglose de promociones por estado ──
                const Text(
                  'Estado de Promociones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Card verde → promociones aprobadas
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: ListTile(
                    title: const Text('Aprobadas'),
                    trailing: Text(
                      promocionesAprobadas.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Card amarilla → promociones pendientes de revisión
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.yellow[700]!), // ! afirma que no es null
                  ),
                  child: ListTile(
                    title: const Text('Pendientes'),
                    trailing: Text(
                      promocionesPendientes.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Card roja → promociones rechazadas
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: ListTile(
                    title: const Text('Rechazadas'),
                    trailing: Text(
                      promocionesRechazadas.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Indicador de vistas totales acumuladas ──
                // Muestra el alcance global de todas las promociones combinadas.
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vistas Totales',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Número grande en azul para destacar el KPI de visibilidad
                      Text(
                        totalVistas.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget reutilizable para cada tarjeta del grid de KPIs.
/// Es un StatelessWidget porque no maneja estado propio;
/// solo muestra la información que recibe por parámetros.
class _StatCard extends StatelessWidget {
  final String title;  // Nombre del KPI (ej. "Usuarios")
  final String value;  // Valor numérico ya convertido a String
  final IconData icon; // Ícono representativo de la categoría
  final Color color;   // Color temático de la card (fondo, borde e ícono)

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // withOpacity(0.1) crea un fondo muy suave del color de la categoría,
        // manteniendo legibilidad y diferenciando visualmente cada card.
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color), // Borde del mismo color para coherencia
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centra el contenido verticalmente
        children: [
          Icon(icon, color: color, size: 32),  // Ícono grande del color temático
          const SizedBox(height: 8),
          // Número principal del KPI en grande y en negrita
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          // Etiqueta descriptiva debajo del número
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
