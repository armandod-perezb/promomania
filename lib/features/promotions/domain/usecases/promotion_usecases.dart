import 'package:app/features/promotions/domain/repositories/promotion_repository.dart';
import 'package:app/features/promotions/domain/entities/promocion.dart';

class InitializePromotionsUseCase {
  final Future<void> Function() initData;

  InitializePromotionsUseCase({required this.initData});

  Future<void> execute() => initData();
}

class LoadLocalPromotionsUseCase {
  final Future<void> Function() loadLocal;

  LoadLocalPromotionsUseCase({required this.loadLocal});

  Future<void> execute() => loadLocal();
}

class GetActivePromotionsUseCase {
  final PromotionRepository repository;

  GetActivePromotionsUseCase(this.repository);

  Future<List<Promocion>> execute({
    int? categoryId,
    int? supermarketId,
    int? page,
    int? pageSize,
  }) {
    return repository.getActivePromotions(
      categoryId: categoryId,
      supermarketId: supermarketId,
      page: page,
      pageSize: pageSize,
    );
  }
}

class GetPromotionByCodeUseCase {
  final PromotionRepository repository;

  GetPromotionByCodeUseCase(this.repository);

  Future<Promocion?> execute(String codigo) {
    return repository.getPromotionByCode(codigo);
  }
}

class CreatePromotionUseCase {
  final PromotionRepository repository;

  CreatePromotionUseCase(this.repository);

  Future<Promocion> execute(Promocion promocion) {
    return repository.createPromotion(promocion);
  }
}

class UpdatePromotionUseCase {
  final PromotionRepository repository;

  UpdatePromotionUseCase(this.repository);

  Future<Promocion> execute(Promocion promocion) {
    return repository.updatePromotion(promocion);
  }
}

class DeletePromotionUseCase {
  final PromotionRepository repository;

  DeletePromotionUseCase(this.repository);

  Future<void> execute(String codigo) {
    return repository.deletePromotion(codigo);
  }
}

class IncrementPromotionViewsUseCase {
  final PromotionRepository repository;

  IncrementPromotionViewsUseCase(this.repository);

  Future<void> execute(String codigo) {
    return repository.incrementViews(codigo);
  }
}

class GetPromotionsByUserUseCase {
  final PromotionRepository repository;

  GetPromotionsByUserUseCase(this.repository);

  Future<List<Promocion>> execute(int userId) {
    return repository.getPromotionsByUser(userId);
  }
}

class ApprovePromotionUseCase {
  final PromotionRepository repository;

  ApprovePromotionUseCase(this.repository);

  Future<void> execute(String codigo) {
    return repository.approvePromotion(codigo);
  }
}

class RejectPromotionUseCase {
  final PromotionRepository repository;

  RejectPromotionUseCase(this.repository);

  Future<void> execute(String codigo) {
    return repository.rejectPromotion(codigo);
  }
}

class GetPromotionsByCategoryUseCase {
  final PromotionRepository repository;

  GetPromotionsByCategoryUseCase(this.repository);

  Future<List<Promocion>> execute(int categoryId) {
    return repository.getPromotionsByCategory(categoryId);
  }
}

class GetPromotionsBySupermarketUseCase {
  final PromotionRepository repository;

  GetPromotionsBySupermarketUseCase(this.repository);

  Future<List<Promocion>> execute(int supermarketId) {
    return repository.getPromotionsBySupermarket(supermarketId);
  }
}
