/// Modelo que representa una valoración (like/dislike) asociada a una promoción.
///
/// Cada `Valoracion` indica si un usuario marcó la promoción como positiva
/// o negativa. Se guarda como parte de los datos de la app y se usa para
/// calcular métricas y el rating de una promoción.
class Valoracion {
  /// Identificador único de la valoración.
  final int id;

  /// Tipo de valoración: 'positiva' o 'negativa'.
  final String tipo;

  /// ID del usuario que hizo la valoración (referencia a `Usuario`).
  final int idUsuario;

  /// Código de la promoción valorada (referencia a `Promocion.codigo`).
  final String codigoPromocion;

  /// Constructor principal.
  Valoracion({
    required this.id,
    required this.tipo,
    required this.idUsuario,
    required this.codigoPromocion,
  });

  /// Construye una instancia a partir de un `Map` (JSON).
  factory Valoracion.fromJson(Map<String, dynamic> json) {
    return Valoracion(
      id: json['id'] as int,
      tipo: json['tipo'] as String,
      idUsuario: json['id_usuario'] as int,
      codigoPromocion: json['codigo_promocion'] as String,
    );
  }

  /// Serializa la valoración a `Map<String, dynamic>` para persistencia.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'id_usuario': idUsuario,
      'codigo_promocion': codigoPromocion,
    };
  }
}
