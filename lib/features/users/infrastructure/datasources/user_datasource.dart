import 'package:app/features/promotions/infrastructure/services/promo_service.dart';
import 'package:app/features/users/domain/entities/usuario.dart';

abstract class UserDataSource {
  Usuario? getUserById(int id);
  List<Usuario> getAllUsers();
  void updateUser(Usuario usuario);
}

class PromoUserDataSource implements UserDataSource {
  final PromoService promoService;

  PromoUserDataSource(this.promoService);

  @override
  Usuario? getUserById(int id) {
    return promoService.getUsuario(id);
  }

  @override
  List<Usuario> getAllUsers() {
    return promoService.getUsuarios();
  }

  @override
  void updateUser(Usuario usuario) {
    promoService.updateUsuario(usuario);
  }
}
