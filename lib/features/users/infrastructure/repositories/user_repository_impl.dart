import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/storage/session_manager.dart';
import 'package:app/features/users/domain/entities/usuario.dart';
import 'package:app/features/users/domain/repositories/user_repository.dart';
import 'package:app/features/users/infrastructure/datasources/user_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource dataSource;
  final SessionManager sessionManager;

  UserRepositoryImpl({required this.dataSource, required this.sessionManager});

  // ── Sync queries ──────────────────────────────────────────────────────────

  @override
  List<Usuario> getUsersSync() => dataSource.getAllUsers();

  @override
  Usuario? getUserByIdSync(int id) => dataSource.getUserById(id);

  // ── Async commands ────────────────────────────────────────────────────────

  @override
  Future<Usuario> getUserById(int id) async {
    final usuario = dataSource.getUserById(id);
    if (usuario == null) throw UserNotFoundException('Usuario no encontrado');
    return usuario;
  }

  @override
  Future<List<Usuario>> getAllUsers({int? page, int? pageSize}) async {
    final users = dataSource.getAllUsers();
    if (page == null || pageSize == null || pageSize <= 0) return users;
    final start = (page - 1) * pageSize;
    if (start < 0 || start >= users.length) return [];
    return users.sublist(start, (start + pageSize).clamp(0, users.length));
  }

  @override
  Future<Usuario> updateUserProfile(Usuario usuario) async {
    final current = dataSource.getUserById(usuario.id);
    if (current == null) throw UserNotFoundException('Usuario no encontrado');
    dataSource.updateUser(usuario);
    if (sessionManager.usuarioActual?.id == usuario.id) {
      await sessionManager.actualizarUsuario(usuario);
    }
    return usuario;
  }

  @override
  Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final usuario = dataSource.getUserById(userId);
    if (usuario == null) throw UserNotFoundException('Usuario no encontrado');
    if (usuario.password != currentPassword) {
      throw ValidationException('Contrasena actual incorrecta');
    }
    final updated = usuario.copyWith(password: newPassword);
    dataSource.updateUser(updated);
    if (sessionManager.usuarioActual?.id == userId) {
      await sessionManager.actualizarUsuario(updated);
    }
  }

  @override
  Future<void> deactivateUser(int userId) async {
    final usuario = dataSource.getUserById(userId);
    if (usuario == null) throw UserNotFoundException('Usuario no encontrado');
    final updated = usuario.copyWith(estado: 'inactivo');
    dataSource.updateUser(updated);
    if (sessionManager.usuarioActual?.id == userId) {
      await sessionManager.actualizarUsuario(updated);
    }
  }

  @override
  Future<List<Usuario>> getUsersByCity(String city) async {
    final normalizedCity = city.trim().toLowerCase();
    return dataSource.getAllUsers().where((u) {
      return (u.ciudad ?? '').trim().toLowerCase() == normalizedCity;
    }).toList();
  }

  @override
  Future<void> addUser(Usuario usuario) async => dataSource.addUser(usuario);

  @override
  Future<void> deleteUser(int userId) async => dataSource.deleteUser(userId);
}
