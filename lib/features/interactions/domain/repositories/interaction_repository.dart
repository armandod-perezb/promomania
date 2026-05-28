import '../entities/favorito.dart';
import '../entities/valoracion.dart';

abstract class InteractionRepository {
  // ── Sync queries ──────────────────────────────────────────────────────────
  List<Favorito> getFavoritosByUsuarioSync(int userId);
  bool isFavoritoSync(int userId, String promotionCode);
  List<Valoracion> getValoracionesByPromocionSync(String promotionCode);
  List<Valoracion> getAllValoracionesSync();

  // ── Async commands ────────────────────────────────────────────────────────
  Future<List<Favorito>> getFavoritosByUsuario(int userId);
  Future<bool> isFavorito(int userId, String promotionCode);
  Future<void> toggleFavorito(int userId, String promotionCode);

  Future<List<Valoracion>> getValoracionesByPromocion(String promotionCode);
  Future<int> countPositiveRatings(String promotionCode);
  Future<int> countNegativeRatings(String promotionCode);
  Future<void> addValoracion(Valoracion valoracion);
  Future<void> deleteValoracion(int id);
}
