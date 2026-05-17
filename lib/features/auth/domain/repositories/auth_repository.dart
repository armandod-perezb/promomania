import '../../../users/domain/entities/usuario.dart';

/// Interfaz de repositorio para operaciones de autenticación y gestión de usuarios.
///
/// Define los contratos que debe cumplir cualquier implementación de acceso a datos
/// para autenticación (login, register) y gestión de sesiones.
abstract class AuthRepository {
  /// Autentica un usuario con correo y contraseña.
  ///
  /// Retorna el usuario autenticado si es exitoso.
  /// Lanza excepciones en caso de credenciales inválidas.
  Future<Usuario> login({required String correo, required String password});

  /// Registra un nuevo usuario en el sistema.
  ///
  /// Retorna el usuario creado.
  /// Lanza excepciones si el correo ya existe o los datos son inválidos.
  Future<Usuario> register({
    required String nombre,
    required String correo,
    required String password,
  });

  /// Cierra la sesión del usuario actual.
  Future<void> logout();

  /// Obtiene el usuario actualmente autenticado.
  ///
  /// Retorna null si no hay usuario autenticado.
  Future<Usuario?> getCurrentUser();

  /// Refresca el token de la sesión actual.
  Future<void> refreshToken();

  /// Solicita el envío de código de recuperación para el correo indicado.
  Future<void> sendRecoveryCode({required String correo});

  /// Verifica el código de recuperación asociado a un correo.
  Future<bool> verifyRecoveryCode({required String correo, required String code});

  /// Actualiza la contraseña del usuario asociado al correo.
  Future<void> resetPassword({
    required String correo,
    required String newPassword,
  });
}
