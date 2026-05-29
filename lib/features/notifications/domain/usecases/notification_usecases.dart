import '../entities/notification_summary.dart';
import '../entities/notification_item.dart';
import '../entities/push_campaign.dart';
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

class GetAllNotificationsUseCase {
  final NotificationRepository repository;

  GetAllNotificationsUseCase(this.repository);

  Future<List<NotificationItem>> execute() {
    return repository.getAllNotifications();
  }
}

class CreateNotificationUseCase {
  final NotificationRepository repository;

  CreateNotificationUseCase(this.repository);

  Future<NotificationItem> execute(NotificationItem item) {
    return repository.createNotification(item);
  }
}

class UpdateNotificationUseCase {
  final NotificationRepository repository;

  UpdateNotificationUseCase(this.repository);

  Future<NotificationItem> execute(NotificationItem item) {
    return repository.updateNotification(item);
  }
}

class DeleteNotificationUseCase {
  final NotificationRepository repository;

  DeleteNotificationUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deleteNotification(id);
  }
}

class GetAllPushCampaignsUseCase {
  final NotificationRepository repository;

  GetAllPushCampaignsUseCase(this.repository);

  Future<List<PushCampaign>> execute() {
    return repository.getAllPushCampaigns();
  }
}

class CreatePushCampaignUseCase {
  final NotificationRepository repository;

  CreatePushCampaignUseCase(this.repository);

  Future<PushCampaign> execute(PushCampaign campaign) {
    return repository.createPushCampaign(campaign);
  }
}

class UpdatePushCampaignUseCase {
  final NotificationRepository repository;

  UpdatePushCampaignUseCase(this.repository);

  Future<PushCampaign> execute(PushCampaign campaign) {
    return repository.updatePushCampaign(campaign);
  }
}

class DeletePushCampaignUseCase {
  final NotificationRepository repository;

  DeletePushCampaignUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deletePushCampaign(id);
  }
}
