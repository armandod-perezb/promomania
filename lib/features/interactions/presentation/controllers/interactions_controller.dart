import 'package:app/features/interactions/domain/entities/favorito.dart';
import 'package:app/features/interactions/domain/entities/valoracion.dart';
import 'package:app/features/interactions/domain/usecases/interaction_usecases.dart';

class InteractionsController {
  final GetFavoritosByUsuarioUseCase _getFavoritosByUsuarioUseCase;
  final IsFavoritoUseCase _isFavoritoUseCase;
  final ToggleFavoritoUseCase _toggleFavoritoUseCase;
  final GetValoracionesByPromocionUseCase _getValoracionesByPromocionUseCase;
  final CountPositiveRatingsUseCase _countPositiveRatingsUseCase;
  final CountNegativeRatingsUseCase _countNegativeRatingsUseCase;
  final AddValoracionUseCase _addValoracionUseCase;
  final DeleteValoracionUseCase _deleteValoracionUseCase;

  InteractionsController({
    required GetFavoritosByUsuarioUseCase getFavoritosByUsuarioUseCase,
    required IsFavoritoUseCase isFavoritoUseCase,
    required ToggleFavoritoUseCase toggleFavoritoUseCase,
    required GetValoracionesByPromocionUseCase getValoracionesByPromocionUseCase,
    required CountPositiveRatingsUseCase countPositiveRatingsUseCase,
    required CountNegativeRatingsUseCase countNegativeRatingsUseCase,
    required AddValoracionUseCase addValoracionUseCase,
    required DeleteValoracionUseCase deleteValoracionUseCase,
  }) : _getFavoritosByUsuarioUseCase = getFavoritosByUsuarioUseCase,
       _isFavoritoUseCase = isFavoritoUseCase,
       _toggleFavoritoUseCase = toggleFavoritoUseCase,
       _getValoracionesByPromocionUseCase = getValoracionesByPromocionUseCase,
       _countPositiveRatingsUseCase = countPositiveRatingsUseCase,
       _countNegativeRatingsUseCase = countNegativeRatingsUseCase,
       _addValoracionUseCase = addValoracionUseCase,
       _deleteValoracionUseCase = deleteValoracionUseCase;

  Future<List<Favorito>> getFavoritosByUsuario(int userId) {
    return _getFavoritosByUsuarioUseCase.execute(userId);
  }

  Future<bool> isFavorito(int userId, String promotionCode) {
    return _isFavoritoUseCase.execute(userId, promotionCode);
  }

  Future<void> toggleFavorito(int userId, String promotionCode) {
    return _toggleFavoritoUseCase.execute(userId, promotionCode);
  }

  Future<List<Valoracion>> getValoracionesByPromocion(String promotionCode) {
    return _getValoracionesByPromocionUseCase.execute(promotionCode);
  }

  Future<int> countPositiveRatings(String promotionCode) {
    return _countPositiveRatingsUseCase.execute(promotionCode);
  }

  Future<int> countNegativeRatings(String promotionCode) {
    return _countNegativeRatingsUseCase.execute(promotionCode);
  }

  Future<void> addValoracion(Valoracion valoracion) {
    return _addValoracionUseCase.execute(valoracion);
  }

  Future<void> deleteValoracion(int id) {
    return _deleteValoracionUseCase.execute(id);
  }
}
