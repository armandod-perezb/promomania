import '../entities/reporte.dart';
import '../repositories/moderation_repository.dart';

class GetAllReportesUseCase {
  final ModerationRepository repository;

  GetAllReportesUseCase(this.repository);

  Future<List<Reporte>> execute() {
    return repository.getAllReportes();
  }
}

class GetReportesByUsuarioUseCase {
  final ModerationRepository repository;

  GetReportesByUsuarioUseCase(this.repository);

  Future<List<Reporte>> execute(int userId) {
    return repository.getReportesByUsuario(userId);
  }
}

class GetReportesByPromocionUseCase {
  final ModerationRepository repository;

  GetReportesByPromocionUseCase(this.repository);

  Future<List<Reporte>> execute(String promotionCode) {
    return repository.getReportesByPromocion(promotionCode);
  }
}

class AddReporteUseCase {
  final ModerationRepository repository;

  AddReporteUseCase(this.repository);

  Future<void> execute(Reporte reporte) {
    return repository.addReporte(reporte);
  }
}

class UpdateReporteUseCase {
  final ModerationRepository repository;

  UpdateReporteUseCase(this.repository);

  Future<void> execute(Reporte reporte) {
    return repository.updateReporte(reporte);
  }
}

class DeleteReporteUseCase {
  final ModerationRepository repository;

  DeleteReporteUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deleteReporte(id);
  }
}
