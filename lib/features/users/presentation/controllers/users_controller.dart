import 'package:app/features/users/domain/entities/usuario.dart';
import 'package:app/features/users/domain/usecases/user_usecases.dart';

class UsersController {
  final GetUserByIdUseCase _getUserByIdUseCase;
  final GetAllUsersUseCase _getAllUsersUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final DeactivateUserUseCase _deactivateUserUseCase;
  final GetUsersByCityUseCase _getUsersByCityUseCase;

  UsersController({
    required GetUserByIdUseCase getUserByIdUseCase,
    required GetAllUsersUseCase getAllUsersUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required DeactivateUserUseCase deactivateUserUseCase,
    required GetUsersByCityUseCase getUsersByCityUseCase,
  }) : _getUserByIdUseCase = getUserByIdUseCase,
       _getAllUsersUseCase = getAllUsersUseCase,
       _updateUserProfileUseCase = updateUserProfileUseCase,
       _changePasswordUseCase = changePasswordUseCase,
       _deactivateUserUseCase = deactivateUserUseCase,
       _getUsersByCityUseCase = getUsersByCityUseCase;

  Future<Usuario> getUserById(int id) {
    return _getUserByIdUseCase.execute(id);
  }

  Future<List<Usuario>> getAllUsers({int? page, int? pageSize}) {
    return _getAllUsersUseCase.execute(page: page, pageSize: pageSize);
  }

  Future<Usuario> updateUserProfile(Usuario usuario) {
    return _updateUserProfileUseCase.execute(usuario);
  }

  Future<void> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) {
    return _changePasswordUseCase.execute(
      userId: userId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> deactivateUser(int userId) {
    return _deactivateUserUseCase.execute(userId);
  }

  Future<List<Usuario>> getUsersByCity(String city) {
    return _getUsersByCityUseCase.execute(city);
  }
}
