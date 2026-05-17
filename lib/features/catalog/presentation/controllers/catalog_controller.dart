import 'package:app/features/catalog/domain/entities/categoria.dart';
import 'package:app/features/catalog/domain/entities/tipo_promocion.dart';
import 'package:app/features/catalog/domain/usecases/catalog_usecases.dart';

class CatalogController {
  final GetCategoriasUseCase _getCategoriasUseCase;
  final GetTiposPromocionUseCase _getTiposPromocionUseCase;
  final GetCategoriaByIdUseCase _getCategoriaByIdUseCase;
  final GetTipoPromocionByIdUseCase _getTipoPromocionByIdUseCase;

  CatalogController({
    required GetCategoriasUseCase getCategoriasUseCase,
    required GetTiposPromocionUseCase getTiposPromocionUseCase,
    required GetCategoriaByIdUseCase getCategoriaByIdUseCase,
    required GetTipoPromocionByIdUseCase getTipoPromocionByIdUseCase,
  }) : _getCategoriasUseCase = getCategoriasUseCase,
       _getTiposPromocionUseCase = getTiposPromocionUseCase,
       _getCategoriaByIdUseCase = getCategoriaByIdUseCase,
       _getTipoPromocionByIdUseCase = getTipoPromocionByIdUseCase;

  Future<List<Categoria>> getCategorias() {
    return _getCategoriasUseCase.execute();
  }

  Future<List<TipoPromocion>> getTiposPromocion() {
    return _getTiposPromocionUseCase.execute();
  }

  Future<Categoria?> getCategoriaById(int id) {
    return _getCategoriaByIdUseCase.execute(id);
  }

  Future<TipoPromocion?> getTipoPromocionById(int id) {
    return _getTipoPromocionByIdUseCase.execute(id);
  }
}
