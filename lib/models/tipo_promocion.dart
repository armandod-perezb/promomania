/// Modelo que describe un tipo o categoría funcional de promoción.
///
/// Ejemplos: 'descuento', '2x1', 'envio gratis'. Se usa para clasificar
/// promociones y asignarles comportamiento/etiquetas en la UI.
class TipoPromocion {
  /// Identificador único del tipo.
  final int id;

  /// Nombre legible del tipo (por ejemplo: 'Descuento').
  final String nombre;

  /// Descripción opcional que explique el tipo.
  final String? descripcion;

  /// Estado operativo: 'activo' o 'inactivo'.
  final String estado;

  /// Constructor principal.
  TipoPromocion({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.estado,
  });

  /// Construye una instancia a partir de un `Map` (parseado desde JSON).
  ///
  /// Proporciona 'activo' como valor por defecto cuando `estado` está ausente.
  factory TipoPromocion.fromJson(Map<String, dynamic> json) {
    return TipoPromocion(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      estado: json['estado'] as String? ?? 'activo',
    );
  }

  /// Serializa el objeto a `Map<String, dynamic>` para persistirlo en JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'estado': estado,
    };
  }

  /// Devuelve una copia inmutable del `TipoPromocion`, sobrescribiendo
  /// únicamente los campos proporcionados.
  TipoPromocion copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? estado,
  }) {
    return TipoPromocion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
    );
  }
}
