/// Modelo que representa un usuario de la aplicación.
///
/// Contiene los datos básicos necesarios para autenticación, autorización
/// y personalización (por ejemplo la ciudad). Se usa en `PromoService`
/// para identificar al creador de promociones y en las pantallas de admin.
class Usuario {
  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

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

  /// Nivel de experiencia del usuario. Todos empiezan en nivel 1.
  final int nivel;

  /// Puntos acumulados por promociones aprobadas.
  final int puntuacion;

  /// Fecha de creación ISO enviada por el backend.
  final String? createdAt;

  /// Fecha de última actualización ISO enviada por el backend.
  final String? updatedAt;

  /// Constructor principal.
  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.password,
    required this.rol,
    required this.estado,
    this.ciudad,
    this.nivel = 1,
    this.puntuacion = 0,
    this.createdAt,
    this.updatedAt,
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
      password: json['password'] as String? ?? '',
      rol: json['rol'] as String? ?? 'usuario',
      estado: json['estado'] as String? ?? 'activo',
      ciudad: json['ciudad'] as String?,
      nivel: _asInt(json['nivel'], fallback: 1),
      puntuacion: _asInt(json['puntuacion']),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
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
      'nivel': nivel,
      'puntuacion': puntuacion,
      'created_at': createdAt,
      'updated_at': updatedAt,
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
    int? nivel,
    int? puntuacion,
    String? createdAt,
    String? updatedAt,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      password: password ?? this.password,
      rol: rol ?? this.rol,
      estado: estado ?? this.estado,
      ciudad: ciudad ?? this.ciudad,
      nivel: nivel ?? this.nivel,
      puntuacion: puntuacion ?? this.puntuacion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
