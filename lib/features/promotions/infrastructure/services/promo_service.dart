import 'package:app/features/promotions/domain/repositories/promotion_repository.dart';
import 'package:app/features/promotions/domain/usecases/promotion_usecases.dart';
import 'package:app/features/promotions/infrastructure/datasources/promo_local_datasource.dart';
import 'package:app/features/promotions/infrastructure/repositories/promotion_repository_impl.dart';
import 'package:app/features/catalog/domain/entities/categoria.dart';
import 'package:app/features/comments/domain/entities/comentario.dart';
import 'package:app/features/interactions/domain/entities/favorito.dart';
import 'package:app/features/promotions/domain/entities/promocion.dart';
import 'package:app/features/promotions/domain/entities/promocion_horario.dart';
import 'package:app/features/moderation/domain/entities/reporte.dart';
import 'package:app/features/promotions/domain/entities/supermercado.dart';
import 'package:app/features/catalog/domain/entities/tipo_promocion.dart';
import 'package:app/features/users/domain/entities/usuario.dart';
import 'package:app/features/interactions/domain/entities/valoracion.dart';
import 'package:flutter/foundation.dart';

/// Fachada compatible con la UI actual.
///
/// Internamente delega en datasource + repository + usecases para cumplir
/// la fase 2 de la migración hexagonal sin romper pantallas existentes.
class PromoService extends ChangeNotifier {
  final PromoLocalDataSource _dataSource;
  final PromotionRepository _promotionRepository;

  late final InitializePromotionsUseCase _initializePromotionsUseCase;
  late final LoadLocalPromotionsUseCase _loadLocalPromotionsUseCase;
  late final GetActivePromotionsUseCase _getActivePromotionsUseCase;
  late final CreatePromotionUseCase _createPromotionUseCase;
  late final UpdatePromotionUseCase _updatePromotionUseCase;
  late final DeletePromotionUseCase _deletePromotionUseCase;
  late final IncrementPromotionViewsUseCase _incrementPromotionViewsUseCase;

  PromoService({
    PromoLocalDataSource? dataSource,
    PromotionRepository? promotionRepository,
  }) : this._internal(
         dataSource ?? PromoLocalDataSource(),
         promotionRepository,
       );

  PromoService._internal(
    this._dataSource,
    PromotionRepository? promotionRepository,
  ) : _promotionRepository =
          promotionRepository ?? PromotionRepositoryImpl(_dataSource) {
    _initializePromotionsUseCase = InitializePromotionsUseCase(
      initData: _dataSource.init,
    );
    _loadLocalPromotionsUseCase = LoadLocalPromotionsUseCase(
      loadLocal: _dataSource.loadLocalPromociones,
    );
    _getActivePromotionsUseCase = GetActivePromotionsUseCase(
      _promotionRepository,
    );
    _createPromotionUseCase = CreatePromotionUseCase(_promotionRepository);
    _updatePromotionUseCase = UpdatePromotionUseCase(_promotionRepository);
    _deletePromotionUseCase = DeletePromotionUseCase(_promotionRepository);
    _incrementPromotionViewsUseCase = IncrementPromotionViewsUseCase(
      _promotionRepository,
    );
  }

  List<Usuario> get usuarios => _dataSource.usuarios;
  List<Supermercado> get supermercados => _dataSource.supermercados;
  List<Categoria> get categorias => _dataSource.categorias;
  List<TipoPromocion> get tiposPromocion => _dataSource.tiposPromocion;
  List<Promocion> get promociones => _dataSource.promociones;
  List<PromocionHorario> get promocionesHorarios =>
      _dataSource.promocionesHorarios;
  List<Comentario> get comentarios => _dataSource.comentarios;
  List<Valoracion> get valoraciones => _dataSource.valoraciones;
  List<Favorito> get favoritos => _dataSource.favoritos;
  List<Reporte> get reportes => _dataSource.reportes;

  bool get loaded => _dataSource.loaded;
  String? get loadError => _dataSource.loadError;

  Uint8List? getImageBytes(String codigo) => _dataSource.imageCache[codigo];

  void setImageBytes(String codigo, Uint8List bytes) {
    _dataSource.imageCache[codigo] = bytes;
    notifyListeners();
  }

  void clearImageCache() {
    _dataSource.imageCache.clear();
    notifyListeners();
  }

  Future<void> init() async {
    await _initializePromotionsUseCase.execute();
    notifyListeners();
  }

