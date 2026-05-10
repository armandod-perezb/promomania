import '../entities/usuario.dart';

/// Interfaz de repositorio para gestión de usuarios.
///
/// Define los contratos para operaciones CRUD y consultas de usuarios.
abstract class UserRepository {
  /// Obtiene un usuario por su ID.
  Future<Usuario> getUserById(int id);

  /// Obtiene todos los usuarios (con paginación opcional).
  Future<List<Usuario>> getAllUsers({int? page, int? pageSize});

  /// Actualiza el perfil del usuario actual.
  Future<Usuario> updateUserProfile(Usuario usuario);

  /// Cambia la contraseña del usuario.
  Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  });

  /// Desactiva la cuenta del usuario.
  Future<void> deactivateUser(int userId);

  /// Obtiene usuarios por ciudad (para segmentación).
  Future<List<Usuario>> getUsersByCity(String city);
}
