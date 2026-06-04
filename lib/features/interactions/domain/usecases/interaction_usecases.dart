import '../entities/favorito.dart';
import '../entities/valoracion.dart';
import '../repositories/interaction_repository.dart';

/// Caso de uso para obtener favoritos de un usuario desde cache local; mantiene la regla de negocio fuera de la interfaz.
class GetFavoritosByUsuarioSyncUseCase {
  final InteractionRepository repository;
  GetFavoritosByUsuarioSyncUseCase(this.repository);
  List<Favorito> execute(int userId) =>
      repository.getFavoritosByUsuarioSync(userId);
}

/// Caso de uso para consultar si una promocion es favorita desde cache local; mantiene la regla de negocio fuera de la interfaz.
class IsFavoritoSyncUseCase {
  final InteractionRepository repository;
  IsFavoritoSyncUseCase(this.repository);
  bool execute(int userId, String promotionCode) =>
      repository.isFavoritoSync(userId, promotionCode);
}

/// Caso de uso para obtener valoraciones de una promocion desde cache local; mantiene la regla de negocio fuera de la interfaz.
class GetValoracionesByPromocionSyncUseCase {
  final InteractionRepository repository;
  GetValoracionesByPromocionSyncUseCase(this.repository);
  List<Valoracion> execute(String promotionCode) =>
      repository.getValoracionesByPromocionSync(promotionCode);
}

/// Caso de uso para obtener todas las valoraciones desde cache local; mantiene la regla de negocio fuera de la interfaz.
class GetAllValoracionesSyncUseCase {
  final InteractionRepository repository;
  GetAllValoracionesSyncUseCase(this.repository);
  List<Valoracion> execute() => repository.getAllValoracionesSync();
}

/// Caso de uso para obtener favoritos de un usuario; mantiene la regla de negocio fuera de la interfaz.
class GetFavoritosByUsuarioUseCase {
  final InteractionRepository repository;

  GetFavoritosByUsuarioUseCase(this.repository);

  Future<List<Favorito>> execute(int userId) {
    return repository.getFavoritosByUsuario(userId);
  }
}

/// Caso de uso para consultar si una promocion esta marcada como favorita; mantiene la regla de negocio fuera de la interfaz.
class IsFavoritoUseCase {
  final InteractionRepository repository;

  IsFavoritoUseCase(this.repository);

  Future<bool> execute(int userId, String promotionCode) {
    return repository.isFavorito(userId, promotionCode);
  }
}

/// Caso de uso para agregar o quitar una promocion de favoritos; mantiene la regla de negocio fuera de la interfaz.
class ToggleFavoritoUseCase {
  final InteractionRepository repository;

  ToggleFavoritoUseCase(this.repository);

  Future<void> execute(int userId, String promotionCode) {
    return repository.toggleFavorito(userId, promotionCode);
  }
}

/// Caso de uso para obtener valoraciones de una promocion; mantiene la regla de negocio fuera de la interfaz.
class GetValoracionesByPromocionUseCase {
  final InteractionRepository repository;

  GetValoracionesByPromocionUseCase(this.repository);

  Future<List<Valoracion>> execute(String promotionCode) {
    return repository.getValoracionesByPromocion(promotionCode);
  }
}

/// Caso de uso para contar valoraciones positivas; mantiene la regla de negocio fuera de la interfaz.
class CountPositiveRatingsUseCase {
  final InteractionRepository repository;

  CountPositiveRatingsUseCase(this.repository);

  Future<int> execute(String promotionCode) {
    return repository.countPositiveRatings(promotionCode);
  }
}

/// Caso de uso para contar valoraciones negativas; mantiene la regla de negocio fuera de la interfaz.
class CountNegativeRatingsUseCase {
  final InteractionRepository repository;

  CountNegativeRatingsUseCase(this.repository);

  Future<int> execute(String promotionCode) {
    return repository.countNegativeRatings(promotionCode);
  }
}

/// Caso de uso para agregar una valoracion; mantiene la regla de negocio fuera de la interfaz.
class AddValoracionUseCase {
  final InteractionRepository repository;

  AddValoracionUseCase(this.repository);

  Future<void> execute(Valoracion valoracion) {
    return repository.addValoracion(valoracion);
  }
}

/// Caso de uso para eliminar una valoracion; mantiene la regla de negocio fuera de la interfaz.
class DeleteValoracionUseCase {
  final InteractionRepository repository;

  DeleteValoracionUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deleteValoracion(id);
  }
}
