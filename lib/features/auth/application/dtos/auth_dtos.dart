/// DTO (Data Transfer Object) para login.
///
/// Encapsula los datos necesarios para autenticar un usuario.
class LoginDTO {
  final String correo;
  final String password;

  LoginDTO({required this.correo, required this.password});

  Map<String, dynamic> toJson() {
    return {'correo': correo, 'password': password};
  }
}

/// DTO para registro de nuevo usuario.
///
/// Encapsula los datos necesarios para crear una nueva cuenta.
class RegisterDTO {
  final String nombre;
  final String correo;
  final String password;
  final String? ciudad;

  RegisterDTO({
    required this.nombre,
    required this.correo,
    required this.password,
    this.ciudad,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'correo': correo,
      'password': password,
      'ciudad': ciudad,
    };
  }
}
