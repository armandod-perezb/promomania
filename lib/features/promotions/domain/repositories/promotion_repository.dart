import 'package:app/features/promotions/domain/entities/promocion.dart';

/// Interfaz de repositorio para gestión de promociones.
///
/// Define los contratos para operaciones CRUD y consultas avanzadas de promociones.
/// Promotion es el aggregate root principal del dominio.
abstract class PromotionRepository {
  /// Crea una nueva promoción.
  Future<Promocion> createPromotion(Promocion promocion);

  /// Obtiene una promoción por su código.
  Future<Promocion?> getPromotionByCode(String codigo);

  /// Obtiene todas las promociones activas (con filtros opcionales).
  Future<List<Promocion>> getActivePromotions({
    int? categoryId,
    int? supermarketId,
    int? page,
    int? pageSize,
  });

  /// Obtiene promociones por categoría.
  Future<List<Promocion>> getPromotionsByCategory(int categoryId);

  /// Obtiene promociones por supermercado.
  Future<List<Promocion>> getPromotionsBySupermarket(int supermarketId);

  /// Actualiza una promoción existente.
  Future<Promocion> updatePromotion(Promocion promocion);

  /// Aprueba una promoción (cambía estado a 'aprobada').
  Future<void> approvePromotion(String codigo);

  /// Rechaza una promoción (cambía estado a 'rechazada').
  Future<void> rejectPromotion(String codigo);

  /// Elimina una promoción.
  Future<void> deletePromotion(String codigo);

  /// Incrementa el contador de vistas de una promoción.
  Future<void> incrementViews(String codigo);

  /// Obtiene promociones por usuario (creador).
  Future<List<Promocion>> getPromotionsByUser(int userId);
}
