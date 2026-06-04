import '../entities/categoria.dart';
import '../entities/tipo_promocion.dart';

/// Contrato de repositorio de catalogo; define las operaciones que consume la capa de dominio.
abstract class CatalogRepository {
  Future<List<Categoria>> getCategorias();
  Future<List<TipoPromocion>> getTiposPromocion();
  Future<Categoria?> getCategoriaById(int id);
  Future<TipoPromocion?> getTipoPromocionById(int id);

  /// Devuelve una categoría por ID de forma síncrona.
  Categoria? getCategoriaByIdSync(int id);

  /// Devuelve los datos de estilo (emoji y color hex) para una categoría.
  /// Operación síncrona pura — apta para builds reactivos de UI.
  Map<String, String> getCategoriaStyleSync(int idCategoria);
}
