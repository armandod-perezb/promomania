import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/network/api_exception.dart';
import 'package:app/features/users/domain/entities/usuario.dart';

/// Resultado del login/register remoto: usuario autenticado + Bearer token.
class RemoteLoginResult {
  final String token;
  final Usuario usuario;

  RemoteLoginResult({required this.token, required this.usuario});
}

/// DataSource que autentica usuarios contra la API Django.
///
/// login  → POST /auth/login/
/// register → POST /usuarios/  +  POST /auth/login/
abstract class RemoteLoginDataSource {
  Future<RemoteLoginResult> login({
    required String correo,
    required String password,
  });

  Future<RemoteLoginResult> register({
    required String nombre,
    required String correo,
    required String password,
  });
}

class ApiRemoteLoginDataSource implements RemoteLoginDataSource {
  final ApiClient _client;

  ApiRemoteLoginDataSource(this._client);

  @override
  Future<RemoteLoginResult> login({
    required String correo,
    required String password,
  }) async {
    try {
      final data = await _client.post(
        '/auth/login/',
        {'correo': correo, 'password': password},
      ) as Map<String, dynamic>;

      final token = data['token'] as String;
      final usuarioJson = data['usuario'] as Map<String, dynamic>;
      final usuario = _usuarioFromApi(usuarioJson);
      _client.setToken(token);
      return RemoteLoginResult(token: token, usuario: usuario);
    } on ApiRequestException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 401 || e.statusCode == 403) {
        throw AuthenticationException(e.message);
      }
      throw ServerException(e.message);
    }
  }

  @override
  Future<RemoteLoginResult> register({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    try {
      await _client.post('/usuarios/', {
        'nombre': nombre,
        'correo': correo,
        'password': password,
        'rol': 'usuario',
        'estado': 'activo',
      });
    } on ApiRequestException catch (e) {
      if (e.statusCode == 400) {
        final msg = e.message.contains('correo')
            ? 'El correo ya está registrado'
            : e.message;
        throw ValidationException(msg);
      }
      throw ServerException(e.message);
    }
    return login(correo: correo, password: password);
  }

  /// Construye un [Usuario] desde el JSON de la API.
  /// El campo `password` es write-only en el backend, se deja vacío.
  static Usuario _usuarioFromApi(Map<String, dynamic> json) {
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
