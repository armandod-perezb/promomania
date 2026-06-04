import 'dart:typed_data';
import 'package:app/features/promotions/domain/repositories/promotion_repository.dart';
import 'package:app/features/promotions/domain/entities/promocion.dart';
import 'package:app/features/promotions/domain/entities/promocion_horario.dart';
import 'package:app/features/promotions/domain/entities/supermercado.dart';

/// Caso de uso para inicializar promociones; mantiene la regla de negocio fuera de la interfaz.
class InitializePromotionsUseCase {
  final Future<void> Function() initData;

  InitializePromotionsUseCase({required this.initData});

  Future<void> execute() => initData();
}

/// Caso de uso para cargar promociones locales; mantiene la regla de negocio fuera de la interfaz.
class LoadLocalPromotionsUseCase {
  final Future<void> Function() loadLocal;

  LoadLocalPromotionsUseCase({required this.loadLocal});

  Future<void> execute() => loadLocal();
}

/// Caso de uso para obtener promociones activas; mantiene la regla de negocio fuera de la interfaz.
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

/// Caso de uso para buscar una promocion por codigo; mantiene la regla de negocio fuera de la interfaz.
class GetPromotionByCodeUseCase {
  final PromotionRepository repository;

  GetPromotionByCodeUseCase(this.repository);

  Future<Promocion?> execute(String codigo) {
    return repository.getPromotionByCode(codigo);
  }
}

/// Caso de uso para crear una promocion; mantiene la regla de negocio fuera de la interfaz.
class CreatePromotionUseCase {
  final PromotionRepository repository;

  CreatePromotionUseCase(this.repository);

  Future<Promocion> execute(Promocion promocion) {
    return repository.createPromotion(promocion);
  }
}

/// Caso de uso para actualizar una promocion; mantiene la regla de negocio fuera de la interfaz.
class UpdatePromotionUseCase {
  final PromotionRepository repository;

  UpdatePromotionUseCase(this.repository);

  Future<Promocion> execute(Promocion promocion) {
    return repository.updatePromotion(promocion);
  }
}

/// Caso de uso para eliminar una promocion; mantiene la regla de negocio fuera de la interfaz.
class DeletePromotionUseCase {
  final PromotionRepository repository;

  DeletePromotionUseCase(this.repository);

  Future<void> execute(String codigo) {
    return repository.deletePromotion(codigo);
  }
}

/// Caso de uso para registrar vistas de una promocion; mantiene la regla de negocio fuera de la interfaz.
class IncrementPromotionViewsUseCase {
  final PromotionRepository repository;

  IncrementPromotionViewsUseCase(this.repository);

  Future<void> execute(String codigo) {
    return repository.incrementViews(codigo);
  }
}

/// Caso de uso para obtener promociones publicadas por un usuario; mantiene la regla de negocio fuera de la interfaz.
class GetPromotionsByUserUseCase {
  final PromotionRepository repository;

  GetPromotionsByUserUseCase(this.repository);

  Future<List<Promocion>> execute(int userId) {
    return repository.getPromotionsByUser(userId);
  }
}

/// Caso de uso para aprobar una promocion; mantiene la regla de negocio fuera de la interfaz.
class ApprovePromotionUseCase {
  final PromotionRepository repository;

  ApprovePromotionUseCase(this.repository);

  Future<void> execute(String codigo) {
    return repository.approvePromotion(codigo);
  }
}

/// Caso de uso para rechazar una promocion; mantiene la regla de negocio fuera de la interfaz.
class RejectPromotionUseCase {
  final PromotionRepository repository;

  RejectPromotionUseCase(this.repository);

  Future<void> execute(String codigo) {
    return repository.rejectPromotion(codigo);
  }
}

/// Caso de uso para obtener promociones por categoria; mantiene la regla de negocio fuera de la interfaz.
class GetPromotionsByCategoryUseCase {
  final PromotionRepository repository;

  GetPromotionsByCategoryUseCase(this.repository);

  Future<List<Promocion>> execute(int categoryId) {
    return repository.getPromotionsByCategory(categoryId);
  }
}

/// Caso de uso para obtener promociones por supermercado; mantiene la regla de negocio fuera de la interfaz.
class GetPromotionsBySupermarketUseCase {
  final PromotionRepository repository;

