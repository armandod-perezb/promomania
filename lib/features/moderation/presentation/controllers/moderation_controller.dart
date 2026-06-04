import 'package:app/features/moderation/domain/entities/reporte.dart';
import 'package:app/features/moderation/domain/usecases/moderation_usecases.dart';

/// Controlador de moderacion; coordina casos de uso y expone operaciones para la capa de presentacion.
class ModerationController {
  final GetReportesSyncUseCase _getReportesSyncUseCase;
  final GetAllReportesUseCase _getAllReportesUseCase;
  final GetReportesByUsuarioUseCase _getReportesByUsuarioUseCase;
  final GetReportesByPromocionUseCase _getReportesByPromocionUseCase;
  final AddReporteUseCase _addReporteUseCase;
  final UpdateReporteUseCase _updateReporteUseCase;
  final DeleteReporteUseCase _deleteReporteUseCase;

  ModerationController({
    required GetReportesSyncUseCase getReportesSyncUseCase,
    required GetAllReportesUseCase getAllReportesUseCase,
    required GetReportesByUsuarioUseCase getReportesByUsuarioUseCase,
    required GetReportesByPromocionUseCase getReportesByPromocionUseCase,
    required AddReporteUseCase addReporteUseCase,
    required UpdateReporteUseCase updateReporteUseCase,
    required DeleteReporteUseCase deleteReporteUseCase,
  }) : _getReportesSyncUseCase = getReportesSyncUseCase,
       _getAllReportesUseCase = getAllReportesUseCase,
       _getReportesByUsuarioUseCase = getReportesByUsuarioUseCase,
       _getReportesByPromocionUseCase = getReportesByPromocionUseCase,
       _addReporteUseCase = addReporteUseCase,
       _updateReporteUseCase = updateReporteUseCase,
       _deleteReporteUseCase = deleteReporteUseCase;

  List<Reporte> getReportesSync() => _getReportesSyncUseCase.execute();

  Future<List<Reporte>> getAllReportes() {
    return _getAllReportesUseCase.execute();
  }

  Future<List<Reporte>> getReportesByUsuario(int userId) {
    return _getReportesByUsuarioUseCase.execute(userId);
  }

  Future<List<Reporte>> getReportesByPromocion(String promotionCode) {
    return _getReportesByPromocionUseCase.execute(promotionCode);
  }

  Future<void> addReporte(Reporte reporte) {
    return _addReporteUseCase.execute(reporte);
  }

  Future<void> updateReporte(Reporte reporte) {
    return _updateReporteUseCase.execute(reporte);
  }

  Future<void> deleteReporte(int id) {
    return _deleteReporteUseCase.execute(id);
  }
}
