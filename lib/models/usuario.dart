/// Modelo que representa un usuario de la aplicación.
///
/// Contiene los datos básicos necesarios para autenticación, autorización
/// y personalización (por ejemplo la ciudad). Se usa en `PromoService`
/// para identificar al creador de promociones y en las pantallas de admin.
class Usuario {
  /// Identificador único del usuario.
  final int id;

  /// Nombre completo del usuario.
  final String nombre;

  /// Correo electrónico (también usado como identificador para login).
  final String correo;

  /// Contraseña en texto plano en este modelo (en producción debería ser hash).
  final String password;

  /// Rol del usuario: 'usuario' o 'admin'. Controla accesos en la app.
  final String rol;

  /// Estado de la cuenta: 'activo' o 'inactivo'.
  final String estado;

  /// Ciudad del usuario (opcional), usada para segmentación y filtros.
  final String? ciudad;

  /// Constructor principal.
  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.password,
    required this.rol,
    required this.estado,
    this.ciudad,
  });

  /// Crea una instancia de `Usuario` a partir de un `Map` parseado desde JSON.
  ///
  /// Proporciona valores por defecto para `rol` y `estado` cuando no están
  /// presentes en el JSON empaquetado.
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

  /// Serializa el `Usuario` a `Map<String, dynamic>` para convertirlo a JSON.
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

  /// Devuelve una copia inmutable del usuario, permitiendo sobrescribir
  /// únicamente los campos que se pasen (patrón `copyWith`).
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
