import 'package:app/features/interactions/domain/entities/favorito.dart';
import 'package:app/features/interactions/domain/entities/valoracion.dart';
import 'package:app/features/interactions/domain/usecases/interaction_usecases.dart';

class InteractionsController {
  final GetFavoritosByUsuarioSyncUseCase _getFavoritosByUsuarioSync;
  final IsFavoritoSyncUseCase _isFavoritoSync;
  final GetValoracionesByPromocionSyncUseCase _getValoracionesByPromocionSync;
  final GetAllValoracionesSyncUseCase _getAllValoracionesSync;
  final GetFavoritosByUsuarioUseCase _getFavoritosByUsuario;
  final IsFavoritoUseCase _isFavorito;
  final ToggleFavoritoUseCase _toggleFavorito;
  final GetValoracionesByPromocionUseCase _getValoracionesByPromocion;
  final CountPositiveRatingsUseCase _countPositiveRatings;
  final CountNegativeRatingsUseCase _countNegativeRatings;
  final AddValoracionUseCase _addValoracion;
  final DeleteValoracionUseCase _deleteValoracion;

  InteractionsController({
    required GetFavoritosByUsuarioSyncUseCase getFavoritosByUsuarioSyncUseCase,
    required IsFavoritoSyncUseCase isFavoritoSyncUseCase,
    required GetValoracionesByPromocionSyncUseCase getValoracionesByPromocionSyncUseCase,
    required GetAllValoracionesSyncUseCase getAllValoracionesSyncUseCase,
    required GetFavoritosByUsuarioUseCase getFavoritosByUsuarioUseCase,
    required IsFavoritoUseCase isFavoritoUseCase,
    required ToggleFavoritoUseCase toggleFavoritoUseCase,
    required GetValoracionesByPromocionUseCase getValoracionesByPromocionUseCase,
    required CountPositiveRatingsUseCase countPositiveRatingsUseCase,
    required CountNegativeRatingsUseCase countNegativeRatingsUseCase,
    required AddValoracionUseCase addValoracionUseCase,
    required DeleteValoracionUseCase deleteValoracionUseCase,
  })  : _getFavoritosByUsuarioSync = getFavoritosByUsuarioSyncUseCase,
        _isFavoritoSync = isFavoritoSyncUseCase,
        _getValoracionesByPromocionSync = getValoracionesByPromocionSyncUseCase,
        _getAllValoracionesSync = getAllValoracionesSyncUseCase,
        _getFavoritosByUsuario = getFavoritosByUsuarioUseCase,
        _isFavorito = isFavoritoUseCase,
        _toggleFavorito = toggleFavoritoUseCase,
        _getValoracionesByPromocion = getValoracionesByPromocionUseCase,
        _countPositiveRatings = countPositiveRatingsUseCase,
        _countNegativeRatings = countNegativeRatingsUseCase,
        _addValoracion = addValoracionUseCase,
        _deleteValoracion = deleteValoracionUseCase;

  // ── Sync queries ──────────────────────────────────────────────────────────
  List<Favorito> getFavoritosByUsuarioSync(int userId) => _getFavoritosByUsuarioSync.execute(userId);
  bool isFavoritoSync(int userId, String promotionCode) => _isFavoritoSync.execute(userId, promotionCode);
  List<Valoracion> getValoracionesByPromocionSync(String promotionCode) => _getValoracionesByPromocionSync.execute(promotionCode);
  List<Valoracion> getAllValoracionesSync() => _getAllValoracionesSync.execute();

  // ── Async commands ────────────────────────────────────────────────────────
  Future<List<Favorito>> getFavoritosByUsuario(int userId) => _getFavoritosByUsuario.execute(userId);
  Future<bool> isFavorito(int userId, String promotionCode) => _isFavorito.execute(userId, promotionCode);
  Future<void> toggleFavorito(int userId, String promotionCode) => _toggleFavorito.execute(userId, promotionCode);
  Future<List<Valoracion>> getValoracionesByPromocion(String promotionCode) => _getValoracionesByPromocion.execute(promotionCode);
  Future<int> countPositiveRatings(String promotionCode) => _countPositiveRatings.execute(promotionCode);
  Future<int> countNegativeRatings(String promotionCode) => _countNegativeRatings.execute(promotionCode);
  Future<void> addValoracion(Valoracion valoracion) => _addValoracion.execute(valoracion);
  Future<void> deleteValoracion(int id) => _deleteValoracion.execute(id);
}
