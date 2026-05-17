import '../entities/notification_summary.dart';

abstract class NotificationRepository {
  Future<NotificationSummary> getAdminSummary();
  Future<int> getReportesBadgeCount();
}
