import '../entities/notification_summary.dart';
import '../entities/notification_item.dart';
import '../entities/push_campaign.dart';
import '../repositories/notification_repository.dart';

/// Caso de uso para GetAdminNotificationSummary; mantiene la regla de negocio fuera de la interfaz.
class GetAdminNotificationSummaryUseCase {
  final NotificationRepository repository;

  GetAdminNotificationSummaryUseCase(this.repository);

  Future<NotificationSummary> execute() {
    return repository.getAdminSummary();
  }
}

/// Caso de uso para GetReportesBadgeCount; mantiene la regla de negocio fuera de la interfaz.
class GetReportesBadgeCountUseCase {
  final NotificationRepository repository;

  GetReportesBadgeCountUseCase(this.repository);

  Future<int> execute() {
    return repository.getReportesBadgeCount();
  }
}

/// Caso de uso para GetAllNotifications; mantiene la regla de negocio fuera de la interfaz.
class GetAllNotificationsUseCase {
  final NotificationRepository repository;

  GetAllNotificationsUseCase(this.repository);

  Future<List<NotificationItem>> execute() {
    return repository.getAllNotifications();
  }
}

/// Caso de uso para CreateNotification; mantiene la regla de negocio fuera de la interfaz.
class CreateNotificationUseCase {
  final NotificationRepository repository;

  CreateNotificationUseCase(this.repository);

  Future<NotificationItem> execute(NotificationItem item) {
    return repository.createNotification(item);
  }
}

/// Caso de uso para UpdateNotification; mantiene la regla de negocio fuera de la interfaz.
class UpdateNotificationUseCase {
  final NotificationRepository repository;

  UpdateNotificationUseCase(this.repository);

  Future<NotificationItem> execute(NotificationItem item) {
    return repository.updateNotification(item);
  }
}

/// Caso de uso para eliminar una notificacion; mantiene la regla de negocio fuera de la interfaz.
class DeleteNotificationUseCase {
  final NotificationRepository repository;

  DeleteNotificationUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deleteNotification(id);
  }
}

/// Caso de uso para GetAllPushCampaigns; mantiene la regla de negocio fuera de la interfaz.
class GetAllPushCampaignsUseCase {
  final NotificationRepository repository;

  GetAllPushCampaignsUseCase(this.repository);

  Future<List<PushCampaign>> execute() {
    return repository.getAllPushCampaigns();
  }
}

/// Caso de uso para crear una campana push; mantiene la regla de negocio fuera de la interfaz.
class CreatePushCampaignUseCase {
  final NotificationRepository repository;

  CreatePushCampaignUseCase(this.repository);

  Future<PushCampaign> execute(PushCampaign campaign) {
    return repository.createPushCampaign(campaign);
  }
}

/// Caso de uso para UpdatePushCampaign; mantiene la regla de negocio fuera de la interfaz.
class UpdatePushCampaignUseCase {
  final NotificationRepository repository;

  UpdatePushCampaignUseCase(this.repository);

  Future<PushCampaign> execute(PushCampaign campaign) {
    return repository.updatePushCampaign(campaign);
  }
}

/// Caso de uso para eliminar una campana push; mantiene la regla de negocio fuera de la interfaz.
class DeletePushCampaignUseCase {
  final NotificationRepository repository;

  DeletePushCampaignUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deletePushCampaign(id);
  }
}
