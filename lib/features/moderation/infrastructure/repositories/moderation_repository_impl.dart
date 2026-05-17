import 'package:app/features/moderation/domain/entities/reporte.dart';
import 'package:app/features/moderation/domain/repositories/moderation_repository.dart';
import 'package:app/features/moderation/infrastructure/datasources/moderation_datasource.dart';

class ModerationRepositoryImpl implements ModerationRepository {
  final ModerationDataSource dataSource;

  ModerationRepositoryImpl(this.dataSource);

  @override
  Future<List<Reporte>> getAllReportes() async {
    return dataSource.getAllReportes();
  }

  @override
  Future<List<Reporte>> getReportesByUsuario(int userId) async {
    return dataSource.getReportesByUsuario(userId);
  }

  @override
  Future<List<Reporte>> getReportesByPromocion(String promotionCode) async {
    return dataSource.getReportesByPromocion(promotionCode);
  }

  @override
  Future<void> addReporte(Reporte reporte) async {
    dataSource.addReporte(reporte);
  }

  @override
  Future<void> updateReporte(Reporte reporte) async {
    dataSource.updateReporte(reporte);
  }

  @override
  Future<void> deleteReporte(int id) async {
    dataSource.deleteReporte(id);
  }
}
