import 'package:app/features/catalog/domain/entities/categoria.dart';
import 'package:app/features/catalog/domain/entities/tipo_promocion.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart';

abstract class CatalogDataSource {
  List<Categoria> getCategorias();
  List<TipoPromocion> getTiposPromocion();
  Categoria? getCategoriaById(int id);
  TipoPromocion? getTipoPromocionById(int id);
}

class PromoCatalogDataSource implements CatalogDataSource {
  final PromoService promoService;

  PromoCatalogDataSource(this.promoService);

  @override
  List<Categoria> getCategorias() {
    return promoService.getCategorias();
  }

  @override
  List<TipoPromocion> getTiposPromocion() {
    return promoService.getTiposPromocion();
  }

  @override
  Categoria? getCategoriaById(int id) {
    return promoService.getCategoria(id);
  }

  @override
  TipoPromocion? getTipoPromocionById(int id) {
    return promoService.getTipoPromocion(id);
  }
}
