import 'package:app/features/interactions/domain/entities/favorito.dart';
import 'package:app/features/interactions/domain/entities/valoracion.dart';
import 'package:app/features/interactions/domain/repositories/interaction_repository.dart';
import 'package:app/features/interactions/infrastructure/datasources/interaction_datasource.dart';

class InteractionRepositoryImpl implements InteractionRepository {
  final InteractionDataSource dataSource;

  InteractionRepositoryImpl(this.dataSource);

  @override
  Future<List<Favorito>> getFavoritosByUsuario(int userId) async {
    return dataSource.getFavoritosByUsuario(userId);
  }

  @override
  Future<bool> isFavorito(int userId, String promotionCode) async {
    return dataSource.isFavorito(userId, promotionCode);
  }

  @override
  Future<void> toggleFavorito(int userId, String promotionCode) async {
    dataSource.toggleFavorito(userId, promotionCode);
  }

  @override
  Future<List<Valoracion>> getValoracionesByPromocion(String promotionCode) async {
    return dataSource.getValoracionesByPromocion(promotionCode);
  }

  @override
  Future<int> countPositiveRatings(String promotionCode) async {
    return dataSource.countPositiveRatings(promotionCode);
  }

  @override
  Future<int> countNegativeRatings(String promotionCode) async {
    return dataSource.countNegativeRatings(promotionCode);
  }

  @override
  Future<void> addValoracion(Valoracion valoracion) async {
    dataSource.addValoracion(valoracion);
  }

  @override
  Future<void> deleteValoracion(int id) async {
    dataSource.deleteValoracion(id);
  }
}
