import 'package:app/core/storage/session_manager.dart';
import 'package:app/features/users/domain/entities/usuario.dart';

abstract class AuthSessionDataSource {
  Future<void> saveSession(Usuario usuario);
  Future<void> clearSession();
  Usuario? getCurrentUser();
}

class LocalAuthSessionDataSource implements AuthSessionDataSource {
  final SessionManager sessionManager;

  LocalAuthSessionDataSource(this.sessionManager);

  @override
  Future<void> saveSession(Usuario usuario) async {
    await sessionManager.guardarSesion(usuario);
  }

  @override
  Future<void> clearSession() async {
    await sessionManager.logout();
  }

  @override
  Usuario? getCurrentUser() {
    return sessionManager.usuarioActual;
  }
}