  GetPromotionsBySupermarketUseCase(this.repository);

  Future<List<Promocion>> execute(int supermarketId) {
    return repository.getPromotionsBySupermarket(supermarketId);
  }
}

// ── Sync query use cases ──────────────────────────────────────────────────────

/// Caso de uso para obtener promociones activas desde cache local; mantiene la regla de negocio fuera de la interfaz.
class GetActivePromotionsSyncUseCase {
  final PromotionRepository repository;
  GetActivePromotionsSyncUseCase(this.repository);
  List<Promocion> execute({int? categoryId, int? supermarketId}) =>
      repository.getActivePromotionsSync(
        categoryId: categoryId,
        supermarketId: supermarketId,
      );
}

/// Caso de uso para obtener todas las promociones desde cache local; mantiene la regla de negocio fuera de la interfaz.
class GetAllPromotionsSyncUseCase {
  final PromotionRepository repository;
  GetAllPromotionsSyncUseCase(this.repository);
  List<Promocion> execute() => repository.getAllPromotionsSync();
}

/// Caso de uso para buscar una promocion por codigo en cache local; mantiene la regla de negocio fuera de la interfaz.
class GetPromotionByCodeSyncUseCase {
  final PromotionRepository repository;
  GetPromotionByCodeSyncUseCase(this.repository);
  Promocion? execute(String codigo) =>
      repository.getPromotionByCodeSync(codigo);
}

/// Caso de uso para obtener ofertas relampago desde cache local; mantiene la regla de negocio fuera de la interfaz.
class GetFlashDealsSyncUseCase {
  final PromotionRepository repository;
  GetFlashDealsSyncUseCase(this.repository);
  List<Promocion> execute({int limit = 5}) =>
      repository.getFlashDealsSync(limit: limit);
}

/// Caso de uso para obtener comercios cercanos desde cache local; mantiene la regla de negocio fuera de la interfaz.
class GetNearbyStoresSyncUseCase {
  final PromotionRepository repository;
  GetNearbyStoresSyncUseCase(this.repository);
  List<Map<String, dynamic>> execute({int limit = 5}) =>
      repository.getNearbyStoresSync(limit: limit);
}

/// Caso de uso para calcular la urgencia visual de una promocion; mantiene la regla de negocio fuera de la interfaz.
class GetPromocionUrgencyUseCase {
  final PromotionRepository repository;
  GetPromocionUrgencyUseCase(this.repository);
  String execute(Promocion promo) => repository.getPromocionUrgency(promo);
}

/// Caso de uso para agrupar promociones por urgencia desde cache local; mantiene la regla de negocio fuera de la interfaz.
class GetPromocionesByUrgencySyncUseCase {
  final PromotionRepository repository;
  GetPromocionesByUrgencySyncUseCase(this.repository);
  Map<String, List<Promocion>> execute(int userId) =>
      repository.getPromocionesByUrgencySync(userId);
}

/// Caso de uso para calcular la valoracion de una promocion desde cache local; mantiene la regla de negocio fuera de la interfaz.
class GetPromocionRatingSyncUseCase {
  final PromotionRepository repository;
  GetPromocionRatingSyncUseCase(this.repository);
  double execute(String codigo) => repository.getPromocionRatingSync(codigo);
}

/// Caso de uso para calcular el precio final con descuento; mantiene la regla de negocio fuera de la interfaz.
class GetPrecioConDescuentoUseCase {
  final PromotionRepository repository;
  GetPrecioConDescuentoUseCase(this.repository);
  double execute(Promocion promo) => repository.getPrecioConDescuento(promo);
}

/// Caso de uso para obtener horarios de una promocion por codigo; mantiene la regla de negocio fuera de la interfaz.
class GetPromocionesHorariosByCodigoUseCase {
  final PromotionRepository repository;
  GetPromocionesHorariosByCodigoUseCase(this.repository);
  List<PromocionHorario> execute(String codigo) =>
      repository.getPromocionesHorariosByCodigoSync(codigo);
}

/// Caso de uso para calcular el siguiente identificador de horario; mantiene la regla de negocio fuera de la interfaz.
class GetNextHorarioIdUseCase {
  final PromotionRepository repository;
  GetNextHorarioIdUseCase(this.repository);
  int execute() => repository.getNextHorarioIdSync();
}

