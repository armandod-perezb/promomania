class NotificationItem {
  final int id;
  final String titulo;
  final String mensaje;
  final String tipo;
  final String estado;
  final DateTime? fechaProgramada;
  final DateTime? enviadoEn;

  NotificationItem({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.estado,
    this.fechaProgramada,
    this.enviadoEn,
  });

  NotificationItem copyWith({
    int? id,
    String? titulo,
    String? mensaje,
    String? tipo,
    String? estado,
    DateTime? fechaProgramada,
    DateTime? enviadoEn,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      fechaProgramada: fechaProgramada ?? this.fechaProgramada,
      enviadoEn: enviadoEn ?? this.enviadoEn,
    );
  }
}
