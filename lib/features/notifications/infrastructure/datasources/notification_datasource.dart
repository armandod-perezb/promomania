import 'package:app/features/notifications/domain/entities/notification_item.dart';
import 'package:app/features/notifications/domain/entities/push_campaign.dart';
import 'package:app/features/notifications/domain/entities/notification_summary.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart';

/// Contrato de fuente de datos de notificaciones; separa el origen concreto de la informacion del resto de la app.
abstract class NotificationDataSource {
  NotificationSummary getAdminSummary();
  int getReportesBadgeCount();
  List<NotificationItem> getAllNotifications();
  NotificationItem createNotification(NotificationItem item);
  NotificationItem updateNotification(NotificationItem item);
  void deleteNotification(int id);
  List<PushCampaign> getAllPushCampaigns();
  PushCampaign createPushCampaign(PushCampaign campaign);
  PushCampaign updatePushCampaign(PushCampaign campaign);
  void deletePushCampaign(int id);
}

/// Fuente de datos de notificaciones; obtiene y transforma informacion desde servicios o almacenamiento local.
class PromoNotificationDataSource implements NotificationDataSource {
  final PromoService promoService;
  final List<NotificationItem> _notifications = [];
  final List<PushCampaign> _pushCampaigns = [];

  PromoNotificationDataSource(this.promoService);

  @override
  NotificationSummary getAdminSummary() {
    final reportes = promoService.getReportes();
    final promociones = promoService.getPromociones();
    final usuarios = promoService.getUsuarios();
    final comentarios = promoService.getComentarios();

    final promocionesPendientes = promociones
        .where((p) => p.estado.toLowerCase() == 'pendiente')
        .length;

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

  @override
  List<NotificationItem> getAllNotifications() =>
      List.unmodifiable(_notifications);

  @override
  NotificationItem createNotification(NotificationItem item) {
    _notifications.add(item);
    return item;
  }

  @override
  NotificationItem updateNotification(NotificationItem item) {
    final index = _notifications.indexWhere((n) => n.id == item.id);
    if (index == -1) {
      _notifications.add(item);
      return item;
    }
    _notifications[index] = item;
    return item;
  }

  @override
  void deleteNotification(int id) {
    _notifications.removeWhere((n) => n.id == id);
  }

  @override
  List<PushCampaign> getAllPushCampaigns() => List.unmodifiable(_pushCampaigns);

  @override
  PushCampaign createPushCampaign(PushCampaign campaign) {
    _pushCampaigns.add(campaign);
    return campaign;
  }

  @override
  PushCampaign updatePushCampaign(PushCampaign campaign) {
    final index = _pushCampaigns.indexWhere((c) => c.id == campaign.id);
    if (index == -1) {
      _pushCampaigns.add(campaign);
      return campaign;
    }
    _pushCampaigns[index] = campaign;
    return campaign;
  }

  @override
  void deletePushCampaign(int id) {
    _pushCampaigns.removeWhere((c) => c.id == id);
  }
}
