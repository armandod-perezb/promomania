import 'dart:typed_data';
import 'package:app/features/promotions/domain/entities/promocion.dart';
import 'package:app/features/promotions/domain/entities/promocion_horario.dart';
import 'package:app/features/promotions/domain/entities/supermercado.dart';

/// Interfaz de repositorio para gestión de promociones.
///
/// Define contratos CQRS:
///  - Queries síncronas (datos en memoria, ideales para builds reactivos de UI)
///  - Commands asíncronos (operaciones con persistencia)
abstract class PromotionRepository {
  // ── Estado ────────────────────────────────────────────────────────────────

  bool get isLoaded;
  String? get loadError;
  Future<void> reinitialize();

  // ── Queries síncronas ─────────────────────────────────────────────────────

  List<Promocion> getActivePromotionsSync({int? categoryId, int? supermarketId});
  List<Promocion> getAllPromotionsSync();
  Promocion? getPromotionByCodeSync(String codigo);
  List<Promocion> getPromotionsByUserSync(int userId);
  List<Promocion> getFlashDealsSync({int limit = 5});
  List<Map<String, dynamic>> getNearbyStoresSync({int limit = 5});
  String getPromocionUrgency(Promocion promo);
  Map<String, List<Promocion>> getPromocionesByUrgencySync(int userId);
  double getPromocionRatingSync(String codigo);
  double getPrecioConDescuento(Promocion promo);

  List<PromocionHorario> getPromocionesHorariosByCodigoSync(String codigo);
  int getNextHorarioIdSync();

  Supermercado? getSupermercadoSync(int id);
  List<Supermercado> getSupermercadosSync();

  Uint8List? getCachedImageBytes(String codigo);

  // ── Commands asíncronos ───────────────────────────────────────────────────

  Future<Promocion> createPromotion(Promocion promocion);
  Future<Promocion?> getPromotionByCode(String codigo);
  Future<List<Promocion>> getActivePromotions({
    int? categoryId,
    int? supermarketId,
    int? page,
    int? pageSize,
  });
  Future<List<Promocion>> getPromotionsByCategory(int categoryId);
  Future<List<Promocion>> getPromotionsBySupermarket(int supermarketId);
  Future<Promocion> updatePromotion(Promocion promocion);
  Future<void> approvePromotion(String codigo);
  Future<void> rejectPromotion(String codigo);
  Future<void> deletePromotion(String codigo);
  Future<void> incrementViews(String codigo);
  Future<List<Promocion>> getPromotionsByUser(int userId);

  Future<void> addPromocionHorario(PromocionHorario horario);
  Future<String?> savePromotionImage(String codigo, Uint8List bytes);
  Future<Uint8List?> getPromotionImageBytes(String codigo);

  Future<Supermercado> createSupermercado(Supermercado supermercado);
  Future<void> addSupermercado(Supermercado supermercado);
  Future<void> updateSupermercado(Supermercado supermercado);
  Future<void> deleteSupermercado(int id);
}
