class TipoPromocion {
  final int id;
  final String nombre;
  final String? descripcion;
  final String estado; // 'activo' o 'inactivo'

  TipoPromocion({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.estado,
  });

  factory TipoPromocion.fromJson(Map<String, dynamic> json) {
    return TipoPromocion(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      estado: json['estado'] as String? ?? 'activo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'estado': estado,
    };
  }

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
