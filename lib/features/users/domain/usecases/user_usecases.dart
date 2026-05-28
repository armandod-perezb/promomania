import '../entities/usuario.dart';
import '../repositories/user_repository.dart';

class GetUserByIdUseCase {
  final UserRepository repository;

  GetUserByIdUseCase(this.repository);

  Future<Usuario> execute(int id) {
    return repository.getUserById(id);
  }
}

class GetAllUsersUseCase {
  final UserRepository repository;

  GetAllUsersUseCase(this.repository);

  Future<List<Usuario>> execute({int? page, int? pageSize}) {
    return repository.getAllUsers(page: page, pageSize: pageSize);
  }
}

class UpdateUserProfileUseCase {
  final UserRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<Usuario> execute(Usuario usuario) {
    return repository.updateUserProfile(usuario);
  }
}

class ChangePasswordUseCase {
  final UserRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<void> execute({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) {
    return repository.changePassword(
      userId: userId,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}

class DeactivateUserUseCase {
  final UserRepository repository;

  DeactivateUserUseCase(this.repository);

  Future<void> execute(int userId) {
    return repository.deactivateUser(userId);
  }
}

class GetUsersByCityUseCase {
  final UserRepository repository;

  GetUsersByCityUseCase(this.repository);

  Future<List<Usuario>> execute(String city) {
    return repository.getUsersByCity(city);
  }
}

class GetUsersSyncUseCase {
  final UserRepository repository;
  GetUsersSyncUseCase(this.repository);
  List<Usuario> execute() => repository.getUsersSync();
}

class GetUserByIdSyncUseCase {
  final UserRepository repository;
  GetUserByIdSyncUseCase(this.repository);
  Usuario? execute(int id) => repository.getUserByIdSync(id);
}

class AddUserUseCase {
  final UserRepository repository;
  AddUserUseCase(this.repository);
  Future<void> execute(Usuario usuario) => repository.addUser(usuario);
}

class DeleteUserUseCase {
  final UserRepository repository;
  DeleteUserUseCase(this.repository);
  Future<void> execute(int userId) => repository.deleteUser(userId);
}
