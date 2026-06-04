/// Modelo que representa un supermercado o comercio dentro de la app.
///
/// Se utiliza para relacionar promociones con una tienda física u online.
class Supermercado {
  /// Identificador único del supermercado.
  final int id;

  /// Nombre comercial del supermercado.
  final String nombre;

  /// Dirección física (opcional).
  final String? direccion;

  /// Ciudad donde se ubica el supermercado (opcional).
  final String? ciudad;

  /// Estado operacional: 'activo' o 'inactivo'.
  final String estado;

  /// Fecha de creación ISO enviada por el backend.
  final String? createdAt;

  /// Fecha de última actualización ISO enviada por el backend.
  final String? updatedAt;

  /// Constructor principal.
  Supermercado({
    required this.id,
    required this.nombre,
    this.direccion,
    this.ciudad,
    required this.estado,
    this.createdAt,
    this.updatedAt,
  });

  /// Construye una instancia a partir de un `Map` (parseado desde JSON).
  ///
  /// Si `estado` no está presente se asume 'activo' por defecto.
  factory Supermercado.fromJson(Map<String, dynamic> json) {
    return Supermercado(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String?,
      ciudad: json['ciudad'] as String?,
      estado: json['estado'] as String? ?? 'activo',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Serializa la entidad a `Map<String, dynamic>` para convertirla a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'ciudad': ciudad,
      'estado': estado,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Devuelve una copia inmutable del supermercado, permitiendo actualizar
  /// solo los campos que se pasen como parámetros.
  Supermercado copyWith({
    int? id,
    String? nombre,
    String? direccion,
    String? ciudad,
    String? estado,
    String? createdAt,
    String? updatedAt,
  }) {
    return Supermercado(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      ciudad: ciudad ?? this.ciudad,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
