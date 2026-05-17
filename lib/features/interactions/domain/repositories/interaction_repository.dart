import '../entities/favorito.dart';
import '../entities/valoracion.dart';

abstract class InteractionRepository {
  Future<List<Favorito>> getFavoritosByUsuario(int userId);
  Future<bool> isFavorito(int userId, String promotionCode);
  Future<void> toggleFavorito(int userId, String promotionCode);

  Future<List<Valoracion>> getValoracionesByPromocion(String promotionCode);
  Future<int> countPositiveRatings(String promotionCode);
  Future<int> countNegativeRatings(String promotionCode);
  Future<void> addValoracion(Valoracion valoracion);
  Future<void> deleteValoracion(int id);
}
