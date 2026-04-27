import 'package:flutter/material.dart';
import '../main.dart';

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
    return AnimatedBuilder(
      animation: promoService,
      builder: (context, _) {
        // Snapshot de entidades para calcular indicadores agregados del panel.
        final usuarios = promoService.getUsuarios();
        final promociones = promoService.getPromociones();
        final supermercados = promoService.getSupermercados();
        final comentarios = promoService.getComentarios();

        // Estadísticas
        final promocionesAprobadas = promociones
            .where((p) => p.estado == 'aprobada')
            .length;
        final promocionesPendientes = promociones
            .where((p) => p.estado == 'pendiente')
            .length;
        final promocionesRechazadas = promociones
            .where((p) => p.estado == 'rechazada')
            .length;
        // Acumulado de alcance bruto de todas las promociones.
        final totalVistas = promociones.fold<int>(
          0,
          (sum, p) => sum + p.vistas,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Panel de Administración'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Matriz de KPIs base para lectura rapida del estado del sistema.
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _StatCard(
                      title: 'Usuarios',
                      value: usuarios.length.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      title: 'Promociones',
                      value: promociones.length.toString(),
                      icon: Icons.local_offer,
                      color: Colors.orange,
                    ),
                    _StatCard(
                      title: 'Supermercados',
                      value: supermercados.length.toString(),
                      icon: Icons.store,
                      color: Colors.green,
                    ),
                    _StatCard(
                      title: 'Comentarios',
                      value: comentarios.length.toString(),
                      icon: Icons.comment,
                      color: Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Desglose por estado para detectar cuellos de revision/aprobacion.
                const Text(
                  'Estado de Promociones',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.yellow[700]!),
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
                // Indicador global de visibilidad acumulada de contenido promocional.
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

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
        // Color por categoria para diferenciar cada tarjeta del grid.
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
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
