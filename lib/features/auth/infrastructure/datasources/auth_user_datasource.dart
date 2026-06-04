import 'package:app/features/promotions/infrastructure/services/promo_service.dart';
import 'package:app/features/users/domain/entities/usuario.dart';

/// Contrato de fuente de datos de autenticacion; separa el origen concreto de la informacion del resto de la app.
abstract class AuthUserDataSource {
  Usuario? findByEmail(String correo);
  List<Usuario> getAllUsers();
  void addUser(Usuario usuario);
  void updateUser(Usuario usuario);
}

/// Fuente de datos de autenticacion; obtiene y transforma informacion desde servicios o almacenamiento local.
class PromoAuthUserDataSource implements AuthUserDataSource {
  final PromoService promoService;

  PromoAuthUserDataSource(this.promoService);

  @override
  Usuario? findByEmail(String correo) {
    return promoService.getUsuarioByEmail(correo);
  }

  @override
  List<Usuario> getAllUsers() {
    return promoService.getUsuarios();
  }

  @override
  void addUser(Usuario usuario) {
    promoService.addUsuario(usuario);
  }

  @override
  void updateUser(Usuario usuario) {
    promoService.updateUsuario(usuario);
  }
}
