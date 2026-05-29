import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/network/api_exception.dart';
import 'package:app/features/users/domain/entities/usuario.dart';

abstract class RemoteUserDataSource {
  Future<List<Usuario>> getAllUsers();
  Future<Usuario> getUserById(int id);
  Future<Usuario> updateUserProfile(Usuario usuario);
  Future<Usuario> createUser(Usuario usuario);
  Future<void> deleteUser(int userId);
}

class ApiRemoteUserDataSource implements RemoteUserDataSource {
  final ApiClient _client;

  ApiRemoteUserDataSource(this._client);

  @override
  Future<List<Usuario>> getAllUsers() async {
    try {
      final data = await _client.getAllPages('/usuarios/');
      return data.map((item) => _usuarioFromApi(item as Map<String, dynamic>)).toList();
    } on ApiRequestException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        throw UnauthorizedException('Tu sesión no es válida. Inicia sesión de nuevo.');
      }
      throw ServerException(e.message);
    }
  }

  @override
  Future<Usuario> getUserById(int id) async {
    try {
      final data = await _client.get('/usuarios/$id/') as Map<String, dynamic>;
      return _usuarioFromApi(data);
    } on ApiRequestException catch (e) {
      if (e.statusCode == 404) {
        throw UserNotFoundException('Usuario no encontrado');
      }
      if (e.statusCode == 401 || e.statusCode == 403) {
        throw UnauthorizedException('Tu sesión no es válida. Inicia sesión de nuevo.');
      }
      throw ServerException(e.message);
    }
  }

  @override
  Future<Usuario> updateUserProfile(Usuario usuario) async {
    try {
      final data = await _client.patch('/usuarios/${usuario.id}/', {
        'nombre': usuario.nombre,
        'correo': usuario.correo,
        if (usuario.ciudad != null && usuario.ciudad!.trim().isNotEmpty)
          'ciudad': usuario.ciudad,
      }) as Map<String, dynamic>;
      return _usuarioFromApi(data);
    } on ApiRequestException catch (e) {
      if (e.statusCode == 400) {
        throw ValidationException(e.message);
      }
      if (e.statusCode == 404) {
        throw UserNotFoundException('Usuario no encontrado');
      }
      if (e.statusCode == 401 || e.statusCode == 403) {
        throw UnauthorizedException('Tu sesión no es válida. Inicia sesión de nuevo.');
      }
      throw ServerException(e.message);
    }
  }

  @override
  Future<Usuario> createUser(Usuario usuario) async {
    try {
      final data = await _client.post('/usuarios/', {
        'nombre': usuario.nombre,
        'correo': usuario.correo,
        'password': usuario.password,
        'rol': usuario.rol,
        'estado': usuario.estado,
        if (usuario.ciudad != null && usuario.ciudad!.trim().isNotEmpty)
          'ciudad': usuario.ciudad,
      }) as Map<String, dynamic>;
      return _usuarioFromApi(data).copyWith(password: usuario.password);
    } on ApiRequestException catch (e) {
      if (e.statusCode == 400) {
        throw ValidationException(e.message);
      }
      if (e.statusCode == 401 || e.statusCode == 403) {
        throw UnauthorizedException('Tu sesión no es válida. Inicia sesión de nuevo.');
      }
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> deleteUser(int userId) async {
    try {
      await _client.delete('/usuarios/$userId/');
    } on ApiRequestException catch (e) {
      if (e.statusCode == 404) {
        throw UserNotFoundException('Usuario no encontrado');
      }
      if (e.statusCode == 401 || e.statusCode == 403) {
        throw UnauthorizedException('Tu sesión no es válida. Inicia sesión de nuevo.');
      }
      throw ServerException(e.message);
    }
  }

  Usuario _usuarioFromApi(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
      password: '',
      rol: json['rol'] as String? ?? 'usuario',
      estado: json['estado'] as String? ?? 'activo',
      ciudad: json['ciudad'] as String?,
    );
  }
}
