import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/promotions/domain/entities/promocion.dart';
import 'package:app/features/promotions/domain/entities/promocion_horario.dart';
import 'package:app/features/promotions/domain/entities/supermercado.dart';
import 'package:app/features/promotions/domain/repositories/promotion_repository.dart';
import 'package:app/features/promotions/infrastructure/datasources/remote_admin_promotion_datasource.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart';

/// Adapter que implementa PromotionRepository delegando en PromoService.
/// Permite integrar una capa remota (Django API) sin romper la UI actual.
class PromotionServiceRepositoryAdapter implements PromotionRepository {
  final PromoService promoService;
  final RemoteAdminPromotionDataSource? remoteDataSource;

  PromotionServiceRepositoryAdapter(
    this.promoService, {
    this.remoteDataSource,
  });

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
    if (categoryId != null) {
      result = result.where((p) => p.idCategoria == categoryId);
    }
    if (supermarketId != null) {
      result = result.where((p) => p.idSupermercado == supermarketId);
    }
    return result.toList();
  }

  @override
  List<Promocion> getAllPromotionsSync() => promoService.getPromociones();

  @override
  Promocion? getPromotionByCodeSync(String codigo) =>
      promoService.getPromocionByCodigo(codigo);

  @override
  List<Promocion> getPromotionsByUserSync(int userId) =>
      promoService.getPromocionesById(userId);

  @override
  List<Promocion> getFlashDealsSync({int limit = 5}) =>
      promoService.getFlashDeals(limit: limit);

  @override
  List<Map<String, dynamic>> getNearbyStoresSync({int limit = 5}) =>
      promoService.getNearbyStores(limit: limit);

  @override
  String getPromocionUrgency(Promocion promo) =>
      promoService.getPromocionUrgency(promo);

  @override
  Map<String, List<Promocion>> getPromocionesByUrgencySync(int userId) =>
      promoService.getPromocionesByUrgency(userId);

  @override
  double getPromocionRatingSync(String codigo) =>
      promoService.getPromocionRating(codigo);

  @override
  double getPrecioConDescuento(Promocion promo) =>
      promoService.getPrecioConDescuento(promo);

  @override
  List<PromocionHorario> getPromocionesHorariosByCodigoSync(String codigo) =>
      promoService
          .getPromocionesHorarios()
          .where((h) => h.codigoPromocion == codigo)
          .toList();

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
    if (remoteDataSource != null) {
      try {
        final created = await remoteDataSource!.createPromotion(promocion);
        _upsertLocalPromotion(created);
        return created;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }

    promoService.addPromocion(promocion);
    return promocion;
  }

  @override
  Future<Promocion?> getPromotionByCode(String codigo) async {
    if (remoteDataSource != null) {
      try {
        final remote = await remoteDataSource!.getPromotionByCode(codigo);
        if (remote != null) _upsertLocalPromotion(remote);
        return remote ?? promoService.getPromocionByCodigo(codigo);
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    return promoService.getPromocionByCodigo(codigo);
  }

  @override
  Future<List<Promocion>> getActivePromotions({
    int? categoryId,
    int? supermarketId,
    int? page,
    int? pageSize,
  }) async {
    var list = getActivePromotionsSync(
      categoryId: categoryId,
      supermarketId: supermarketId,
    );

    if (remoteDataSource != null) {
      try {
        final remoteAll = await remoteDataSource!.getAllPromotions();
        for (final promo in remoteAll) {
          _upsertLocalPromotion(promo);
        }
        list = remoteAll.where((p) => p.estado == 'aprobada').toList();
        if (categoryId != null) {
          list = list.where((p) => p.idCategoria == categoryId).toList();
        }
        if (supermarketId != null) {
          list = list.where((p) => p.idSupermercado == supermarketId).toList();
        }
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }

    if (page == null || pageSize == null || pageSize <= 0) return list;
    final start = (page - 1) * pageSize;
    if (start < 0 || start >= list.length) return [];
    return list.sublist(start, (start + pageSize).clamp(0, list.length));
  }

  @override
  Future<List<Promocion>> getPromotionsByCategory(int categoryId) async {
    if (remoteDataSource != null) {
      try {
        final remoteAll = await remoteDataSource!.getAllPromotions();
        for (final promo in remoteAll) {
          _upsertLocalPromotion(promo);
        }
        return remoteAll.where((p) => p.idCategoria == categoryId).toList();
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    return promoService.getPromocionesByCategoria(categoryId);
  }

  @override
  Future<List<Promocion>> getPromotionsBySupermarket(int supermarketId) async {
    if (remoteDataSource != null) {
      try {
        final remoteAll = await remoteDataSource!.getAllPromotions();
        for (final promo in remoteAll) {
          _upsertLocalPromotion(promo);
        }
        return remoteAll.where((p) => p.idSupermercado == supermarketId).toList();
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    return promoService.getPromocionesBySupermercado(supermarketId);
  }

  @override
  Future<List<Promocion>> getPromotionsByUser(int userId) async {
    if (remoteDataSource != null) {
      try {
        final remoteAll = await remoteDataSource!.getAllPromotions();
        for (final promo in remoteAll) {
          _upsertLocalPromotion(promo);
        }
        return remoteAll.where((p) => p.idUsuario == userId).toList();
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    return promoService.getPromocionesById(userId);
  }

  @override
  Future<Promocion> updatePromotion(Promocion promocion) async {
    if (remoteDataSource != null) {
      try {
        final updated = await remoteDataSource!.updatePromotion(promocion);
        _upsertLocalPromotion(updated);
        return updated;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    promoService.updatePromocion(promocion);
    return promocion;
  }

  @override
  Future<void> approvePromotion(String codigo) async {
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.approvePromotion(codigo);
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    final local = promoService.getPromocionByCodigo(codigo);
    if (local != null) {
      _upsertLocalPromotion(local.copyWith(estado: 'aprobada'));
    }
  }

  @override
  Future<void> rejectPromotion(String codigo) async {
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.rejectPromotion(codigo);
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    final local = promoService.getPromocionByCodigo(codigo);
    if (local != null) {
      _upsertLocalPromotion(local.copyWith(estado: 'rechazada'));
    }
  }

  @override
  Future<void> deletePromotion(String codigo) async {
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.deletePromotion(codigo);
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    promoService.deletePromocion(codigo);
  }

  @override
  Future<void> incrementViews(String codigo) async {
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.incrementViews(codigo);
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    promoService.incrementarVistas(codigo);
  }

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
  Future<Supermercado> createSupermercado(Supermercado supermercado) async {
    debugPrint('DEBUG REPO - createSupermercado llamado: ${supermercado.nombre}');
    debugPrint('DEBUG REPO - remoteDataSource: ${remoteDataSource != null}');
    
    if (remoteDataSource != null) {
      try {
        debugPrint('DEBUG REPO - Llamando a API...');
        final created = await remoteDataSource!.createSupermercado(supermercado);
        debugPrint('DEBUG REPO - API respondió con ID: ${created.id}');
        _upsertLocalSupermercado(created);
        return created;
      } catch (e) {
        debugPrint('DEBUG REPO - Error en API: $e');
        if (!_shouldFallbackToLocal(e)) {
          debugPrint('DEBUG REPO - Relanzando error: $e');
          rethrow;
        }
        debugPrint('DEBUG REPO - Fallback a local por NetworkException');
      }
    }
    // Fallback: asignar ID local temporal y agregar
    debugPrint('DEBUG REPO - Creando supermercado local (fallback)');
    final localId = promoService.getSupermercados().length + 1;
    final localSupermercado = Supermercado(
      id: localId,
      nombre: supermercado.nombre,
      direccion: supermercado.direccion,
      ciudad: supermercado.ciudad,
      estado: supermercado.estado,
    );
    promoService.addSupermercado(localSupermercado);
    return localSupermercado;
  }

  @override
  Future<void> addSupermercado(Supermercado supermercado) async {
    if (remoteDataSource != null) {
      try {
        final created = await remoteDataSource!.createSupermercado(supermercado);
        _upsertLocalSupermercado(created);
        return;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    promoService.addSupermercado(supermercado);
  }

  @override
  Future<void> updateSupermercado(Supermercado supermercado) async {
    if (remoteDataSource != null) {
      try {
        final updated = await remoteDataSource!.updateSupermercado(supermercado);
        _upsertLocalSupermercado(updated);
        return;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    promoService.updateSupermercado(supermercado);
  }

  @override
  Future<void> deleteSupermercado(int id) async {
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.deleteSupermercado(id);
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    promoService.deleteSupermercado(id);
  }

  void _upsertLocalPromotion(Promocion promocion) {
    if (promoService.getPromocionByCodigo(promocion.codigo) == null) {
      promoService.addPromocion(promocion);
      return;
    }
    promoService.updatePromocion(promocion);
  }

  void _upsertLocalSupermercado(Supermercado supermercado) {
    if (promoService.getSupermercado(supermercado.id) == null) {
      promoService.addSupermercado(supermercado);
      return;
    }
    promoService.updateSupermercado(supermercado);
  }

  bool _shouldFallbackToLocal(Object error) {
    return error is NetworkException;
  }
}
