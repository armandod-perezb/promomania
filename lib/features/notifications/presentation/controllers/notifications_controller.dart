import 'package:app/features/notifications/domain/entities/notification_item.dart';
import 'package:app/features/notifications/domain/entities/push_campaign.dart';
import 'package:app/features/notifications/domain/entities/notification_summary.dart';
import 'package:app/features/notifications/domain/usecases/notification_usecases.dart';

/// Controlador de notificaciones; coordina casos de uso y expone operaciones para la capa de presentacion.
class NotificationsController {
  final GetAdminNotificationSummaryUseCase _getAdminSummaryUseCase;
  final GetReportesBadgeCountUseCase _getReportesBadgeCountUseCase;
  final GetAllNotificationsUseCase _getAllNotificationsUseCase;
  final CreateNotificationUseCase _createNotificationUseCase;
  final UpdateNotificationUseCase _updateNotificationUseCase;
  final DeleteNotificationUseCase _deleteNotificationUseCase;
  final GetAllPushCampaignsUseCase _getAllPushCampaignsUseCase;
  final CreatePushCampaignUseCase _createPushCampaignUseCase;
  final UpdatePushCampaignUseCase _updatePushCampaignUseCase;
  final DeletePushCampaignUseCase _deletePushCampaignUseCase;

  NotificationsController({
    required GetAdminNotificationSummaryUseCase getAdminSummaryUseCase,
    required GetReportesBadgeCountUseCase getReportesBadgeCountUseCase,
    required GetAllNotificationsUseCase getAllNotificationsUseCase,
    required CreateNotificationUseCase createNotificationUseCase,
    required UpdateNotificationUseCase updateNotificationUseCase,
    required DeleteNotificationUseCase deleteNotificationUseCase,
    required GetAllPushCampaignsUseCase getAllPushCampaignsUseCase,
    required CreatePushCampaignUseCase createPushCampaignUseCase,
    required UpdatePushCampaignUseCase updatePushCampaignUseCase,
    required DeletePushCampaignUseCase deletePushCampaignUseCase,
  }) : _getAdminSummaryUseCase = getAdminSummaryUseCase,
       _getReportesBadgeCountUseCase = getReportesBadgeCountUseCase,
       _getAllNotificationsUseCase = getAllNotificationsUseCase,
       _createNotificationUseCase = createNotificationUseCase,
       _updateNotificationUseCase = updateNotificationUseCase,
       _deleteNotificationUseCase = deleteNotificationUseCase,
       _getAllPushCampaignsUseCase = getAllPushCampaignsUseCase,
       _createPushCampaignUseCase = createPushCampaignUseCase,
       _updatePushCampaignUseCase = updatePushCampaignUseCase,
       _deletePushCampaignUseCase = deletePushCampaignUseCase;

  Future<NotificationSummary> getAdminSummary() {
    return _getAdminSummaryUseCase.execute();
  }

  Future<int> getReportesBadgeCount() {
    return _getReportesBadgeCountUseCase.execute();
  }

  Future<List<NotificationItem>> getAllNotifications() {
    return _getAllNotificationsUseCase.execute();
  }

  Future<NotificationItem> createNotification(NotificationItem item) {
    return _createNotificationUseCase.execute(item);
  }

  Future<NotificationItem> updateNotification(NotificationItem item) {
    return _updateNotificationUseCase.execute(item);
  }

  Future<void> deleteNotification(int id) {
    return _deleteNotificationUseCase.execute(id);
  }

  Future<List<PushCampaign>> getAllPushCampaigns() {
    return _getAllPushCampaignsUseCase.execute();
  }

  Future<PushCampaign> createPushCampaign(PushCampaign campaign) {
    return _createPushCampaignUseCase.execute(campaign);
  }

  Future<PushCampaign> updatePushCampaign(PushCampaign campaign) {
    return _updatePushCampaignUseCase.execute(campaign);
  }

  Future<void> deletePushCampaign(int id) {
    return _deletePushCampaignUseCase.execute(id);
  }
}
