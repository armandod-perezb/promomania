import 'package:app/features/promotions/domain/repositories/promotion_repository.dart';
import 'package:app/features/promotions/infrastructure/datasources/promo_local_datasource.dart';
import 'package:app/features/promotions/domain/entities/promocion.dart';

class PromotionRepositoryImpl implements PromotionRepository {
  final PromoLocalDataSource dataSource;

  PromotionRepositoryImpl(this.dataSource);

  @override
  Future<Promocion> createPromotion(Promocion promocion) async {
    dataSource.addPromocion(promocion);
    await dataSource.saveLocalData();
    return promocion;
  }

  @override
  Future<void> deletePromotion(String codigo) async {
    dataSource.deletePromocion(codigo);
    await dataSource.saveLocalData();
  }

  @override
  Future<List<Promocion>> getActivePromotions({
    int? categoryId,
    int? supermarketId,
    int? page,
    int? pageSize,
  }) async {
    var list = dataSource.getPromocionesAprobadas();

    if (categoryId != null) {
      list = list.where((p) => p.idCategoria == categoryId).toList();
    }

    if (supermarketId != null) {
      list = list.where((p) => p.idSupermercado == supermarketId).toList();
    }

    if (page != null && pageSize != null && page > 0 && pageSize > 0) {
      final start = (page - 1) * pageSize;
      if (start >= list.length) return [];
      final end = (start + pageSize).clamp(0, list.length);
      return list.sublist(start, end);
    }

    return list;
  }

  @override
  Future<Promocion?> getPromotionByCode(String codigo) async {
    return dataSource.getPromocionByCodigo(codigo);
  }

  @override
  Future<List<Promocion>> getPromotionsByCategory(int categoryId) async {
    return dataSource.getPromocionesByCategoria(categoryId);
  }

  @override
  Future<List<Promocion>> getPromotionsBySupermarket(int supermarketId) async {
    return dataSource.getPromocionesBySupermercado(supermarketId);
  }

  @override
  Future<List<Promocion>> getPromotionsByUser(int userId) async {
    return dataSource.getPromocionesById(userId);
  }

  @override
  Future<void> incrementViews(String codigo) async {
    dataSource.incrementarVistas(codigo);
    await dataSource.saveLocalData();
  }

  @override
  Future<void> approvePromotion(String codigo) async {
    final promo = dataSource.getPromocionByCodigo(codigo);
    if (promo == null) return;
    dataSource.updatePromocion(promo.copyWith(estado: 'aprobada'));
    await dataSource.saveLocalData();
  }

  @override
  Future<void> rejectPromotion(String codigo) async {
    final promo = dataSource.getPromocionByCodigo(codigo);
    if (promo == null) return;
    dataSource.updatePromocion(promo.copyWith(estado: 'rechazada'));
    await dataSource.saveLocalData();
  }

  @override
  Future<Promocion> updatePromotion(Promocion promocion) async {
    dataSource.updatePromocion(promocion);
    await dataSource.saveLocalData();
    return promocion;
  }
}
