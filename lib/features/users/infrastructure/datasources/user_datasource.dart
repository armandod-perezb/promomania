import 'package:app/features/promotions/infrastructure/services/promo_service.dart';
import 'package:app/features/users/domain/entities/usuario.dart';

abstract class UserDataSource {
  List<Usuario> getAllUsers();
  Usuario? getUserById(int id);
  void updateUser(Usuario usuario);
  void addUser(Usuario usuario);
  void deleteUser(int userId);
}

class PromoUserDataSource implements UserDataSource {
  final PromoService promoService;

  PromoUserDataSource(this.promoService);

  @override
  List<Usuario> getAllUsers() => promoService.getUsuarios();

  @override
  Usuario? getUserById(int id) => promoService.getUsuario(id);

  @override
  void updateUser(Usuario usuario) => promoService.updateUsuario(usuario);

  @override
  void addUser(Usuario usuario) => promoService.addUsuario(usuario);

  @override
  void deleteUser(int userId) => promoService.deleteUsuario(userId);
}
