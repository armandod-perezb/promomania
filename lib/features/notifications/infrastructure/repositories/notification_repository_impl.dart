import 'package:app/features/notifications/domain/entities/notification_summary.dart';
import 'package:app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:app/features/notifications/infrastructure/datasources/notification_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource dataSource;

  NotificationRepositoryImpl(this.dataSource);

  @override
  Future<NotificationSummary> getAdminSummary() async {
    return dataSource.getAdminSummary();
  }

  @override
  Future<int> getReportesBadgeCount() async {
    return dataSource.getReportesBadgeCount();
  }
}
