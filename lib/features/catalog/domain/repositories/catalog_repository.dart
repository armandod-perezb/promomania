import '../entities/categoria.dart';
import '../entities/tipo_promocion.dart';

abstract class CatalogRepository {
  Future<List<Categoria>> getCategorias();
  Future<List<TipoPromocion>> getTiposPromocion();
  Future<Categoria?> getCategoriaById(int id);
  Future<TipoPromocion?> getTipoPromocionById(int id);
}
