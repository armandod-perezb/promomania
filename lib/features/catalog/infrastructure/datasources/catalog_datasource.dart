import 'package:app/features/catalog/domain/entities/categoria.dart';
import 'package:app/features/catalog/domain/entities/tipo_promocion.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart';

/// Contrato de fuente de datos de catalogo; separa el origen concreto de la informacion del resto de la app.
abstract class CatalogDataSource {
  List<Categoria> getCategorias();
  List<TipoPromocion> getTiposPromocion();
  Categoria? getCategoriaById(int id);
  Categoria? getCategoriaByIdSync(int id);
  TipoPromocion? getTipoPromocionById(int id);
  Map<String, String> getCategoriaStyle(int idCategoria);
}

/// Fuente de datos de catalogo; obtiene y transforma informacion desde servicios o almacenamiento local.
class PromoCatalogDataSource implements CatalogDataSource {
  final PromoService promoService;

  PromoCatalogDataSource(this.promoService);

  @override
  List<Categoria> getCategorias() => promoService.getCategorias();

  @override
  List<TipoPromocion> getTiposPromocion() => promoService.getTiposPromocion();

  @override
  Categoria? getCategoriaById(int id) => promoService.getCategoria(id);

  @override
  Categoria? getCategoriaByIdSync(int id) => promoService.getCategoria(id);

  @override
  TipoPromocion? getTipoPromocionById(int id) =>
      promoService.getTipoPromocion(id);

  @override
  Map<String, String> getCategoriaStyle(int idCategoria) =>
      promoService.getCategoriaStyle(idCategoria);
}
