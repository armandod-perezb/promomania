import '../entities/categoria.dart';
import '../entities/tipo_promocion.dart';
import '../repositories/catalog_repository.dart';

/// Caso de uso para obtener categorias; mantiene la regla de negocio fuera de la interfaz.
class GetCategoriasUseCase {
  final CatalogRepository repository;

  GetCategoriasUseCase(this.repository);

  Future<List<Categoria>> execute() {
    return repository.getCategorias();
  }
}

/// Caso de uso para obtener tipos de promocion; mantiene la regla de negocio fuera de la interfaz.
class GetTiposPromocionUseCase {
  final CatalogRepository repository;

  GetTiposPromocionUseCase(this.repository);

  Future<List<TipoPromocion>> execute() {
    return repository.getTiposPromocion();
  }
}

/// Caso de uso para obtener una categoria por identificador; mantiene la regla de negocio fuera de la interfaz.
class GetCategoriaByIdUseCase {
  final CatalogRepository repository;

  GetCategoriaByIdUseCase(this.repository);

  Future<Categoria?> execute(int id) {
    return repository.getCategoriaById(id);
  }
}

/// Caso de uso para obtener un tipo de promocion por identificador; mantiene la regla de negocio fuera de la interfaz.
class GetTipoPromocionByIdUseCase {
  final CatalogRepository repository;

  GetTipoPromocionByIdUseCase(this.repository);

  Future<TipoPromocion?> execute(int id) {
    return repository.getTipoPromocionById(id);
  }
}

/// Caso de uso para obtener una categoria desde cache local; mantiene la regla de negocio fuera de la interfaz.
class GetCategoriaByIdSyncUseCase {
  final CatalogRepository repository;
  GetCategoriaByIdSyncUseCase(this.repository);
  Categoria? execute(int id) => repository.getCategoriaByIdSync(id);
}

/// Caso de uso para resolver el estilo visual de una categoria; mantiene la regla de negocio fuera de la interfaz.
class GetCategoriaStyleUseCase {
  final CatalogRepository repository;

  GetCategoriaStyleUseCase(this.repository);

  Map<String, String> execute(int idCategoria) {
    return repository.getCategoriaStyleSync(idCategoria);
  }
}
