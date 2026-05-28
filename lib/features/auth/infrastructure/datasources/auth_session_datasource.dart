import 'package:app/core/storage/session_manager.dart';
import 'package:app/features/users/domain/entities/usuario.dart';

abstract class AuthSessionDataSource {
  Future<void> saveSession(Usuario usuario, {String? token});
  Future<void> clearSession();
  Usuario? getCurrentUser();
  String? getToken();
}

class LocalAuthSessionDataSource implements AuthSessionDataSource {
  final SessionManager sessionManager;

  LocalAuthSessionDataSource(this.sessionManager);

  @override
  Future<void> saveSession(Usuario usuario, {String? token}) async {
    await sessionManager.guardarSesion(usuario, token: token);
  }

  @override
  Future<void> clearSession() async {
    await sessionManager.logout();
  }

  @override
  Usuario? getCurrentUser() {
    return sessionManager.usuarioActual;
  }

  @override
  String? getToken() => sessionManager.token;
}
