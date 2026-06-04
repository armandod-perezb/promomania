import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/infrastructure/datasources/auth_session_datasource.dart';
import 'package:app/features/auth/infrastructure/datasources/auth_user_datasource.dart';
import 'package:app/features/auth/infrastructure/datasources/remote_login_datasource.dart';
import 'package:app/features/users/domain/entities/usuario.dart';

/// Implementacion del repositorio de autenticacion; adapta fuentes de datos remotas/locales al contrato de dominio.
class AuthRepositoryImpl implements AuthRepository {
  final AuthUserDataSource userDataSource;
  final AuthSessionDataSource sessionDataSource;
  final RemoteLoginDataSource? remoteLoginDataSource;
  final Map<String, _RecoveryCodeEntry> _recoveryCodes = {};

  AuthRepositoryImpl({
    required this.userDataSource,
    required this.sessionDataSource,
    this.remoteLoginDataSource,
  });

  static const Duration _recoveryCodeTtl = Duration(minutes: 10);

  String _normalizeEmail(String correo) => correo.trim().toLowerCase();

  int _nextUserId() {
    final users = userDataSource.getAllUsers();
    if (users.isEmpty) {
      return 1;
    }
    return users.last.id + 1;
  }

  @override
  Future<Usuario> login({
    required String correo,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(correo);

    if (remoteLoginDataSource != null) {
      try {
        final result = await remoteLoginDataSource!.login(
          correo: normalizedEmail,
          password: password,
        );
        await sessionDataSource.saveSession(
          result.usuario,
          token: result.token,
        );
        return result.usuario;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }

    final usuario = userDataSource.findByEmail(normalizedEmail);
    if (usuario == null) {
      throw UserNotFoundException('Usuario no encontrado');
    }
    if (usuario.password != password) {
      throw AuthenticationException('Contrasena incorrecta');
    }
    await sessionDataSource.saveSession(usuario);
    return usuario;
  }

  @override
  Future<Usuario> register({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(correo);

    if (remoteLoginDataSource != null) {
      try {
        final result = await remoteLoginDataSource!.register(
          nombre: nombre.trim(),
          correo: normalizedEmail,
          password: password,
        );
        await sessionDataSource.saveSession(
          result.usuario,
          token: result.token,
        );
        return result.usuario;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }

    final usuarioExistente = userDataSource.findByEmail(normalizedEmail);
    if (usuarioExistente != null) {
      throw ValidationException('El email ya esta registrado');
    }

    final nuevoUsuario = Usuario(
      id: _nextUserId(),
      nombre: nombre.trim(),
      correo: normalizedEmail,
      password: password,
      rol: 'usuario',
      estado: 'activo',
    );

    userDataSource.addUser(nuevoUsuario);
    await sessionDataSource.saveSession(nuevoUsuario);
    return nuevoUsuario;
  }

  @override
  Future<void> logout() async {
    await sessionDataSource.clearSession();
  }

  @override
  Future<Usuario?> getCurrentUser() async {
    return sessionDataSource.getCurrentUser();
  }

  @override
  Future<void> refreshToken() async {}

  @override
  Future<void> sendRecoveryCode({required String correo}) async {
    final normalizedEmail = _normalizeEmail(correo);
    final usuario = userDataSource.findByEmail(normalizedEmail);
    if (usuario == null) {
      throw UserNotFoundException('Usuario no encontrado');
    }

    _recoveryCodes[normalizedEmail] = _RecoveryCodeEntry(
      code: '123456',
      expiresAt: DateTime.now().add(_recoveryCodeTtl),
    );
  }

  @override
  Future<bool> verifyRecoveryCode({
    required String correo,
    required String code,
  }) async {
    final normalizedEmail = _normalizeEmail(correo);
    final usuario = userDataSource.findByEmail(normalizedEmail);
    if (usuario == null) {
      throw UserNotFoundException('Usuario no encontrado');
    }

    final entry = _recoveryCodes[normalizedEmail];
    if (entry == null) {
      return false;
    }

    if (DateTime.now().isAfter(entry.expiresAt)) {
      _recoveryCodes.remove(normalizedEmail);
      return false;
    }

    return entry.code == code.trim();
  }

  @override
  Future<void> resetPassword({
    required String correo,
    required String newPassword,
  }) async {
    final normalizedEmail = _normalizeEmail(correo);
    final usuario = userDataSource.findByEmail(normalizedEmail);
    if (usuario == null) {
      throw UserNotFoundException('Usuario no encontrado');
    }

    userDataSource.updateUser(usuario.copyWith(password: newPassword));
    _recoveryCodes.remove(normalizedEmail);
  }

  bool _shouldFallbackToLocal(Object error) {
    return error is NetworkException;
  }
}

/// Tipo auxiliar interno usado por autenticacion para mantener la pantalla organizada.
class _RecoveryCodeEntry {
  final String code;
  final DateTime expiresAt;

  _RecoveryCodeEntry({required this.code, required this.expiresAt});
}
