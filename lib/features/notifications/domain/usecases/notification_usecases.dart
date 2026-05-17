import '../entities/notification_summary.dart';
import '../repositories/notification_repository.dart';

class GetAdminNotificationSummaryUseCase {
  final NotificationRepository repository;

  GetAdminNotificationSummaryUseCase(this.repository);

  Future<NotificationSummary> execute() {
    return repository.getAdminSummary();
  }
}

class GetReportesBadgeCountUseCase {
  final NotificationRepository repository;

  GetReportesBadgeCountUseCase(this.repository);

  Future<int> execute() {
    return repository.getReportesBadgeCount();
  }
}
