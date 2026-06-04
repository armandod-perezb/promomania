import 'package:app/features/users/domain/entities/usuario.dart';
import 'package:app/features/users/domain/usecases/user_usecases.dart';

/// Controlador de usuarios; coordina casos de uso y expone operaciones para la capa de presentacion.
class UsersController {
  final GetUserByIdUseCase _getUserByIdUseCase;
  final GetAllUsersUseCase _getAllUsersUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final DeactivateUserUseCase _deactivateUserUseCase;
  final GetUsersByCityUseCase _getUsersByCityUseCase;
  final GetUsersSyncUseCase _getUsersSyncUseCase;
  final GetUserByIdSyncUseCase _getUserByIdSyncUseCase;
  final AddUserUseCase _addUserUseCase;
  final DeleteUserUseCase _deleteUserUseCase;

  UsersController({
    required GetUserByIdUseCase getUserByIdUseCase,
    required GetAllUsersUseCase getAllUsersUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required DeactivateUserUseCase deactivateUserUseCase,
    required GetUsersByCityUseCase getUsersByCityUseCase,
    required GetUsersSyncUseCase getUsersSyncUseCase,
    required GetUserByIdSyncUseCase getUserByIdSyncUseCase,
    required AddUserUseCase addUserUseCase,
    required DeleteUserUseCase deleteUserUseCase,
  }) : _getUserByIdUseCase = getUserByIdUseCase,
       _getAllUsersUseCase = getAllUsersUseCase,
       _updateUserProfileUseCase = updateUserProfileUseCase,
       _changePasswordUseCase = changePasswordUseCase,
       _deactivateUserUseCase = deactivateUserUseCase,
       _getUsersByCityUseCase = getUsersByCityUseCase,
       _getUsersSyncUseCase = getUsersSyncUseCase,
       _getUserByIdSyncUseCase = getUserByIdSyncUseCase,
       _addUserUseCase = addUserUseCase,
       _deleteUserUseCase = deleteUserUseCase;

  // ── Sync queries ──────────────────────────────────────────────────────────
  List<Usuario> getUsersSync() => _getUsersSyncUseCase.execute();
  Usuario? getUserByIdSync(int id) => _getUserByIdSyncUseCase.execute(id);

  // ── Async commands ────────────────────────────────────────────────────────
  Future<Usuario> getUserById(int id) => _getUserByIdUseCase.execute(id);
  Future<List<Usuario>> getAllUsers({int? page, int? pageSize}) =>
      _getAllUsersUseCase.execute(page: page, pageSize: pageSize);
  Future<Usuario> updateUserProfile(Usuario usuario) =>
      _updateUserProfileUseCase.execute(usuario);
  Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) => _changePasswordUseCase.execute(
    userId: userId,
    currentPassword: currentPassword,
    newPassword: newPassword,
  );
  Future<void> deactivateUser(int userId) =>
      _deactivateUserUseCase.execute(userId);
  Future<List<Usuario>> getUsersByCity(String city) =>
      _getUsersByCityUseCase.execute(city);
  Future<void> addUser(Usuario usuario) => _addUserUseCase.execute(usuario);
  Future<void> deleteUser(int userId) => _deleteUserUseCase.execute(userId);
}
