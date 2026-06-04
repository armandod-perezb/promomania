import '../entities/usuario.dart';
import '../repositories/user_repository.dart';

/// Caso de uso para obtener un usuario por identificador; mantiene la regla de negocio fuera de la interfaz.
class GetUserByIdUseCase {
  final UserRepository repository;

  GetUserByIdUseCase(this.repository);

  Future<Usuario> execute(int id) {
    return repository.getUserById(id);
  }
}

/// Caso de uso para obtener todos los usuarios; mantiene la regla de negocio fuera de la interfaz.
class GetAllUsersUseCase {
  final UserRepository repository;

  GetAllUsersUseCase(this.repository);

  Future<List<Usuario>> execute({int? page, int? pageSize}) {
    return repository.getAllUsers(page: page, pageSize: pageSize);
  }
}

/// Caso de uso para actualizar el perfil del usuario; mantiene la regla de negocio fuera de la interfaz.
class UpdateUserProfileUseCase {
  final UserRepository repository;

  UpdateUserProfileUseCase(this.repository);

  Future<Usuario> execute(Usuario usuario) {
    return repository.updateUserProfile(usuario);
  }
}

/// Caso de uso para cambiar la contrasena del usuario; mantiene la regla de negocio fuera de la interfaz.
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

/// Caso de uso para desactivar un usuario; mantiene la regla de negocio fuera de la interfaz.
class DeactivateUserUseCase {
  final UserRepository repository;

  DeactivateUserUseCase(this.repository);

  Future<void> execute(int userId) {
    return repository.deactivateUser(userId);
  }
}

/// Caso de uso para obtener usuarios por ciudad; mantiene la regla de negocio fuera de la interfaz.
class GetUsersByCityUseCase {
  final UserRepository repository;

  GetUsersByCityUseCase(this.repository);

  Future<List<Usuario>> execute(String city) {
    return repository.getUsersByCity(city);
  }
}

/// Caso de uso para obtener usuarios desde cache local; mantiene la regla de negocio fuera de la interfaz.
class GetUsersSyncUseCase {
  final UserRepository repository;
  GetUsersSyncUseCase(this.repository);
  List<Usuario> execute() => repository.getUsersSync();
}

/// Caso de uso para obtener un usuario desde cache local; mantiene la regla de negocio fuera de la interfaz.
class GetUserByIdSyncUseCase {
  final UserRepository repository;
  GetUserByIdSyncUseCase(this.repository);
  Usuario? execute(int id) => repository.getUserByIdSync(id);
}

/// Caso de uso para agregar un usuario; mantiene la regla de negocio fuera de la interfaz.
class AddUserUseCase {
  final UserRepository repository;
  AddUserUseCase(this.repository);
  Future<void> execute(Usuario usuario) => repository.addUser(usuario);
}

/// Caso de uso para eliminar un usuario; mantiene la regla de negocio fuera de la interfaz.
class DeleteUserUseCase {
  final UserRepository repository;
  DeleteUserUseCase(this.repository);
  Future<void> execute(int userId) => repository.deleteUser(userId);
}
