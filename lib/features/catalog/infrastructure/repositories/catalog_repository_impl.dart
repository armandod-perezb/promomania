import 'package:app/features/catalog/domain/entities/categoria.dart';
import 'package:app/features/catalog/domain/entities/tipo_promocion.dart';
import 'package:app/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:app/features/catalog/infrastructure/datasources/catalog_datasource.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogDataSource dataSource;

  CatalogRepositoryImpl(this.dataSource);

  @override
  Future<List<Categoria>> getCategorias() async => dataSource.getCategorias();

  @override
  Future<List<TipoPromocion>> getTiposPromocion() async => dataSource.getTiposPromocion();

  @override
  Future<Categoria?> getCategoriaById(int id) async => dataSource.getCategoriaById(id);

  @override
  Future<TipoPromocion?> getTipoPromocionById(int id) async => dataSource.getTipoPromocionById(id);

  @override
  Categoria? getCategoriaByIdSync(int id) => dataSource.getCategoriaByIdSync(id);

  @override
  Map<String, String> getCategoriaStyleSync(int idCategoria) =>
      dataSource.getCategoriaStyle(idCategoria);
}
