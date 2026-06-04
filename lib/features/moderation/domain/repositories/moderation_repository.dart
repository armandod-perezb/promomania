import '../entities/reporte.dart';

/// Contrato de repositorio de moderacion; define las operaciones que consume la capa de dominio.
abstract class ModerationRepository {
  List<Reporte> getReportesSync();
  Future<List<Reporte>> getAllReportes();
  Future<List<Reporte>> getReportesByUsuario(int userId);
  Future<List<Reporte>> getReportesByPromocion(String promotionCode);
  Future<void> addReporte(Reporte reporte);
  Future<void> updateReporte(Reporte reporte);
  Future<void> deleteReporte(int id);
}
