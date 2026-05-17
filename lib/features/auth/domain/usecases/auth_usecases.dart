import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/users/domain/entities/usuario.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Usuario> execute({required String correo, required String password}) {
    return repository.login(correo: correo, password: password);
  }
}

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

class SendRecoveryCodeUseCase {
  final AuthRepository repository;

  SendRecoveryCodeUseCase(this.repository);

  Future<void> execute({required String correo}) {
    return repository.sendRecoveryCode(correo: correo);
  }
}

class VerifyRecoveryCodeUseCase {
  final AuthRepository repository;

  VerifyRecoveryCodeUseCase(this.repository);

  Future<bool> execute({required String correo, required String code}) {
    return repository.verifyRecoveryCode(correo: correo, code: code);
  }
}

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> execute({required String correo, required String newPassword}) {
    return repository.resetPassword(correo: correo, newPassword: newPassword);
  }
}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> execute() {
    return repository.logout();
  }
}
