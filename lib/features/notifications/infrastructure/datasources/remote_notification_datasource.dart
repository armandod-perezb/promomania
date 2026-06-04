import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/network/api_exception.dart';
import 'package:app/features/notifications/domain/entities/notification_item.dart';
import 'package:app/features/notifications/domain/entities/notification_summary.dart';
import 'package:app/features/notifications/domain/entities/push_campaign.dart';

/// Contrato de fuente de datos de notificaciones; separa el origen concreto de la informacion del resto de la app.
abstract class RemoteNotificationDataSource {
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

/// Fuente de datos de notificaciones; obtiene y transforma informacion desde servicios o almacenamiento local.
class ApiRemoteNotificationDataSource implements RemoteNotificationDataSource {
  final ApiClient _client;

  ApiRemoteNotificationDataSource(this._client);

  @override
  Future<NotificationSummary> getAdminSummary() async {
    try {
      final results = await Future.wait([
        _client.getAllPages('/reportes/'),
        _client.getAllPages('/promociones/'),
        _client.getAllPages('/usuarios/'),
        _client.getAllPages('/comentarios/'),
      ]);
      final reportes = results[0];
      final promociones = results[1];
      final usuarios = results[2];
      final comentarios = results[3];
      final promocionesPendientes = promociones
          .where(
            (p) =>
                _asString(
                  (p as Map<String, dynamic>)['estado'],
                ).toLowerCase() ==
                'pendiente',
          )
          .length;
      return NotificationSummary(
        reportesPendientes: reportes.length,
        promocionesPendientes: promocionesPendientes,
        totalUsuarios: usuarios.length,
        totalComentarios: comentarios.length,
        generatedAt: DateTime.now(),
      );
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<int> getReportesBadgeCount() async {
    try {
      final reportes = await _client.getAllPages('/reportes/');
      return reportes.length;
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<List<NotificationItem>> getAllNotifications() async {
    try {
      final all = await _client.getAllPages('/notificaciones/');
      return all
          .map((item) => _notificationFromApi(item as Map<String, dynamic>))
          .toList();
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<NotificationItem> createNotification(NotificationItem item) async {
    try {
      final created =
          await _client.post('/notificaciones/', _notificationToApi(item))
              as Map<String, dynamic>;
      return _notificationFromApi(created);
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<NotificationItem> updateNotification(NotificationItem item) async {
    try {
      final updated =
          await _client.patch(
                '/notificaciones/${item.id}/',
                _notificationToApi(item),
              )
              as Map<String, dynamic>;
      return _notificationFromApi(updated);
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<void> deleteNotification(int id) async {
    try {
      await _client.delete('/notificaciones/$id/');
    } on ApiRequestException catch (e) {
      if (e.statusCode == 404) return;
      throw _mapApiException(e);
    }
  }

  @override
  Future<List<PushCampaign>> getAllPushCampaigns() async {
    try {
      final all = await _client.getAllPages('/notificaciones-push/');
      return all
          .map((item) => _pushFromApi(item as Map<String, dynamic>))
          .toList();
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<PushCampaign> createPushCampaign(PushCampaign campaign) async {
    try {
      final created =
          await _client.post('/notificaciones-push/', _pushToApi(campaign))
              as Map<String, dynamic>;
      return _pushFromApi(created);
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<PushCampaign> updatePushCampaign(PushCampaign campaign) async {
    try {
      final updated =
          await _client.patch(
                '/notificaciones-push/${campaign.id}/',
                _pushToApi(campaign),
              )
              as Map<String, dynamic>;
      return _pushFromApi(updated);
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<void> deletePushCampaign(int id) async {
    try {
      await _client.delete('/notificaciones-push/$id/');
    } on ApiRequestException catch (e) {
      if (e.statusCode == 404) return;
      throw _mapApiException(e);
    }
  }

  NotificationItem _notificationFromApi(Map<String, dynamic> json) {
    return NotificationItem(
      id: _asInt(json['id']),
      titulo: _asString(json['titulo']),
      mensaje: _asString(json['mensaje']),
      tipo: _asString(json['tipo'], fallback: 'general'),
      estado: _asString(json['estado'], fallback: 'pendiente'),
      fechaProgramada: _parseDate(json['fecha_programada']),
      enviadoEn: _parseDate(json['enviado_en']),
    );
  }

  PushCampaign _pushFromApi(Map<String, dynamic> json) {
    return PushCampaign(
      id: _asInt(json['id']),
      titulo: _asString(json['titulo']),
      mensaje: _asString(json['mensaje']),
      estado: _asString(json['estado'], fallback: 'borrador'),
      enviados: _asInt(json['enviados']),
      aperturas: _asInt(json['aperturas']),
      clicks: _asInt(json['clicks']),
      programadaEn: _parseDate(json['programada_en']),
      enviadaEn: _parseDate(json['enviada_en']),
    );
  }

  Map<String, dynamic> _notificationToApi(NotificationItem item) {
    return {
      'id': item.id,
      'titulo': item.titulo,
      'mensaje': item.mensaje,
      'tipo': item.tipo,
      'estado': item.estado,
      'fecha_programada': item.fechaProgramada?.toIso8601String(),
      'enviado_en': item.enviadoEn?.toIso8601String(),
    };
  }

  Map<String, dynamic> _pushToApi(PushCampaign campaign) {
    return {
      'id': campaign.id,
      'titulo': campaign.titulo,
      'mensaje': campaign.mensaje,
      'estado': campaign.estado,
      'enviados': campaign.enviados,
      'aperturas': campaign.aperturas,
      'clicks': campaign.clicks,
      'programada_en': campaign.programadaEn?.toIso8601String(),
      'enviada_en': campaign.enviadaEn?.toIso8601String(),
    };
  }

  Exception _mapApiException(ApiRequestException e) {
    if (e.statusCode == 400) return ValidationException(e.message);
    if (e.statusCode == 401 || e.statusCode == 403) {
      return UnauthorizedException(
        'Tu sesión no es válida. Inicia sesión de nuevo.',
      );
    }
    return ServerException(e.message);
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
