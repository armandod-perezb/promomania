class Reporte {
  final int id;
  final String motivo;
  final String fecha;
  final String estado; // 'pendiente', 'revisado', 'descartado'
  final int idUsuario;
  final String codigoPromocion;

  Reporte({
    required this.id,
    required this.motivo,
    required this.fecha,
    required this.estado,
    required this.idUsuario,
    required this.codigoPromocion,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) {
    return Reporte(
      id: json['id'] as int,
      motivo: json['motivo'] as String,
      fecha: json['fecha'] as String,
      estado: json['estado'] as String? ?? 'pendiente',
      idUsuario: json['id_usuario'] as int,
      codigoPromocion: json['codigo_promocion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motivo': motivo,
      'fecha': fecha,
      'estado': estado,
      'id_usuario': idUsuario,
      'codigo_promocion': codigoPromocion,
    };
  }

  Reporte copyWith({
    int? id,
    String? motivo,
    String? fecha,
    String? estado,
    int? idUsuario,
    String? codigoPromocion,
  }) {
    return Reporte(
      id: id ?? this.id,
      motivo: motivo ?? this.motivo,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
      idUsuario: idUsuario ?? this.idUsuario,
      codigoPromocion: codigoPromocion ?? this.codigoPromocion,
    );
  }
}