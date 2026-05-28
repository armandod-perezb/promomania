import 'package:app/features/catalog/domain/entities/categoria.dart';
import 'package:app/features/catalog/domain/entities/tipo_promocion.dart';
import 'package:app/features/catalog/domain/usecases/catalog_usecases.dart';

class CatalogController {
  final GetCategoriasUseCase _getCategoriasUseCase;
  final GetTiposPromocionUseCase _getTiposPromocionUseCase;
  final GetCategoriaByIdUseCase _getCategoriaByIdUseCase;
  final GetTipoPromocionByIdUseCase _getTipoPromocionByIdUseCase;
  final GetCategoriaByIdSyncUseCase _getCategoriaByIdSyncUseCase;
  final GetCategoriaStyleUseCase _getCategoriaStyleUseCase;

  CatalogController({
    required GetCategoriasUseCase getCategoriasUseCase,
    required GetTiposPromocionUseCase getTiposPromocionUseCase,
    required GetCategoriaByIdUseCase getCategoriaByIdUseCase,
    required GetTipoPromocionByIdUseCase getTipoPromocionByIdUseCase,
    required GetCategoriaByIdSyncUseCase getCategoriaByIdSyncUseCase,
    required GetCategoriaStyleUseCase getCategoriaStyleUseCase,
  }) : _getCategoriasUseCase = getCategoriasUseCase,
       _getTiposPromocionUseCase = getTiposPromocionUseCase,
       _getCategoriaByIdUseCase = getCategoriaByIdUseCase,
       _getTipoPromocionByIdUseCase = getTipoPromocionByIdUseCase,
       _getCategoriaByIdSyncUseCase = getCategoriaByIdSyncUseCase,
       _getCategoriaStyleUseCase = getCategoriaStyleUseCase;

  Future<List<Categoria>> getCategorias() => _getCategoriasUseCase.execute();
  Future<List<TipoPromocion>> getTiposPromocion() => _getTiposPromocionUseCase.execute();
  Future<Categoria?> getCategoriaById(int id) => _getCategoriaByIdUseCase.execute(id);
  Future<TipoPromocion?> getTipoPromocionById(int id) => _getTipoPromocionByIdUseCase.execute(id);
  Categoria? getCategoriaByIdSync(int id) => _getCategoriaByIdSyncUseCase.execute(id);
  Map<String, String> getCategoriaStyleSync(int idCategoria) => _getCategoriaStyleUseCase.execute(idCategoria);
}
