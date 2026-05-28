import 'dart:typed_data';
import 'package:app/features/promotions/domain/entities/promocion.dart';
import 'package:app/features/promotions/domain/entities/promocion_horario.dart';
import 'package:app/features/promotions/domain/entities/supermercado.dart';
import 'package:app/features/promotions/domain/usecases/promotion_usecases.dart';

/// Controlador de la capa de presentacion para el feature de promociones.
/// Expone unicamente use cases — nunca depende de infraestructura directamente.
class PromotionsController {
  // Async commands
  final GetActivePromotionsUseCase _getActivePromotions;
  final GetPromotionByCodeUseCase _getPromotionByCode;
  final CreatePromotionUseCase _createPromotion;
  final UpdatePromotionUseCase _updatePromotion;
  final DeletePromotionUseCase _deletePromotion;
  final IncrementPromotionViewsUseCase _incrementViews;
  final GetPromotionsByUserUseCase _getPromotionsByUser;
  final ApprovePromotionUseCase _approvePromotion;
  final RejectPromotionUseCase _rejectPromotion;
  final GetPromotionsByCategoryUseCase _getPromotionsByCategory;
  final GetPromotionsBySupermarketUseCase _getPromotionsBySupermarket;
  final AddPromocionHorarioUseCase _addPromocionHorario;
  final SavePromotionImageUseCase _savePromotionImage;
  final GetPromotionImageBytesUseCase _getPromotionImageBytes;
  final AddSupermercadoUseCase _addSupermercado;
  final UpdateSupermercadoUseCase _updateSupermercado;
  final DeleteSupermercadoUseCase _deleteSupermercado;
  final ReinitializePromotionsUseCase _reinitialize;
  final IsLoadedUseCase _isLoaded;
  final GetLoadErrorUseCase _getLoadError;

