import 'package:app/features/catalog/domain/entities/categoria.dart';
import 'package:app/features/catalog/domain/entities/tipo_promocion.dart';
import 'package:app/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:app/features/catalog/infrastructure/datasources/catalog_datasource.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogDataSource dataSource;

  CatalogRepositoryImpl(this.dataSource);

  @override
  Future<List<Categoria>> getCategorias() async {
    return dataSource.getCategorias();
  }

  @override
  Future<List<TipoPromocion>> getTiposPromocion() async {
    return dataSource.getTiposPromocion();
  }

  @override
  Future<Categoria?> getCategoriaById(int id) async {
    return dataSource.getCategoriaById(id);
  }

  @override
  Future<TipoPromocion?> getTipoPromocionById(int id) async {
    return dataSource.getTipoPromocionById(id);
  }
}
