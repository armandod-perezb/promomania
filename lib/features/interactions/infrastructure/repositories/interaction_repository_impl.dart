import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/interactions/domain/entities/favorito.dart';
import 'package:app/features/interactions/domain/entities/valoracion.dart';
import 'package:app/features/interactions/domain/repositories/interaction_repository.dart';
import 'package:app/features/interactions/infrastructure/datasources/interaction_datasource.dart';
import 'package:app/features/interactions/infrastructure/datasources/remote_favorite_datasource.dart';

/// Implementacion del repositorio de favoritos y valoraciones; adapta fuentes de datos remotas/locales al contrato de dominio.
class InteractionRepositoryImpl implements InteractionRepository {
  final InteractionDataSource dataSource;
  final RemoteFavoriteDataSource? remoteFavoriteDataSource;

  InteractionRepositoryImpl(this.dataSource, {this.remoteFavoriteDataSource});

  @override
  List<Favorito> getFavoritosByUsuarioSync(int userId) =>
      dataSource.getFavoritosByUsuario(userId);

  @override
  bool isFavoritoSync(int userId, String promotionCode) =>
      dataSource.isFavorito(userId, promotionCode);

  @override
  List<Valoracion> getValoracionesByPromocionSync(String promotionCode) =>
      dataSource.getValoracionesByPromocion(promotionCode);

  @override
  List<Valoracion> getAllValoracionesSync() => dataSource.getAllValoraciones();

  @override
  Future<List<Favorito>> getFavoritosByUsuario(int userId) async {
    if (remoteFavoriteDataSource != null) {
      try {
        final remoteFavoritos = await remoteFavoriteDataSource!
            .getFavoritosByUsuario(userId);

        final localFavoritos = dataSource.getFavoritosByUsuario(userId);
        for (final local in localFavoritos) {
          dataSource.removeFavorito(local.idUsuario, local.codigoPromocion);
        }
        for (final remote in remoteFavoritos) {
          dataSource.addFavorito(remote);
        }

        return remoteFavoritos;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }

    return dataSource.getFavoritosByUsuario(userId);
  }

  @override
  Future<bool> isFavorito(int userId, String promotionCode) async {
    if (remoteFavoriteDataSource != null) {
      try {
        final favorito = await remoteFavoriteDataSource!.findFavorito(
          userId,
          promotionCode,
        );
        if (favorito != null &&
            dataSource.getFavorito(userId, promotionCode) == null) {
          dataSource.addFavorito(favorito);
        }
        return favorito != null;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }

    return dataSource.isFavorito(userId, promotionCode);
  }

  @override
  Future<void> toggleFavorito(int userId, String promotionCode) async {
    if (remoteFavoriteDataSource != null) {
      try {
        final existing = await remoteFavoriteDataSource!.findFavorito(
          userId,
          promotionCode,
        );
        if (existing != null) {
          await remoteFavoriteDataSource!.deleteFavorito(existing.id);
          dataSource.removeFavorito(userId, promotionCode);
          return;
        }

        final created = await remoteFavoriteDataSource!.addFavorito(
          userId,
          promotionCode,
        );
        dataSource.addFavorito(created);
        return;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }

    dataSource.toggleFavorito(userId, promotionCode);
  }

  @override
  Future<List<Valoracion>> getValoracionesByPromocion(
    String promotionCode,
  ) async => remoteFavoriteDataSource != null
      ? await (() async {
          try {
            return await remoteFavoriteDataSource!.getValoracionesByPromocion(
              promotionCode,
            );
          } catch (e) {
            if (!_shouldFallbackToLocal(e)) rethrow;
            return dataSource.getValoracionesByPromocion(promotionCode);
          }
        })()
      : dataSource.getValoracionesByPromocion(promotionCode);

  @override
  Future<int> countPositiveRatings(String promotionCode) async {
    final valores = await getValoracionesByPromocion(promotionCode);
    return valores.where((v) => v.tipo == 'positiva').length;
  }

  @override
  Future<int> countNegativeRatings(String promotionCode) async {
    final valores = await getValoracionesByPromocion(promotionCode);
    return valores.where((v) => v.tipo == 'negativa').length;
  }

  @override
  Future<void> addValoracion(Valoracion valoracion) async {
    if (remoteFavoriteDataSource != null) {
      try {
        final created = await remoteFavoriteDataSource!.addValoracion(
          valoracion,
        );
        dataSource.addValoracion(created);
        return;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    dataSource.addValoracion(valoracion);
  }

  @override
  Future<void> deleteValoracion(int id) async {
    if (remoteFavoriteDataSource != null) {
      try {
        await remoteFavoriteDataSource!.deleteValoracion(id);
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    dataSource.deleteValoracion(id);
  }

  bool _shouldFallbackToLocal(Object error) {
    return error is NetworkException;
  }
}
