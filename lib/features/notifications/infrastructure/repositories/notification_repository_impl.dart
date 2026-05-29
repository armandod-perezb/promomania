import 'package:app/core/errors/exceptions.dart';
import 'package:app/features/notifications/domain/entities/notification_item.dart';
import 'package:app/features/notifications/domain/entities/push_campaign.dart';
import 'package:app/features/notifications/domain/entities/notification_summary.dart';
import 'package:app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:app/features/notifications/infrastructure/datasources/notification_datasource.dart';
import 'package:app/features/notifications/infrastructure/datasources/remote_notification_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource dataSource;
  final RemoteNotificationDataSource? remoteDataSource;

  NotificationRepositoryImpl(this.dataSource, {this.remoteDataSource});

  @override
  Future<NotificationSummary> getAdminSummary() async {
    if (remoteDataSource != null) {
      try {
        return await remoteDataSource!.getAdminSummary();
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    return dataSource.getAdminSummary();
  }

  @override
  Future<int> getReportesBadgeCount() async {
    if (remoteDataSource != null) {
      try {
        return await remoteDataSource!.getReportesBadgeCount();
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    return dataSource.getReportesBadgeCount();
  }

  @override
  Future<List<NotificationItem>> getAllNotifications() async {
    if (remoteDataSource != null) {
      try {
        final remote = await remoteDataSource!.getAllNotifications();
        return remote;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    return dataSource.getAllNotifications();
  }

  @override
  Future<NotificationItem> createNotification(NotificationItem item) async {
    if (remoteDataSource != null) {
      try {
        final created = await remoteDataSource!.createNotification(item);
        dataSource.createNotification(created);
        return created;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    return dataSource.createNotification(item);
  }

  @override
  Future<NotificationItem> updateNotification(NotificationItem item) async {
    if (remoteDataSource != null) {
      try {
        final updated = await remoteDataSource!.updateNotification(item);
        dataSource.updateNotification(updated);
        return updated;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    return dataSource.updateNotification(item);
  }

  @override
  Future<void> deleteNotification(int id) async {
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.deleteNotification(id);
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    dataSource.deleteNotification(id);
  }

  @override
  Future<List<PushCampaign>> getAllPushCampaigns() async {
    if (remoteDataSource != null) {
      try {
        return await remoteDataSource!.getAllPushCampaigns();
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    return dataSource.getAllPushCampaigns();
  }

  @override
  Future<PushCampaign> createPushCampaign(PushCampaign campaign) async {
    if (remoteDataSource != null) {
      try {
        final created = await remoteDataSource!.createPushCampaign(campaign);
        dataSource.createPushCampaign(created);
        return created;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    return dataSource.createPushCampaign(campaign);
  }

  @override
  Future<PushCampaign> updatePushCampaign(PushCampaign campaign) async {
    if (remoteDataSource != null) {
      try {
        final updated = await remoteDataSource!.updatePushCampaign(campaign);
        dataSource.updatePushCampaign(updated);
        return updated;
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    return dataSource.updatePushCampaign(campaign);
  }

  @override
  Future<void> deletePushCampaign(int id) async {
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.deletePushCampaign(id);
      } catch (e) {
        if (!_shouldFallbackToLocal(e)) rethrow;
      }
    }
    dataSource.deletePushCampaign(id);
  }

  bool _shouldFallbackToLocal(Object error) {
    return error is NetworkException;
  }
}
