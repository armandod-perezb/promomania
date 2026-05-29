import '../entities/notification_summary.dart';
import '../entities/notification_item.dart';
import '../entities/push_campaign.dart';

abstract class NotificationRepository {
  Future<NotificationSummary> getAdminSummary();
  Future<int> getReportesBadgeCount();
  Future<List<NotificationItem>> getAllNotifications();
  Future<NotificationItem> createNotification(NotificationItem item);
  Future<NotificationItem> updateNotification(NotificationItem item);
  Future<void> deleteNotification(int id);

  Future<List<PushCampaign>> getAllPushCampaigns();
  Future<PushCampaign> createPushCampaign(PushCampaign campaign);
  Future<PushCampaign> updatePushCampaign(PushCampaign campaign);
  Future<void> deletePushCampaign(int id);
}
