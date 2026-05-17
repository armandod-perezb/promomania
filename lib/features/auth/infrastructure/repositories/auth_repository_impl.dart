import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/infrastructure/datasources/auth_session_datasource.dart';
import 'package:app/features/auth/infrastructure/datasources/auth_user_datasource.dart';
import 'package:app/features/users/domain/entities/usuario.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthUserDataSource userDataSource;
  final AuthSessionDataSource sessionDataSource;
  final Map<String, _RecoveryCodeEntry> _recoveryCodes = {};

  AuthRepositoryImpl({
    required this.userDataSource,
    required this.sessionDataSource,
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
  Future<Usuario> login({required String correo, required String password}) async {
    final usuario = userDataSource.findByEmail(_normalizeEmail(correo));
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
  Future<bool> verifyRecoveryCode({required String correo, required String code}) async {
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
  Future<void> resetPassword({required String correo, required String newPassword}) async {
    final normalizedEmail = _normalizeEmail(correo);
    final usuario = userDataSource.findByEmail(normalizedEmail);
    if (usuario == null) {
      throw UserNotFoundException('Usuario no encontrado');
    }

    userDataSource.updateUser(usuario.copyWith(password: newPassword));
    _recoveryCodes.remove(normalizedEmail);
  }
}

class _RecoveryCodeEntry {
  final String code;
  final DateTime expiresAt;

  _RecoveryCodeEntry({required this.code, required this.expiresAt});
}
