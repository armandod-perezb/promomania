import 'dart:typed_data';
import 'package:app/features/promotions/domain/repositories/promotion_repository.dart';
import 'package:app/features/promotions/domain/entities/promocion.dart';
import 'package:app/features/promotions/domain/entities/promocion_horario.dart';
import 'package:app/features/promotions/domain/entities/supermercado.dart';

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

// ── Sync query use cases ──────────────────────────────────────────────────────

class GetActivePromotionsSyncUseCase {
  final PromotionRepository repository;
  GetActivePromotionsSyncUseCase(this.repository);
  List<Promocion> execute({int? categoryId, int? supermarketId}) =>
      repository.getActivePromotionsSync(
        categoryId: categoryId,
        supermarketId: supermarketId,
      );
}

class GetAllPromotionsSyncUseCase {
  final PromotionRepository repository;
  GetAllPromotionsSyncUseCase(this.repository);
  List<Promocion> execute() => repository.getAllPromotionsSync();
}

class GetPromotionByCodeSyncUseCase {
  final PromotionRepository repository;
  GetPromotionByCodeSyncUseCase(this.repository);
  Promocion? execute(String codigo) =>
      repository.getPromotionByCodeSync(codigo);
}

class GetFlashDealsSyncUseCase {
  final PromotionRepository repository;
  GetFlashDealsSyncUseCase(this.repository);
  List<Promocion> execute({int limit = 5}) =>
      repository.getFlashDealsSync(limit: limit);
}

class GetNearbyStoresSyncUseCase {
  final PromotionRepository repository;
  GetNearbyStoresSyncUseCase(this.repository);
  List<Map<String, dynamic>> execute({int limit = 5}) =>
      repository.getNearbyStoresSync(limit: limit);
}

class GetPromocionUrgencyUseCase {
  final PromotionRepository repository;
  GetPromocionUrgencyUseCase(this.repository);
  String execute(Promocion promo) => repository.getPromocionUrgency(promo);
}

class GetPromocionesByUrgencySyncUseCase {
  final PromotionRepository repository;
  GetPromocionesByUrgencySyncUseCase(this.repository);
  Map<String, List<Promocion>> execute(int userId) =>
      repository.getPromocionesByUrgencySync(userId);
}

class GetPromocionRatingSyncUseCase {
  final PromotionRepository repository;
  GetPromocionRatingSyncUseCase(this.repository);
  double execute(String codigo) => repository.getPromocionRatingSync(codigo);
}

class GetPrecioConDescuentoUseCase {
  final PromotionRepository repository;
  GetPrecioConDescuentoUseCase(this.repository);
  double execute(Promocion promo) => repository.getPrecioConDescuento(promo);
}

class GetPromocionesHorariosByCodigoUseCase {
  final PromotionRepository repository;
  GetPromocionesHorariosByCodigoUseCase(this.repository);
  List<PromocionHorario> execute(String codigo) =>
      repository.getPromocionesHorariosByCodigoSync(codigo);
}

class GetNextHorarioIdUseCase {
  final PromotionRepository repository;
  GetNextHorarioIdUseCase(this.repository);
  int execute() => repository.getNextHorarioIdSync();
}

class GetSupermercadoSyncUseCase {
  final PromotionRepository repository;
  GetSupermercadoSyncUseCase(this.repository);
  Supermercado? execute(int id) => repository.getSupermercadoSync(id);
}

class GetSupermercadosSyncUseCase {
  final PromotionRepository repository;
  GetSupermercadosSyncUseCase(this.repository);
  List<Supermercado> execute() => repository.getSupermercadosSync();
}

class GetCachedImageBytesUseCase {
  final PromotionRepository repository;
  GetCachedImageBytesUseCase(this.repository);
  Uint8List? execute(String codigo) => repository.getCachedImageBytes(codigo);
}

// ── Async command use cases ───────────────────────────────────────────────────

class AddPromocionHorarioUseCase {
  final PromotionRepository repository;
  AddPromocionHorarioUseCase(this.repository);
  Future<void> execute(PromocionHorario horario) =>
      repository.addPromocionHorario(horario);
}

class SavePromotionImageUseCase {
  final PromotionRepository repository;
  SavePromotionImageUseCase(this.repository);
  Future<String?> execute(String codigo, Uint8List bytes) =>
      repository.savePromotionImage(codigo, bytes);
}

class GetPromotionImageBytesUseCase {
  final PromotionRepository repository;
  GetPromotionImageBytesUseCase(this.repository);
  Future<Uint8List?> execute(String codigo) =>
      repository.getPromotionImageBytes(codigo);
}

class AddSupermercadoUseCase {
  final PromotionRepository repository;
  AddSupermercadoUseCase(this.repository);
  Future<void> execute(Supermercado supermercado) =>
      repository.addSupermercado(supermercado);
}

class CreateSupermercadoUseCase {
  final PromotionRepository repository;
  CreateSupermercadoUseCase(this.repository);
  Future<Supermercado> execute(Supermercado supermercado) =>
      repository.createSupermercado(supermercado);
}

class UpdateSupermercadoUseCase {
  final PromotionRepository repository;
  UpdateSupermercadoUseCase(this.repository);
  Future<void> execute(Supermercado supermercado) =>
      repository.updateSupermercado(supermercado);
}

class DeleteSupermercadoUseCase {
  final PromotionRepository repository;
  DeleteSupermercadoUseCase(this.repository);
  Future<void> execute(int id) => repository.deleteSupermercado(id);
}

class ReinitializePromotionsUseCase {
  final PromotionRepository repository;
  ReinitializePromotionsUseCase(this.repository);
  Future<void> execute() => repository.reinitialize();
}

class IsLoadedUseCase {
  final PromotionRepository repository;
  IsLoadedUseCase(this.repository);
  bool execute() => repository.isLoaded;
}

class GetLoadErrorUseCase {
  final PromotionRepository repository;
  GetLoadErrorUseCase(this.repository);
  String? execute() => repository.loadError;
}
