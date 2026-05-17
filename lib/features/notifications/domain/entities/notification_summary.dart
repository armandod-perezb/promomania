class NotificationSummary {
  final int reportesPendientes;
  final int promocionesPendientes;
  final int totalUsuarios;
  final int totalComentarios;
  final DateTime generatedAt;

  NotificationSummary({
    required this.reportesPendientes,
    required this.promocionesPendientes,
    required this.totalUsuarios,
    required this.totalComentarios,
    required this.generatedAt,
  });
}
