import '../entities/reporte.dart';
import '../repositories/moderation_repository.dart';

/// Caso de uso para GetReportesSync; mantiene la regla de negocio fuera de la interfaz.
class GetReportesSyncUseCase {
  final ModerationRepository repository;
  GetReportesSyncUseCase(this.repository);
  List<Reporte> execute() => repository.getReportesSync();
}

/// Caso de uso para GetAllReportes; mantiene la regla de negocio fuera de la interfaz.
class GetAllReportesUseCase {
  final ModerationRepository repository;

  GetAllReportesUseCase(this.repository);

  Future<List<Reporte>> execute() {
    return repository.getAllReportes();
  }
}

/// Caso de uso para GetReportesByUsuario; mantiene la regla de negocio fuera de la interfaz.
class GetReportesByUsuarioUseCase {
  final ModerationRepository repository;

  GetReportesByUsuarioUseCase(this.repository);

  Future<List<Reporte>> execute(int userId) {
    return repository.getReportesByUsuario(userId);
  }
}

/// Caso de uso para GetReportesByPromocion; mantiene la regla de negocio fuera de la interfaz.
class GetReportesByPromocionUseCase {
  final ModerationRepository repository;

  GetReportesByPromocionUseCase(this.repository);

  Future<List<Reporte>> execute(String promotionCode) {
    return repository.getReportesByPromocion(promotionCode);
  }
}

/// Caso de uso para AddReporte; mantiene la regla de negocio fuera de la interfaz.
class AddReporteUseCase {
  final ModerationRepository repository;

  AddReporteUseCase(this.repository);

  Future<void> execute(Reporte reporte) {
    return repository.addReporte(reporte);
  }
}

/// Caso de uso para UpdateReporte; mantiene la regla de negocio fuera de la interfaz.
class UpdateReporteUseCase {
  final ModerationRepository repository;

  UpdateReporteUseCase(this.repository);

  Future<void> execute(Reporte reporte) {
    return repository.updateReporte(reporte);
  }
}

/// Caso de uso para eliminar un reporte; mantiene la regla de negocio fuera de la interfaz.
class DeleteReporteUseCase {
  final ModerationRepository repository;

  DeleteReporteUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deleteReporte(id);
  }
}
