import 'package:app/core/storage/session_manager.dart';
import 'package:app/features/users/domain/entities/usuario.dart';

/// Contrato de fuente de datos de autenticacion; separa el origen concreto de la informacion del resto de la app.
abstract class AuthSessionDataSource {
  Future<void> saveSession(Usuario usuario, {String? token});
  Future<void> clearSession();
  Usuario? getCurrentUser();
  String? getToken();
}

/// Fuente de datos de autenticacion; obtiene y transforma informacion desde servicios o almacenamiento local.
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
