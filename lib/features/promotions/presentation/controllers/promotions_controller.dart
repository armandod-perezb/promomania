import 'package:app/features/promotions/domain/entities/promocion.dart';
import 'package:app/features/promotions/domain/usecases/promotion_usecases.dart';

class PromotionsController {
  final GetActivePromotionsUseCase _getActivePromotionsUseCase;
  final GetPromotionByCodeUseCase _getPromotionByCodeUseCase;
  final CreatePromotionUseCase _createPromotionUseCase;
  final UpdatePromotionUseCase _updatePromotionUseCase;
  final DeletePromotionUseCase _deletePromotionUseCase;
  final IncrementPromotionViewsUseCase _incrementPromotionViewsUseCase;
  final GetPromotionsByUserUseCase _getPromotionsByUserUseCase;
  final ApprovePromotionUseCase _approvePromotionUseCase;
  final RejectPromotionUseCase _rejectPromotionUseCase;
  final GetPromotionsByCategoryUseCase _getPromotionsByCategoryUseCase;
  final GetPromotionsBySupermarketUseCase _getPromotionsBySupermarketUseCase;

  PromotionsController({
    required GetActivePromotionsUseCase getActivePromotionsUseCase,
    required GetPromotionByCodeUseCase getPromotionByCodeUseCase,
    required CreatePromotionUseCase createPromotionUseCase,
    required UpdatePromotionUseCase updatePromotionUseCase,
    required DeletePromotionUseCase deletePromotionUseCase,
    required IncrementPromotionViewsUseCase incrementPromotionViewsUseCase,
    required GetPromotionsByUserUseCase getPromotionsByUserUseCase,
    required ApprovePromotionUseCase approvePromotionUseCase,
    required RejectPromotionUseCase rejectPromotionUseCase,
    required GetPromotionsByCategoryUseCase getPromotionsByCategoryUseCase,
    required GetPromotionsBySupermarketUseCase getPromotionsBySupermarketUseCase,
  }) : _getActivePromotionsUseCase = getActivePromotionsUseCase,
       _getPromotionByCodeUseCase = getPromotionByCodeUseCase,
       _createPromotionUseCase = createPromotionUseCase,
       _updatePromotionUseCase = updatePromotionUseCase,
       _deletePromotionUseCase = deletePromotionUseCase,
       _incrementPromotionViewsUseCase = incrementPromotionViewsUseCase,
       _getPromotionsByUserUseCase = getPromotionsByUserUseCase,
       _approvePromotionUseCase = approvePromotionUseCase,
       _rejectPromotionUseCase = rejectPromotionUseCase,
       _getPromotionsByCategoryUseCase = getPromotionsByCategoryUseCase,
       _getPromotionsBySupermarketUseCase = getPromotionsBySupermarketUseCase;

  Future<List<Promocion>> getActivePromotions({
    int? categoryId,
    int? supermarketId,
    int? page,
    int? pageSize,
  }) {
    return _getActivePromotionsUseCase.execute(
      categoryId: categoryId,
      supermarketId: supermarketId,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<Promocion?> getPromotionByCode(String codigo) {
    return _getPromotionByCodeUseCase.execute(codigo);
  }

  Future<Promocion> createPromotion(Promocion promocion) {
    return _createPromotionUseCase.execute(promocion);
  }

  Future<Promocion> updatePromotion(Promocion promocion) {
    return _updatePromotionUseCase.execute(promocion);
  }

  Future<void> deletePromotion(String codigo) {
    return _deletePromotionUseCase.execute(codigo);
  }

  Future<void> incrementViews(String codigo) {
    return _incrementPromotionViewsUseCase.execute(codigo);
  }

  Future<List<Promocion>> getPromotionsByUser(int userId) {
    return _getPromotionsByUserUseCase.execute(userId);
  }

  Future<void> approvePromotion(String codigo) {
    return _approvePromotionUseCase.execute(codigo);
  }

  Future<void> rejectPromotion(String codigo) {
    return _rejectPromotionUseCase.execute(codigo);
  }

  Future<List<Promocion>> getPromotionsByCategory(int categoryId) {
    return _getPromotionsByCategoryUseCase.execute(categoryId);
  }

  Future<List<Promocion>> getPromotionsBySupermarket(int supermarketId) {
    return _getPromotionsBySupermarketUseCase.execute(supermarketId);
  }
}
