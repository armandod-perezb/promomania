class Usuario {
  final int id;
  final String nombre;
  final String correo;
  final String password;
  final String rol; // 'usuario' o 'admin'
  final String estado; // 'activo' o 'inactivo'
  final String? ciudad;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.password,
    required this.rol,
    required this.estado,
    this.ciudad,
  });

  // Convertir JSON a Objeto
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
      password: json['password'] as String,
      rol: json['rol'] as String? ?? 'usuario',
      estado: json['estado'] as String? ?? 'activo',
      ciudad: json['ciudad'] as String?,
    );
  }

  // Convertir Objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'password': password,
      'rol': rol,
      'estado': estado,
      'ciudad': ciudad,
    };
  }

  // Copiar con cambios
  Usuario copyWith({
    int? id,
    String? nombre,
    String? correo,
    String? password,
    String? rol,
    String? estado,
    String? ciudad,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      password: password ?? this.password,
      rol: rol ?? this.rol,
      estado: estado ?? this.estado,
      ciudad: ciudad ?? this.ciudad,
    );
  }
}
