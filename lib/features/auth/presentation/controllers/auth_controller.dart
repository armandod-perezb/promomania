import 'package:app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:app/features/users/domain/entities/usuario.dart';

/// Controlador de autenticacion; coordina casos de uso y expone operaciones para la capa de presentacion.
class AuthController {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final SendRecoveryCodeUseCase _sendRecoveryCodeUseCase;
  final VerifyRecoveryCodeUseCase _verifyRecoveryCodeUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthController({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required SendRecoveryCodeUseCase sendRecoveryCodeUseCase,
    required VerifyRecoveryCodeUseCase verifyRecoveryCodeUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _sendRecoveryCodeUseCase = sendRecoveryCodeUseCase,
       _verifyRecoveryCodeUseCase = verifyRecoveryCodeUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _logoutUseCase = logoutUseCase;

  Future<Usuario> login({required String correo, required String password}) {
    return _loginUseCase.execute(correo: correo, password: password);
  }

  Future<Usuario> register({
    required String nombre,
    required String correo,
    required String password,
  }) {
    return _registerUseCase.execute(
      nombre: nombre,
      correo: correo,
      password: password,
    );
  }

  Future<void> sendRecoveryCode({required String correo}) {
    return _sendRecoveryCodeUseCase.execute(correo: correo);
  }

  Future<bool> verifyRecoveryCode({
    required String correo,
    required String code,
  }) {
    return _verifyRecoveryCodeUseCase.execute(correo: correo, code: code);
  }

  Future<void> resetPassword({
    required String correo,
    required String newPassword,
  }) {
    return _resetPasswordUseCase.execute(
      correo: correo,
      newPassword: newPassword,
    );
  }

  Future<void> logout() {
    return _logoutUseCase.execute();
  }
}
