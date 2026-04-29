/// Modelo que representa un reporte creado por un usuario sobre una promoción.
///
/// Los reportes se usan para notificar problemas, contenido inapropiado
/// o inconsistencia en una promoción. Se almacenan junto a los demás
/// datos en el `PromoService` y pueden persistirse en el JSON local.
class Reporte {
  /// Identificador único del reporte.
  final int id;

  /// Motivo textual del reporte (por ejemplo: 'Producto vencido').
  final String motivo;

  /// Fecha del reporte en formato ISO o legible (se usa como string).
  final String fecha;

  /// Estado del procesamiento del reporte: 'pendiente', 'revisado', 'descartado'.
  final String estado;

  /// ID del usuario que originó el reporte (referencia a `Usuario`).
  final int idUsuario;

  /// Código de la promoción reportada (referencia a `Promocion.codigo`).
  final String codigoPromocion;

  /// Constructor principal con todos los campos obligatorios.
  Reporte({
    required this.id,
    required this.motivo,
    required this.fecha,
    required this.estado,
    required this.idUsuario,
    required this.codigoPromocion,
  });

  /// Construye una instancia desde un `Map` parseado desde JSON.
  ///
  /// Aplica valor por defecto 'pendiente' si `estado` no está presente.
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

  /// Serializa el reporte a `Map` para convertirlo a JSON.
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

  /// Devuelve una copia inmutable del `Reporte`, permitiendo actualizar
  /// solo los campos necesarios (patrón `copyWith`).
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