  /// Recarga todos los datos desde la API, ignorando el estado de carga previo.
  Future<void> reinitializeFromApi() async {
    await _dataSource.reinitializeFromApi();
    notifyListeners();
  }

  Future<void> loadLocalPromociones() async {
    await _loadLocalPromotionsUseCase.execute();
    notifyListeners();
  }

  Usuario? getUsuario(int id) => _dataSource.getUsuario(id);
  Usuario? getUsuarioByEmail(String email) =>
      _dataSource.getUsuarioByEmail(email);
  List<Usuario> getUsuarios() => usuarios;

  void addUsuario(Usuario usuario) {
    _dataSource.usuarios.add(usuario);
    notifyListeners();
  }

  void updateUsuario(Usuario usuario) {
    final index = _dataSource.usuarios.indexWhere((u) => u.id == usuario.id);
    if (index != -1) {
      _dataSource.usuarios[index] = usuario;
      notifyListeners();
    }
  }

  void deleteUsuario(int id) {
    _dataSource.usuarios.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  List<Promocion> getPromociones() => promociones;

  List<Promocion> getPromocionesAprobadas() =>
      _dataSource.getPromocionesAprobadas();

  List<Promocion> getPromocionesById(int idUsuario) =>
      _dataSource.getPromocionesById(idUsuario);

  Promocion? getPromocionByCodigo(String codigo) {
    return _dataSource.getPromocionByCodigo(codigo);
  }

  List<Promocion> getPromocionesByCategoria(int idCategoria) =>
      _dataSource.getPromocionesByCategoria(idCategoria);

  List<Promocion> getPromocionesBySupermercado(int idSupermercado) =>
      _dataSource.getPromocionesBySupermercado(idSupermercado);

  void addPromocion(Promocion promocion) {
    _createPromotionUseCase.execute(promocion);
    notifyListeners();
  }

  void updatePromocion(Promocion promocion) {
    _updatePromotionUseCase.execute(promocion);
    notifyListeners();
  }

  void deletePromocion(String codigo) {
    _deletePromotionUseCase.execute(codigo);
    notifyListeners();
  }

  List<PromocionHorario> getPromocionesHorarios() => promocionesHorarios;

  List<PromocionHorario> getPromocionesHorariosByCodigo(
    String codigoPromocion,
  ) => _dataSource.getPromocionesHorariosByCodigo(codigoPromocion);

  void addPromocionHorario(PromocionHorario promocionHorario) {
    _dataSource.addPromocionHorario(promocionHorario);
    _dataSource.saveLocalData();
    notifyListeners();
  }

  void updatePromocionHorario(PromocionHorario promocionHorario) {
    _dataSource.updatePromocionHorario(promocionHorario);
    _dataSource.saveLocalData();
    notifyListeners();
  }

  void deletePromocionHorario(int id) {
    _dataSource.deletePromocionHorario(id);
    _dataSource.saveLocalData();
    notifyListeners();
  }

  void incrementarVistas(String codigo) {
    _incrementPromotionViewsUseCase.execute(codigo);
    notifyListeners();
  }

  List<Supermercado> getSupermercados() => supermercados;
  Supermercado? getSupermercado(int id) => _dataSource.getSupermercado(id);

  void updateSupermercado(Supermercado updated) {
    final index = _dataSource.supermercados.indexWhere(
      (s) => s.id == updated.id,
    );
    if (index != -1) {
      _dataSource.supermercados[index] = updated;
      notifyListeners();
    }
  }

  /// Crea un supermercado en la API y lo agrega a la lista local.
  /// Retorna el supermercado creado con el ID asignado por el backend.
  Future<Supermercado> createSupermercado(Supermercado supermercado) async {
    final created = await _promotionRepository.createSupermercado(supermercado);
    final index = _dataSource.supermercados.indexWhere(
      (s) => s.id == created.id,
    );
    if (index == -1) {
      _dataSource.supermercados.add(created);
    } else {
      _dataSource.supermercados[index] = created;
    }
    notifyListeners();
    return created;
  }

  void addSupermercado(Supermercado supermercado) {
    _dataSource.supermercados.add(supermercado);
    notifyListeners();
  }

  void deleteSupermercado(int id) {
    _dataSource.supermercados.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  List<Categoria> getCategorias() => categorias;
  Categoria? getCategoria(int id) => _dataSource.getCategoria(id);

  List<TipoPromocion> getTiposPromocion() => tiposPromocion;
  TipoPromocion? getTipoPromocion(int id) => _dataSource.getTipoPromocion(id);

  List<Comentario> getComentarios() => comentarios;

  List<Comentario> getComentariosByPromocion(String codigoPromocion) =>
      _dataSource.getComentariosByPromocion(codigoPromocion);

  void addComentario(Comentario comentario) {
    _dataSource.addComentario(comentario);
    notifyListeners();
  }

  void deleteComentario(int id) {
    _dataSource.deleteComentario(id);
    notifyListeners();
  }

  List<Valoracion> getValoraciones() => valoraciones;

  List<Valoracion> getValoracionesByPromocion(String codigoPromocion) =>
      _dataSource.getValoracionesByPromocion(codigoPromocion);

  int contarValoracionesPositivas(String codigoPromocion) =>
      _dataSource.contarValoracionesPositivas(codigoPromocion);

  int contarValoracionesNegativas(String codigoPromocion) =>
      _dataSource.contarValoracionesNegativas(codigoPromocion);

  void addValoracion(Valoracion valoracion) {
    _dataSource.addValoracion(valoracion);
    notifyListeners();
  }

  void deleteValoracion(int id) {
    _dataSource.deleteValoracion(id);
    notifyListeners();
  }

  List<Favorito> getFavoritos() => favoritos;

  List<Favorito> getFavoritosByUsuario(int idUsuario) =>
      _dataSource.getFavoritosByUsuario(idUsuario);

  bool isFavorito(int idUsuario, String codigoPromocion) =>
      _dataSource.isFavorito(idUsuario, codigoPromocion);

  void addFavorito(Favorito favorito) {
    _dataSource.addFavorito(favorito);
    notifyListeners();
  }

  void removeFavorito(int idUsuario, String codigoPromocion) {
    _dataSource.removeFavorito(idUsuario, codigoPromocion);
    notifyListeners();
  }

  void toggleFavorito(int idUsuario, String codigoPromocion) {
    _dataSource.toggleFavorito(idUsuario, codigoPromocion);
    notifyListeners();
  }

  List<Reporte> getReportes() => reportes;

  List<Reporte> getReportesByUsuario(int idUsuario) =>
      _dataSource.getReportesByUsuario(idUsuario);

  List<Reporte> getReportesByPromocion(String codigoPromocion) =>
      _dataSource.getReportesByPromocion(codigoPromocion);

  void addReporte(Reporte reporte) {
    _dataSource.addReporte(reporte);
    notifyListeners();
  }

  void updateReporte(Reporte reporte) {
    _dataSource.updateReporte(reporte);
    notifyListeners();
  }

  void deleteReporte(int id) {
    _dataSource.deleteReporte(id);
    notifyListeners();
  }

  List<Promocion> getFlashDeals({int limit = 5}) =>
      _dataSource.getFlashDeals(limit: limit);

  List<Map<String, dynamic>> getNearbyStores({int limit = 5}) =>
      _dataSource.getNearbyStores(limit: limit);

  String getPromocionUrgency(Promocion promo) =>
      _dataSource.getPromocionUrgency(promo);

  Map<String, List<Promocion>> getPromocionesByUrgency(int idUsuario) =>
      _dataSource.getPromocionesByUrgency(idUsuario);

  Map<String, String> getCategoriaStyle(int idCategoria) =>
      _dataSource.getCategoriaStyle(idCategoria);

  double getPrecioConDescuento(Promocion promo) =>
      _dataSource.getPrecioConDescuento(promo);

  double getPromocionRating(String codigoPromocion) =>
      _dataSource.getPromocionRating(codigoPromocion);

  int getPromocionReviewsCount(String codigoPromocion) =>
      _dataSource.getPromocionReviewsCount(codigoPromocion);

  Future<String?> savePromotionImage(
    String codigoPromocion,
    Uint8List bytes,
  ) async {
    final value = await _dataSource.savePromotionImage(codigoPromocion, bytes);
    notifyListeners();
    return value;
  }

  Future<Uint8List?> getPromotionImageBytes(String codigoPromocion) {
    return _dataSource.getPromotionImageBytes(codigoPromocion);
  }

  Future<void> preloadPromotionImages(List<String> codigosPromocion) async {
    await _dataSource.preloadPromotionImages(codigosPromocion);
    notifyListeners();
  }

  Future<List<Promocion>> getPromocionesAprobadasAsync({
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
}
