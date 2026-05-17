import '../entities/reporte.dart';

abstract class ModerationRepository {
  Future<List<Reporte>> getAllReportes();
  Future<List<Reporte>> getReportesByUsuario(int userId);
  Future<List<Reporte>> getReportesByPromocion(String promotionCode);
  Future<void> addReporte(Reporte reporte);
  Future<void> updateReporte(Reporte reporte);
  Future<void> deleteReporte(int id);
}
