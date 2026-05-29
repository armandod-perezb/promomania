import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/network/api_exception.dart';
import 'package:app/features/moderation/domain/entities/reporte.dart';

abstract class RemoteModerationDataSource {
  Future<List<Reporte>> getAllReportes();
  Future<List<Reporte>> getReportesByUsuario(int userId);
  Future<List<Reporte>> getReportesByPromocion(String promotionCode);
  Future<Reporte> addReporte(Reporte reporte);
  Future<Reporte> updateReporte(Reporte reporte);
  Future<void> deleteReporte(int id);
}

class ApiRemoteModerationDataSource implements RemoteModerationDataSource {
  final ApiClient _client;

  ApiRemoteModerationDataSource(this._client);

  @override
  Future<List<Reporte>> getAllReportes() async {
    try {
      final all = await _client.getAllPages('/reportes/');
      return all.map((item) => _reporteFromApi(item as Map<String, dynamic>)).toList();
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<List<Reporte>> getReportesByUsuario(int userId) async {
    final all = await getAllReportes();
    return all.where((r) => r.idUsuario == userId).toList();
  }

  @override
  Future<List<Reporte>> getReportesByPromocion(String promotionCode) async {
    final all = await getAllReportes();
    return all.where((r) => r.codigoPromocion == promotionCode).toList();
  }

  @override
  Future<Reporte> addReporte(Reporte reporte) async {
    try {
      final created = await _client.post('/reportes/', _reporteToApi(reporte))
          as Map<String, dynamic>;
      return _reporteFromApi(created);
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<Reporte> updateReporte(Reporte reporte) async {
    try {
      final updated = await _client.patch(
            '/reportes/${reporte.id}/',
            _reporteToApi(reporte),
          )
          as Map<String, dynamic>;
      return _reporteFromApi(updated);
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<void> deleteReporte(int id) async {
    try {
      await _client.delete('/reportes/$id/');
    } on ApiRequestException catch (e) {
      if (e.statusCode == 404) return;
      throw _mapApiException(e);
    }
  }

  Reporte _reporteFromApi(Map<String, dynamic> json) {
    return Reporte(
      id: _asInt(json['id']),
      motivo: _asString(json['motivo']),
      fecha: _asString(json['fecha']),
      estado: _asString(json['estado'], fallback: 'pendiente'),
      idUsuario: _asInt(json['id_usuario']),
      codigoPromocion: _asString(json['codigo_promocion']),
    );
  }

  Map<String, dynamic> _reporteToApi(Reporte reporte) {
    return {
      'id': reporte.id,
      'motivo': reporte.motivo,
      'fecha': reporte.fecha,
      'estado': reporte.estado,
      'id_usuario': reporte.idUsuario,
      'codigo_promocion': reporte.codigoPromocion,
    };
  }

  Exception _mapApiException(ApiRequestException e) {
    if (e.statusCode == 400) return ValidationException(e.message);
    if (e.statusCode == 401 || e.statusCode == 403) {
      return UnauthorizedException('Tu sesión no es válida. Inicia sesión de nuevo.');
    }
    return ServerException(e.message);
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }
}