  // Sync queries
  final GetActivePromotionsSyncUseCase _getActivePromotionsSync;
  final GetAllPromotionsSyncUseCase _getAllPromotionsSync;
  final GetPromotionByCodeSyncUseCase _getPromotionByCodeSync;
  final GetFlashDealsSyncUseCase _getFlashDealsSync;
  final GetNearbyStoresSyncUseCase _getNearbyStoresSync;
  final GetPromocionUrgencyUseCase _getPromocionUrgency;
  final GetPromocionesByUrgencySyncUseCase _getPromocionesByUrgencySync;
  final GetPromocionRatingSyncUseCase _getPromocionRatingSync;
  final GetPrecioConDescuentoUseCase _getPrecioConDescuento;
  final GetPromocionesHorariosByCodigoUseCase _getHorariosByCodigo;
  final GetNextHorarioIdUseCase _getNextHorarioId;
  final GetSupermercadoSyncUseCase _getSupermercadoSync;
  final GetSupermercadosSyncUseCase _getSupermercadosSync;
  final GetCachedImageBytesUseCase _getCachedImageBytes;

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
    required AddPromocionHorarioUseCase addPromocionHorarioUseCase,
    required SavePromotionImageUseCase savePromotionImageUseCase,
    required GetPromotionImageBytesUseCase getPromotionImageBytesUseCase,
    required AddSupermercadoUseCase addSupermercadoUseCase,
    required UpdateSupermercadoUseCase updateSupermercadoUseCase,
    required DeleteSupermercadoUseCase deleteSupermercadoUseCase,
    required ReinitializePromotionsUseCase reinitializeUseCase,
    required IsLoadedUseCase isLoadedUseCase,
    required GetLoadErrorUseCase getLoadErrorUseCase,
    required GetActivePromotionsSyncUseCase getActivePromotionsSyncUseCase,
    required GetAllPromotionsSyncUseCase getAllPromotionsSyncUseCase,
    required GetPromotionByCodeSyncUseCase getPromotionByCodeSyncUseCase,
    required GetFlashDealsSyncUseCase getFlashDealsSyncUseCase,
    required GetNearbyStoresSyncUseCase getNearbyStoresSyncUseCase,
    required GetPromocionUrgencyUseCase getPromocionUrgencyUseCase,
    required GetPromocionesByUrgencySyncUseCase getPromocionesByUrgencySyncUseCase,
    required GetPromocionRatingSyncUseCase getPromocionRatingSyncUseCase,
    required GetPrecioConDescuentoUseCase getPrecioConDescuentoUseCase,
    required GetPromocionesHorariosByCodigoUseCase getHorariosByCodigoUseCase,
    required GetNextHorarioIdUseCase getNextHorarioIdUseCase,
    required GetSupermercadoSyncUseCase getSupermercadoSyncUseCase,
    required GetSupermercadosSyncUseCase getSupermercadosSyncUseCase,
    required GetCachedImageBytesUseCase getCachedImageBytesUseCase,
  })  : _getActivePromotions = getActivePromotionsUseCase,
        _getPromotionByCode = getPromotionByCodeUseCase,
        _createPromotion = createPromotionUseCase,
        _updatePromotion = updatePromotionUseCase,
        _deletePromotion = deletePromotionUseCase,
        _incrementViews = incrementPromotionViewsUseCase,
        _getPromotionsByUser = getPromotionsByUserUseCase,
        _approvePromotion = approvePromotionUseCase,
        _rejectPromotion = rejectPromotionUseCase,
        _getPromotionsByCategory = getPromotionsByCategoryUseCase,
        _getPromotionsBySupermarket = getPromotionsBySupermarketUseCase,
        _addPromocionHorario = addPromocionHorarioUseCase,
        _savePromotionImage = savePromotionImageUseCase,
        _getPromotionImageBytes = getPromotionImageBytesUseCase,
        _addSupermercado = addSupermercadoUseCase,
        _updateSupermercado = updateSupermercadoUseCase,
        _deleteSupermercado = deleteSupermercadoUseCase,
        _reinitialize = reinitializeUseCase,
        _isLoaded = isLoadedUseCase,
        _getLoadError = getLoadErrorUseCase,
        _getActivePromotionsSync = getActivePromotionsSyncUseCase,
        _getAllPromotionsSync = getAllPromotionsSyncUseCase,
        _getPromotionByCodeSync = getPromotionByCodeSyncUseCase,
        _getFlashDealsSync = getFlashDealsSyncUseCase,
        _getNearbyStoresSync = getNearbyStoresSyncUseCase,
        _getPromocionUrgency = getPromocionUrgencyUseCase,
        _getPromocionesByUrgencySync = getPromocionesByUrgencySyncUseCase,
        _getPromocionRatingSync = getPromocionRatingSyncUseCase,
        _getPrecioConDescuento = getPrecioConDescuentoUseCase,
        _getHorariosByCodigo = getHorariosByCodigoUseCase,
        _getNextHorarioId = getNextHorarioIdUseCase,
        _getSupermercadoSync = getSupermercadoSyncUseCase,
        _getSupermercadosSync = getSupermercadosSyncUseCase,
        _getCachedImageBytes = getCachedImageBytesUseCase;

  // ── State getters ────────────────────────────────────────────────────────
  bool get isLoaded => _isLoaded.execute();
  String? get loadError => _getLoadError.execute();

  // ── Async commands ────────────────────────────────────────────────────────

  Future<List<Promocion>> getActivePromotions({int? categoryId, int? supermarketId, int? page, int? pageSize}) =>
      _getActivePromotions.execute(categoryId: categoryId, supermarketId: supermarketId, page: page, pageSize: pageSize);

  Future<Promocion?> getPromotionByCode(String codigo) => _getPromotionByCode.execute(codigo);
  Future<Promocion> createPromotion(Promocion promocion) => _createPromotion.execute(promocion);
  Future<Promocion> updatePromotion(Promocion promocion) => _updatePromotion.execute(promocion);
  Future<void> deletePromotion(String codigo) => _deletePromotion.execute(codigo);
  Future<void> incrementViews(String codigo) => _incrementViews.execute(codigo);
  Future<List<Promocion>> getPromotionsByUser(int userId) => _getPromotionsByUser.execute(userId);
  Future<void> approvePromotion(String codigo) => _approvePromotion.execute(codigo);
  Future<void> rejectPromotion(String codigo) => _rejectPromotion.execute(codigo);
  Future<List<Promocion>> getPromotionsByCategory(int categoryId) => _getPromotionsByCategory.execute(categoryId);
  Future<List<Promocion>> getPromotionsBySupermarket(int supermarketId) => _getPromotionsBySupermarket.execute(supermarketId);
  Future<void> addPromocionHorario(PromocionHorario horario) => _addPromocionHorario.execute(horario);
  Future<String?> savePromotionImage(String codigo, Uint8List bytes) => _savePromotionImage.execute(codigo, bytes);
  Future<Uint8List?> getPromotionImageBytes(String codigo) => _getPromotionImageBytes.execute(codigo);
  Future<void> addSupermercado(Supermercado supermercado) => _addSupermercado.execute(supermercado);
  Future<void> updateSupermercado(Supermercado supermercado) => _updateSupermercado.execute(supermercado);
  Future<void> deleteSupermercado(int id) => _deleteSupermercado.execute(id);
  Future<void> reinitialize() => _reinitialize.execute();

  // ── Sync queries ──────────────────────────────────────────────────────────

  List<Promocion> getActivePromotionsSync({int? categoryId, int? supermarketId}) =>
      _getActivePromotionsSync.execute(categoryId: categoryId, supermarketId: supermarketId);
  List<Promocion> getAllPromotionsSync() => _getAllPromotionsSync.execute();
  Promocion? getPromotionByCodeSync(String codigo) => _getPromotionByCodeSync.execute(codigo);
  List<Promocion> getFlashDealsSync({int limit = 5}) => _getFlashDealsSync.execute(limit: limit);
  List<Map<String, dynamic>> getNearbyStoresSync({int limit = 5}) => _getNearbyStoresSync.execute(limit: limit);
  String getPromocionUrgency(Promocion promo) => _getPromocionUrgency.execute(promo);
  Map<String, List<Promocion>> getPromocionesByUrgencySync(int userId) => _getPromocionesByUrgencySync.execute(userId);
  double getPromocionRatingSync(String codigo) => _getPromocionRatingSync.execute(codigo);
  double getPrecioConDescuento(Promocion promo) => _getPrecioConDescuento.execute(promo);
  List<PromocionHorario> getPromocionesHorariosByCodigo(String codigo) => _getHorariosByCodigo.execute(codigo);
  int getNextHorarioId() => _getNextHorarioId.execute();
  Supermercado? getSupermercadoSync(int id) => _getSupermercadoSync.execute(id);
  List<Supermercado> getSupermercadosSync() => _getSupermercadosSync.execute();
  Uint8List? getCachedImageBytes(String codigo) => _getCachedImageBytes.execute(codigo);
}
