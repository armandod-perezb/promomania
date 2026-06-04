import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/users/domain/entities/usuario.dart';

/// Caso de uso para iniciar sesion; mantiene la regla de negocio fuera de la interfaz.
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Usuario> execute({required String correo, required String password}) {
    return repository.login(correo: correo, password: password);
  }
}

/// Caso de uso para registrar un usuario; mantiene la regla de negocio fuera de la interfaz.
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Usuario> execute({
    required String nombre,
    required String correo,
    required String password,
  }) {
    return repository.register(
      nombre: nombre,
      correo: correo,
      password: password,
    );
  }
}

/// Caso de uso para enviar un codigo de recuperacion; mantiene la regla de negocio fuera de la interfaz.
class SendRecoveryCodeUseCase {
  final AuthRepository repository;

  SendRecoveryCodeUseCase(this.repository);

  Future<void> execute({required String correo}) {
    return repository.sendRecoveryCode(correo: correo);
  }
}

/// Caso de uso para verificar un codigo de recuperacion; mantiene la regla de negocio fuera de la interfaz.
class VerifyRecoveryCodeUseCase {
  final AuthRepository repository;

  VerifyRecoveryCodeUseCase(this.repository);

  Future<bool> execute({required String correo, required String code}) {
    return repository.verifyRecoveryCode(correo: correo, code: code);
  }
}

/// Caso de uso para restablecer la contrasena; mantiene la regla de negocio fuera de la interfaz.
class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> execute({required String correo, required String newPassword}) {
    return repository.resetPassword(correo: correo, newPassword: newPassword);
  }
}

/// Caso de uso para cerrar sesion; mantiene la regla de negocio fuera de la interfaz.
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> execute() {
    return repository.logout();
  }
}
