import 'package:app/features/notifications/domain/entities/notification_summary.dart';
import 'package:app/features/notifications/domain/usecases/notification_usecases.dart';

class NotificationsController {
  final GetAdminNotificationSummaryUseCase _getAdminSummaryUseCase;
  final GetReportesBadgeCountUseCase _getReportesBadgeCountUseCase;

  NotificationsController({
    required GetAdminNotificationSummaryUseCase getAdminSummaryUseCase,
    required GetReportesBadgeCountUseCase getReportesBadgeCountUseCase,
  }) : _getAdminSummaryUseCase = getAdminSummaryUseCase,
       _getReportesBadgeCountUseCase = getReportesBadgeCountUseCase;

  Future<NotificationSummary> getAdminSummary() {
    return _getAdminSummaryUseCase.execute();
  }

  Future<int> getReportesBadgeCount() {
    return _getReportesBadgeCountUseCase.execute();
  }
}
