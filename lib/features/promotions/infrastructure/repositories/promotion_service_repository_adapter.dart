import 'dart:typed_data';
import 'package:app/features/promotions/domain/entities/promocion.dart';
import 'package:app/features/promotions/domain/entities/promocion_horario.dart';
import 'package:app/features/promotions/domain/entities/supermercado.dart';
import 'package:app/features/promotions/domain/repositories/promotion_repository.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart';

/// Adapter que implementa PromotionRepository delegando en PromoService.
/// Permite que PromotionsController use PromoService como fuente de datos
/// sin que la capa de presentacion conozca PromoService directamente.
class PromotionServiceRepositoryAdapter implements PromotionRepository {
  final PromoService promoService;

  PromotionServiceRepositoryAdapter(this.promoService);

  // ── Estado ────────────────────────────────────────────────────────────────

  @override
  bool get isLoaded => promoService.loaded;

  @override
  String? get loadError => promoService.loadError;

  @override
  Future<void> reinitialize() => promoService.init();

  // ── Sync queries ──────────────────────────────────────────────────────────

  @override
  List<Promocion> getActivePromotionsSync({int? categoryId, int? supermarketId}) {
    Iterable<Promocion> result = promoService.getPromocionesAprobadas();
    if (categoryId != null) result = result.where((p) => p.idCategoria == categoryId);
    if (supermarketId != null) result = result.where((p) => p.idSupermercado == supermarketId);
    return result.toList();
  }

  @override
  List<Promocion> getAllPromotionsSync() => promoService.getPromociones();

  @override
  Promocion? getPromotionByCodeSync(String codigo) => promoService.getPromocionByCodigo(codigo);

  @override
  List<Promocion> getPromotionsByUserSync(int userId) => promoService.getPromocionesById(userId);

  @override
  List<Promocion> getFlashDealsSync({int limit = 5}) => promoService.getFlashDeals(limit: limit);

  @override
  List<Map<String, dynamic>> getNearbyStoresSync({int limit = 5}) => promoService.getNearbyStores(limit: limit);

  @override
  String getPromocionUrgency(Promocion promo) => promoService.getPromocionUrgency(promo);

  @override
  Map<String, List<Promocion>> getPromocionesByUrgencySync(int userId) =>
      promoService.getPromocionesByUrgency(userId);

  @override
  double getPromocionRatingSync(String codigo) => promoService.getPromocionRating(codigo);

  @override
  double getPrecioConDescuento(Promocion promo) => promoService.getPrecioConDescuento(promo);

  @override
  List<PromocionHorario> getPromocionesHorariosByCodigoSync(String codigo) =>
      promoService.getPromocionesHorarios().where((h) => h.codigoPromocion == codigo).toList();

  @override
  int getNextHorarioIdSync() {
    final horarios = promoService.getPromocionesHorarios();
    return (horarios.isEmpty ? 0 : horarios.last.id) + 1;
  }

  @override
  Supermercado? getSupermercadoSync(int id) => promoService.getSupermercado(id);

  @override
  List<Supermercado> getSupermercadosSync() => promoService.getSupermercados();

  @override
  Uint8List? getCachedImageBytes(String codigo) => promoService.getImageBytes(codigo);

  // ── Async commands ────────────────────────────────────────────────────────

  @override
  Future<Promocion> createPromotion(Promocion promocion) async {
    promoService.addPromocion(promocion);
    return promocion;
  }

  @override
  Future<Promocion?> getPromotionByCode(String codigo) async =>
      promoService.getPromocionByCodigo(codigo);

  @override
  Future<List<Promocion>> getActivePromotions({
    int? categoryId,
    int? supermarketId,
    int? page,
    int? pageSize,
  }) async {
    var list = getActivePromotionsSync(categoryId: categoryId, supermarketId: supermarketId);
    if (page == null || pageSize == null || pageSize <= 0) return list;
    final start = (page - 1) * pageSize;
    if (start < 0 || start >= list.length) return [];
    return list.sublist(start, (start + pageSize).clamp(0, list.length));
  }

  @override
  Future<List<Promocion>> getPromotionsByCategory(int categoryId) async =>
      promoService.getPromocionesByCategoria(categoryId);

  @override
  Future<List<Promocion>> getPromotionsBySupermarket(int supermarketId) async =>
      promoService.getPromocionesBySupermercado(supermarketId);

  @override
  Future<List<Promocion>> getPromotionsByUser(int userId) async =>
      promoService.getPromocionesById(userId);

  @override
  Future<Promocion> updatePromotion(Promocion promocion) async {
    promoService.updatePromocion(promocion);
    return promocion;
  }

  @override
  Future<void> approvePromotion(String codigo) async {
    final promo = promoService.getPromocionByCodigo(codigo);
    if (promo != null) promoService.updatePromocion(promo.copyWith(estado: 'aprobada'));
  }

  @override
  Future<void> rejectPromotion(String codigo) async {
    final promo = promoService.getPromocionByCodigo(codigo);
    if (promo != null) promoService.updatePromocion(promo.copyWith(estado: 'rechazada'));
  }

  @override
  Future<void> deletePromotion(String codigo) async => promoService.deletePromocion(codigo);

  @override
  Future<void> incrementViews(String codigo) async => promoService.incrementarVistas(codigo);

  @override
  Future<void> addPromocionHorario(PromocionHorario horario) async =>
      promoService.addPromocionHorario(horario);

  @override
  Future<String?> savePromotionImage(String codigo, Uint8List bytes) =>
      promoService.savePromotionImage(codigo, bytes);

  @override
  Future<Uint8List?> getPromotionImageBytes(String codigo) =>
      promoService.getPromotionImageBytes(codigo);

  @override
  Future<void> addSupermercado(Supermercado supermercado) async =>
      promoService.addSupermercado(supermercado);

  @override
  Future<void> updateSupermercado(Supermercado supermercado) async =>
      promoService.updateSupermercado(supermercado);

  @override
  Future<void> deleteSupermercado(int id) async => promoService.deleteSupermercado(id);
}
