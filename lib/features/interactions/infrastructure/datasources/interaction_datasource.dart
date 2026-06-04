import 'package:app/features/interactions/domain/entities/favorito.dart';
import 'package:app/features/interactions/domain/entities/valoracion.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart';

/// Contrato de fuente de datos de favoritos y valoraciones; separa el origen concreto de la informacion del resto de la app.
abstract class InteractionDataSource {
  List<Favorito> getFavoritosByUsuario(int userId);
  Favorito? getFavorito(int userId, String promotionCode);
  bool isFavorito(int userId, String promotionCode);
  void addFavorito(Favorito favorito);
  void removeFavorito(int userId, String promotionCode);
  void toggleFavorito(int userId, String promotionCode);
  List<Valoracion> getValoracionesByPromocion(String promotionCode);
  List<Valoracion> getAllValoraciones();
  int countPositiveRatings(String promotionCode);
  int countNegativeRatings(String promotionCode);
  void addValoracion(Valoracion valoracion);
  void deleteValoracion(int id);
}

/// Fuente de datos de favoritos y valoraciones; obtiene y transforma informacion desde servicios o almacenamiento local.
class PromoInteractionDataSource implements InteractionDataSource {
  final PromoService promoService;

  PromoInteractionDataSource(this.promoService);

  @override
  List<Favorito> getFavoritosByUsuario(int userId) =>
      promoService.getFavoritosByUsuario(userId);

  @override
  Favorito? getFavorito(int userId, String promotionCode) {
    final favoritos = promoService.getFavoritosByUsuario(userId);
    for (final favorito in favoritos) {
      if (favorito.codigoPromocion == promotionCode) {
        return favorito;
      }
    }
    return null;
  }

  @override
  bool isFavorito(int userId, String promotionCode) =>
      promoService.isFavorito(userId, promotionCode);

  @override
  void addFavorito(Favorito favorito) => promoService.addFavorito(favorito);

  @override
  void removeFavorito(int userId, String promotionCode) =>
      promoService.removeFavorito(userId, promotionCode);

  @override
  void toggleFavorito(int userId, String promotionCode) =>
      promoService.toggleFavorito(userId, promotionCode);

  @override
  List<Valoracion> getValoracionesByPromocion(String promotionCode) =>
      promoService.getValoracionesByPromocion(promotionCode);

  @override
  List<Valoracion> getAllValoraciones() => promoService.getValoraciones();

  @override
  int countPositiveRatings(String promotionCode) =>
      promoService.contarValoracionesPositivas(promotionCode);

  @override
  int countNegativeRatings(String promotionCode) =>
      promoService.contarValoracionesNegativas(promotionCode);

  @override
  void addValoracion(Valoracion valoracion) =>
      promoService.addValoracion(valoracion);

  @override
  void deleteValoracion(int id) => promoService.deleteValoracion(id);
}
