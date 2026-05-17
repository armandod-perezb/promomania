import 'package:app/features/notifications/domain/entities/notification_summary.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart';

abstract class NotificationDataSource {
  NotificationSummary getAdminSummary();
  int getReportesBadgeCount();
}

class PromoNotificationDataSource implements NotificationDataSource {
  final PromoService promoService;

  PromoNotificationDataSource(this.promoService);

  @override
  NotificationSummary getAdminSummary() {
    final reportes = promoService.getReportes();
    final promociones = promoService.getPromociones();
    final usuarios = promoService.getUsuarios();
    final comentarios = promoService.getComentarios();

    final promocionesPendientes =
        promociones.where((p) => p.estado.toLowerCase() == 'pendiente').length;

    return NotificationSummary(
      reportesPendientes: reportes.length,
      promocionesPendientes: promocionesPendientes,
      totalUsuarios: usuarios.length,
      totalComentarios: comentarios.length,
      generatedAt: DateTime.now(),
    );
  }

  @override
  int getReportesBadgeCount() {
    return promoService.getReportes().length;
  }
}
