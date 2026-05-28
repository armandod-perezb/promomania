import '../entities/usuario.dart';

/// Interfaz de repositorio para gestión de usuarios.
///
/// Define los contratos para operaciones CRUD y consultas de usuarios.
abstract class UserRepository {
  // ── Sync queries ──────────────────────────────────────────────────────────
  List<Usuario> getUsersSync();
  Usuario? getUserByIdSync(int id);

  // ── Async commands ────────────────────────────────────────────────────────
  Future<Usuario> getUserById(int id);
  Future<List<Usuario>> getAllUsers({int? page, int? pageSize});
  Future<Usuario> updateUserProfile(Usuario usuario);
  Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  });
  Future<void> deactivateUser(int userId);
  Future<List<Usuario>> getUsersByCity(String city);
  Future<void> addUser(Usuario usuario);
  Future<void> deleteUser(int userId);
}
