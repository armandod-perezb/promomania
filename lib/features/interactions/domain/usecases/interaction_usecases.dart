import '../entities/favorito.dart';
import '../entities/valoracion.dart';
import '../repositories/interaction_repository.dart';

class GetFavoritosByUsuarioSyncUseCase {
  final InteractionRepository repository;
  GetFavoritosByUsuarioSyncUseCase(this.repository);
  List<Favorito> execute(int userId) => repository.getFavoritosByUsuarioSync(userId);
}

class IsFavoritoSyncUseCase {
  final InteractionRepository repository;
  IsFavoritoSyncUseCase(this.repository);
  bool execute(int userId, String promotionCode) => repository.isFavoritoSync(userId, promotionCode);
}

class GetValoracionesByPromocionSyncUseCase {
  final InteractionRepository repository;
  GetValoracionesByPromocionSyncUseCase(this.repository);
  List<Valoracion> execute(String promotionCode) => repository.getValoracionesByPromocionSync(promotionCode);
}

class GetAllValoracionesSyncUseCase {
  final InteractionRepository repository;
  GetAllValoracionesSyncUseCase(this.repository);
  List<Valoracion> execute() => repository.getAllValoracionesSync();
}

class GetFavoritosByUsuarioUseCase {
  final InteractionRepository repository;

  GetFavoritosByUsuarioUseCase(this.repository);

  Future<List<Favorito>> execute(int userId) {
    return repository.getFavoritosByUsuario(userId);
  }
}

class IsFavoritoUseCase {
  final InteractionRepository repository;

  IsFavoritoUseCase(this.repository);

  Future<bool> execute(int userId, String promotionCode) {
    return repository.isFavorito(userId, promotionCode);
  }
}

class ToggleFavoritoUseCase {
  final InteractionRepository repository;

  ToggleFavoritoUseCase(this.repository);

  Future<void> execute(int userId, String promotionCode) {
    return repository.toggleFavorito(userId, promotionCode);
  }
}

class GetValoracionesByPromocionUseCase {
  final InteractionRepository repository;

  GetValoracionesByPromocionUseCase(this.repository);

  Future<List<Valoracion>> execute(String promotionCode) {
    return repository.getValoracionesByPromocion(promotionCode);
  }
}

class CountPositiveRatingsUseCase {
  final InteractionRepository repository;

  CountPositiveRatingsUseCase(this.repository);

  Future<int> execute(String promotionCode) {
    return repository.countPositiveRatings(promotionCode);
  }
}

class CountNegativeRatingsUseCase {
  final InteractionRepository repository;

  CountNegativeRatingsUseCase(this.repository);

  Future<int> execute(String promotionCode) {
    return repository.countNegativeRatings(promotionCode);
  }
}

class AddValoracionUseCase {
  final InteractionRepository repository;

  AddValoracionUseCase(this.repository);

  Future<void> execute(Valoracion valoracion) {
    return repository.addValoracion(valoracion);
  }
}

class DeleteValoracionUseCase {
  final InteractionRepository repository;

  DeleteValoracionUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deleteValoracion(id);
  }
}
