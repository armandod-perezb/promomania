import 'package:app/features/promotions/domain/entities/promocion.dart';
import 'package:app/features/promotions/domain/repositories/promotion_repository.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart';

class PromotionServiceRepositoryAdapter implements PromotionRepository {
  final PromoService promoService;

  PromotionServiceRepositoryAdapter(this.promoService);

  @override
  Future<Promocion> createPromotion(Promocion promocion) async {
    promoService.addPromocion(promocion);
    return promocion;
  }

  @override
  Future<Promocion?> getPromotionByCode(String codigo) async {
    return promoService.getPromocionByCodigo(codigo);
  }

  @override
  Future<List<Promocion>> getActivePromotions({
    int? categoryId,
    int? supermarketId,
    int? page,
    int? pageSize,
  }) async {
    Iterable<Promocion> result = promoService.getPromocionesAprobadas();
    if (categoryId != null) {
      result = result.where((p) => p.idCategoria == categoryId);
    }
    if (supermarketId != null) {
      result = result.where((p) => p.idSupermercado == supermarketId);
    }

    final list = result.toList();
    if (page == null || pageSize == null || pageSize <= 0) {
      return list;
    }

    final start = (page - 1) * pageSize;
    if (start < 0 || start >= list.length) {
      return <Promocion>[];
    }
    final end = (start + pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  @override
  Future<List<Promocion>> getPromotionsByCategory(int categoryId) async {
    return promoService.getPromocionesByCategoria(categoryId);
  }

  @override
  Future<List<Promocion>> getPromotionsBySupermarket(int supermarketId) async {
    return promoService.getPromocionesBySupermercado(supermarketId);
  }

  @override
  Future<Promocion> updatePromotion(Promocion promocion) async {
    promoService.updatePromocion(promocion);
    return promocion;
  }

  @override
  Future<void> approvePromotion(String codigo) async {
    final promo = promoService.getPromocionByCodigo(codigo);
    if (promo != null) {
      promoService.updatePromocion(promo.copyWith(estado: 'aprobada'));
    }
  }

  @override
  Future<void> rejectPromotion(String codigo) async {
    final promo = promoService.getPromocionByCodigo(codigo);
    if (promo != null) {
      promoService.updatePromocion(promo.copyWith(estado: 'rechazada'));
    }
  }

  @override
  Future<void> deletePromotion(String codigo) async {
    promoService.deletePromocion(codigo);
  }

  @override
  Future<void> incrementViews(String codigo) async {
    promoService.incrementarVistas(codigo);
  }

  @override
  Future<List<Promocion>> getPromotionsByUser(int userId) async {
    return promoService.getPromocionesById(userId);
  }
}