/// Caso de uso para obtener un supermercado desde cache local; mantiene la regla de negocio fuera de la interfaz.
class GetSupermercadoSyncUseCase {
  final PromotionRepository repository;
  GetSupermercadoSyncUseCase(this.repository);
  Supermercado? execute(int id) => repository.getSupermercadoSync(id);
}

/// Caso de uso para obtener supermercados desde cache local; mantiene la regla de negocio fuera de la interfaz.
class GetSupermercadosSyncUseCase {
  final PromotionRepository repository;
  GetSupermercadosSyncUseCase(this.repository);
  List<Supermercado> execute() => repository.getSupermercadosSync();
}

/// Caso de uso para leer bytes de imagen ya cargados en memoria; mantiene la regla de negocio fuera de la interfaz.
class GetCachedImageBytesUseCase {
  final PromotionRepository repository;
  GetCachedImageBytesUseCase(this.repository);
  Uint8List? execute(String codigo) => repository.getCachedImageBytes(codigo);
}

// ── Async command use cases ───────────────────────────────────────────────────

/// Caso de uso para agregar un horario a una promocion; mantiene la regla de negocio fuera de la interfaz.
class AddPromocionHorarioUseCase {
  final PromotionRepository repository;
  AddPromocionHorarioUseCase(this.repository);
  Future<void> execute(PromocionHorario horario) =>
      repository.addPromocionHorario(horario);
}

/// Caso de uso para guardar la imagen de una promocion; mantiene la regla de negocio fuera de la interfaz.
class SavePromotionImageUseCase {
  final PromotionRepository repository;
  SavePromotionImageUseCase(this.repository);
  Future<String?> execute(String codigo, Uint8List bytes) =>
      repository.savePromotionImage(codigo, bytes);
}

/// Caso de uso para recuperar la imagen de una promocion; mantiene la regla de negocio fuera de la interfaz.
class GetPromotionImageBytesUseCase {
  final PromotionRepository repository;
  GetPromotionImageBytesUseCase(this.repository);
  Future<Uint8List?> execute(String codigo) =>
      repository.getPromotionImageBytes(codigo);
}

/// Caso de uso para agregar un supermercado; mantiene la regla de negocio fuera de la interfaz.
class AddSupermercadoUseCase {
  final PromotionRepository repository;
  AddSupermercadoUseCase(this.repository);
  Future<void> execute(Supermercado supermercado) =>
      repository.addSupermercado(supermercado);
}

/// Caso de uso para crear un supermercado; mantiene la regla de negocio fuera de la interfaz.
class CreateSupermercadoUseCase {
  final PromotionRepository repository;
  CreateSupermercadoUseCase(this.repository);
  Future<Supermercado> execute(Supermercado supermercado) =>
      repository.createSupermercado(supermercado);
}

/// Caso de uso para actualizar un supermercado; mantiene la regla de negocio fuera de la interfaz.
class UpdateSupermercadoUseCase {
  final PromotionRepository repository;
  UpdateSupermercadoUseCase(this.repository);
  Future<void> execute(Supermercado supermercado) =>
      repository.updateSupermercado(supermercado);
}

/// Caso de uso para eliminar un supermercado; mantiene la regla de negocio fuera de la interfaz.
class DeleteSupermercadoUseCase {
  final PromotionRepository repository;
  DeleteSupermercadoUseCase(this.repository);
  Future<void> execute(int id) => repository.deleteSupermercado(id);
}

/// Caso de uso para reinicializar la carga de promociones; mantiene la regla de negocio fuera de la interfaz.
class ReinitializePromotionsUseCase {
  final PromotionRepository repository;
  ReinitializePromotionsUseCase(this.repository);
  Future<void> execute() => repository.reinitialize();
}

/// Caso de uso para consultar si los datos principales ya estan cargados; mantiene la regla de negocio fuera de la interfaz.
class IsLoadedUseCase {
  final PromotionRepository repository;
  IsLoadedUseCase(this.repository);
  bool execute() => repository.isLoaded;
}

/// Caso de uso para consultar el ultimo error de carga; mantiene la regla de negocio fuera de la interfaz.
class GetLoadErrorUseCase {
  final PromotionRepository repository;
  GetLoadErrorUseCase(this.repository);
  String? execute() => repository.loadError;
}
