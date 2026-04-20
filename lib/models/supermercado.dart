class Supermercado {
  final int id;
  final String nombre;
  final String? direccion;
  final String? ciudad;
  final String estado; // 'activo' o 'inactivo'

  Supermercado({
    required this.id,
    required this.nombre,
    this.direccion,
    this.ciudad,
    required this.estado,
  });

  factory Supermercado.fromJson(Map<String, dynamic> json) {
    return Supermercado(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String?,
      ciudad: json['ciudad'] as String?,
      estado: json['estado'] as String? ?? 'activo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'ciudad': ciudad,
      'estado': estado,
    };
  }

  Supermercado copyWith({
    int? id,
    String? nombre,
    String? direccion,
    String? ciudad,
    String? estado,
  }) {
    return Supermercado(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      ciudad: ciudad ?? this.ciudad,
      estado: estado ?? this.estado,
    );
  }
}
