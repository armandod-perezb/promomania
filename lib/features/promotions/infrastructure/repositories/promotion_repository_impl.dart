import 'dart:typed_data';
import 'package:app/features/promotions/domain/repositories/promotion_repository.dart';
import 'package:app/features/promotions/infrastructure/datasources/promo_local_datasource.dart';
import 'package:app/features/promotions/domain/entities/promocion.dart';
import 'package:app/features/promotions/domain/entities/promocion_horario.dart';
import 'package:app/features/promotions/domain/entities/supermercado.dart';

class PromotionRepositoryImpl implements PromotionRepository {
  final PromoLocalDataSource dataSource;

  PromotionRepositoryImpl(this.dataSource);

  // ── Estado ────────────────────────────────────────────────────────────────

  @override
  bool get isLoaded => dataSource.loaded;

  @override
  String? get loadError => dataSource.loadError;

  @override
  Future<void> reinitialize() => dataSource.reinitializeFromApi();

  // ── Sync queries ──────────────────────────────────────────────────────────

  @override
  List<Promocion> getActivePromotionsSync({int? categoryId, int? supermarketId}) {
    var list = dataSource.getPromocionesAprobadas();
    if (categoryId != null) list = list.where((p) => p.idCategoria == categoryId).toList();
    if (supermarketId != null) list = list.where((p) => p.idSupermercado == supermarketId).toList();
    return list;
  }

  @override
  List<Promocion> getAllPromotionsSync() => dataSource.promociones;

  @override
  Promocion? getPromotionByCodeSync(String codigo) => dataSource.getPromocionByCodigo(codigo);

  @override
  List<Promocion> getPromotionsByUserSync(int userId) => dataSource.getPromocionesById(userId);

  @override
  List<Promocion> getFlashDealsSync({int limit = 5}) => dataSource.getFlashDeals(limit: limit);

  @override
  List<Map<String, dynamic>> getNearbyStoresSync({int limit = 5}) => dataSource.getNearbyStores(limit: limit);

  @override
  String getPromocionUrgency(Promocion promo) => dataSource.getPromocionUrgency(promo);

  @override
  Map<String, List<Promocion>> getPromocionesByUrgencySync(int userId) => dataSource.getPromocionesByUrgency(userId);

  @override
  double getPromocionRatingSync(String codigo) => dataSource.getPromocionRating(codigo);

  @override
  double getPrecioConDescuento(Promocion promo) => dataSource.getPrecioConDescuento(promo);

  @override
  List<PromocionHorario> getPromocionesHorariosByCodigoSync(String codigo) =>
      dataSource.promocionesHorarios.where((h) => h.codigoPromocion == codigo).toList();

  @override
  int getNextHorarioIdSync() {
    final horarios = dataSource.promocionesHorarios;
    return (horarios.isEmpty ? 0 : horarios.last.id) + 1;
  }

  @override
  Supermercado? getSupermercadoSync(int id) => dataSource.getSupermercado(id);

  @override
  List<Supermercado> getSupermercadosSync() => dataSource.supermercados;

  @override
  Uint8List? getCachedImageBytes(String codigo) => dataSource.imageCache[codigo];

  // ── Async commands ────────────────────────────────────────────────────────

  @override
  Future<Promocion> createPromotion(Promocion promocion) async {
    dataSource.addPromocion(promocion);
    await dataSource.saveLocalData();
    return promocion;
  }

  @override
  Future<Promocion?> getPromotionByCode(String codigo) async => dataSource.getPromocionByCodigo(codigo);

  @override
  Future<List<Promocion>> getActivePromotions({int? categoryId, int? supermarketId, int? page, int? pageSize}) async {
    var list = getActivePromotionsSync(categoryId: categoryId, supermarketId: supermarketId);
    if (page != null && pageSize != null && page > 0 && pageSize > 0) {
      final start = (page - 1) * pageSize;
      if (start >= list.length) return [];
      list = list.sublist(start, (start + pageSize).clamp(0, list.length));
    }
    return list;
  }

  @override
  Future<List<Promocion>> getPromotionsByCategory(int categoryId) async =>
      dataSource.getPromocionesByCategoria(categoryId);

  @override
  Future<List<Promocion>> getPromotionsBySupermarket(int supermarketId) async =>
      dataSource.getPromocionesBySupermercado(supermarketId);

  @override
  Future<List<Promocion>> getPromotionsByUser(int userId) async => dataSource.getPromocionesById(userId);

  @override
  Future<Promocion> updatePromotion(Promocion promocion) async {
    dataSource.updatePromocion(promocion);
    await dataSource.saveLocalData();
    return promocion;
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
  Future<void> deletePromotion(String codigo) async {
    dataSource.deletePromocion(codigo);
    await dataSource.saveLocalData();
  }

  @override
  Future<void> incrementViews(String codigo) async {
    dataSource.incrementarVistas(codigo);
    await dataSource.saveLocalData();
  }

  @override
  Future<void> addPromocionHorario(PromocionHorario horario) async {
    dataSource.promocionesHorarios.add(horario);
    await dataSource.saveLocalData();
  }

  @override
  Future<String?> savePromotionImage(String codigo, Uint8List bytes) =>
      dataSource.savePromotionImage(codigo, bytes);

  @override
  Future<Uint8List?> getPromotionImageBytes(String codigo) => dataSource.getPromotionImageBytes(codigo);

  @override
  Future<void> addSupermercado(Supermercado supermercado) async {
    dataSource.supermercados.add(supermercado);
    await dataSource.saveLocalData();
  }

  @override
  Future<void> updateSupermercado(Supermercado supermercado) async {
    final index = dataSource.supermercados.indexWhere((s) => s.id == supermercado.id);
    if (index != -1) {
      dataSource.supermercados[index] = supermercado;
      await dataSource.saveLocalData();
    }
  }

  @override
  Future<void> deleteSupermercado(int id) async {
    dataSource.supermercados.removeWhere((s) => s.id == id);
    await dataSource.saveLocalData();
  }
}
