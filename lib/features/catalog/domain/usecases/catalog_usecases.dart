import '../entities/categoria.dart';
import '../entities/tipo_promocion.dart';
import '../repositories/catalog_repository.dart';

class GetCategoriasUseCase {
  final CatalogRepository repository;

  GetCategoriasUseCase(this.repository);

  Future<List<Categoria>> execute() {
    return repository.getCategorias();
  }
}

class GetTiposPromocionUseCase {
  final CatalogRepository repository;

  GetTiposPromocionUseCase(this.repository);

  Future<List<TipoPromocion>> execute() {
    return repository.getTiposPromocion();
  }
}

class GetCategoriaByIdUseCase {
  final CatalogRepository repository;

  GetCategoriaByIdUseCase(this.repository);

  Future<Categoria?> execute(int id) {
    return repository.getCategoriaById(id);
  }
}

class GetTipoPromocionByIdUseCase {
  final CatalogRepository repository;

  GetTipoPromocionByIdUseCase(this.repository);

  Future<TipoPromocion?> execute(int id) {
    return repository.getTipoPromocionById(id);
  }
}
