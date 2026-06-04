import 'package:flutter/foundation.dart';
import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/network/api_exception.dart';
import 'package:app/features/promotions/domain/entities/promocion.dart';
import 'package:app/features/promotions/domain/entities/promocion_horario.dart';
import 'package:app/features/promotions/domain/entities/supermercado.dart';

/// Contrato de fuente de datos de promociones; separa el origen concreto de la informacion del resto de la app.
abstract class RemoteAdminPromotionDataSource {
  Future<List<Promocion>> getAllPromotions();
  Future<Promocion?> getPromotionByCode(String codigo);
  Future<Promocion> createPromotion(Promocion promocion);
  Future<Promocion> updatePromotion(Promocion promocion);
  Future<void> deletePromotion(String codigo);
  Future<void> approvePromotion(String codigo);
  Future<void> rejectPromotion(String codigo);
  Future<void> incrementViews(String codigo);
  Future<PromocionHorario> createPromocionHorario(PromocionHorario horario);

  Future<List<Supermercado>> getAllSupermercados();
  Future<Supermercado> createSupermercado(Supermercado supermercado);
  Future<Supermercado> updateSupermercado(Supermercado supermercado);
  Future<void> deleteSupermercado(int id);
}

/// Fuente de datos de promociones; obtiene y transforma informacion desde servicios o almacenamiento local.
class ApiRemoteAdminPromotionDataSource
    implements RemoteAdminPromotionDataSource {
  final ApiClient _client;

  ApiRemoteAdminPromotionDataSource(this._client);

  @override
  Future<List<Promocion>> getAllPromotions() async {
    try {
      final all = await _client.getAllPages('/promociones/');
      return all
          .map((item) => _promocionFromApi(item as Map<String, dynamic>))
          .toList();
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<Promocion?> getPromotionByCode(String codigo) async {
    try {
      final data =
          await _client.get('/promociones/$codigo/') as Map<String, dynamic>;
      return _promocionFromApi(data);
    } on ApiRequestException catch (e) {
      if (e.statusCode == 404) return null;
      throw _mapApiException(e);
    }
  }

  @override
  Future<Promocion> createPromotion(Promocion promocion) async {
    try {
      final created =
          await _client.post('/promociones/', _promotionToApi(promocion))
              as Map<String, dynamic>;
      return _promocionFromApi(created);
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<Promocion> updatePromotion(Promocion promocion) async {
    try {
      final updated =
          await _client.patch(
                '/promociones/${promocion.codigo}/',
                _promotionToApi(promocion),
              )
              as Map<String, dynamic>;
      return _promocionFromApi(updated);
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<void> deletePromotion(String codigo) async {
    try {
      await _client.delete('/promociones/$codigo/');
    } on ApiRequestException catch (e) {
      if (e.statusCode == 404) return;
      throw _mapApiException(e);
    }
  }

  @override
  Future<void> approvePromotion(String codigo) async {
    try {
      await _client.patch('/promociones/$codigo/', {'estado': 'aprobada'});
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<void> rejectPromotion(String codigo) async {
    try {
      await _client.patch('/promociones/$codigo/', {'estado': 'rechazada'});
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<void> incrementViews(String codigo) async {
    final promo = await getPromotionByCode(codigo);
    if (promo == null) return;
    try {
      await _client.patch('/promociones/$codigo/', {
        'vistas': promo.vistas + 1,
      });
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<PromocionHorario> createPromocionHorario(
    PromocionHorario horario,
  ) async {
    try {
      final created =
          await _client.post(
                '/promociones-horarios/',
                _promocionHorarioToApi(horario),
              )
              as Map<String, dynamic>;
      return _promocionHorarioFromApi(created);
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<List<Supermercado>> getAllSupermercados() async {
    try {
      final all = await _client.getAllPages('/supermercados/');
      return all
          .map((item) => _supermercadoFromApi(item as Map<String, dynamic>))
          .toList();
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<Supermercado> createSupermercado(Supermercado supermercado) async {
    debugPrint(
      'DEBUG API - createSupermercado llamado: ${supermercado.nombre}',
    );
    try {
      final data = _supermercadoToApi(supermercado, includeId: false);
      debugPrint('DEBUG API - Enviando POST /supermercados/ con data: $data');

      final created =
          await _client.post('/supermercados/', data) as Map<String, dynamic>;

      debugPrint('DEBUG API - Respuesta recibida: $created');
      return _supermercadoFromApi(created);
    } on ApiRequestException catch (e) {
      debugPrint(
        'DEBUG API - ApiRequestException: ${e.statusCode} - ${e.message}',
      );
      throw _mapApiException(e);
    } catch (e) {
      debugPrint('DEBUG API - Error inesperado: $e');
      rethrow;
    }
  }

  @override
  Future<Supermercado> updateSupermercado(Supermercado supermercado) async {
    try {
      final updated =
          await _client.patch(
                '/supermercados/${supermercado.id}/',
                _supermercadoToApi(supermercado),
              )
              as Map<String, dynamic>;
      return _supermercadoFromApi(updated);
    } on ApiRequestException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<void> deleteSupermercado(int id) async {
    try {
      await _client.delete('/supermercados/$id/');
    } on ApiRequestException catch (e) {
      if (e.statusCode == 404) return;
      throw _mapApiException(e);
    }
  }

  Promocion _promocionFromApi(Map<String, dynamic> json) {
    return Promocion(
      codigo: _asString(json['codigo']),
      titulo: _asString(json['titulo'], fallback: 'Promoción'),
      descripcion: json['descripcion']?.toString(),
      precio: _asDouble(json['precio']),
      descuento: json['descuento'] == null ? null : _asInt(json['descuento']),
      condicionProducto: _asString(
        json['condicion_producto'],
        fallback: 'nuevo',
      ),
      ubicacion: json['ubicacion']?.toString(),
      url: json['url']?.toString(),
      foto: _sanitizeImageUrl(json['foto']),
      fotoEsLocal: json['foto_es_local'] as bool? ?? false,
      tipoVigencia: _asString(json['tipo_vigencia'], fallback: 'por_fecha'),
      fechaInicio: json['fecha_inicio']?.toString(),
      fechaFin: json['fecha_fin']?.toString(),
      estado: _normalizePromotionStatus(json['estado']),
      puntuacionOtorgada: json['puntuacion_otorgada'] as bool? ?? false,
      vistas: _asInt(json['vistas']),
      idUsuario: _asId(json['id_usuario'], 'id_usuario'),
      idSupermercado: _asId(json['id_supermercado'], 'id_supermercado'),
      idCategoria: _asId(json['id_categoria'], 'id_categoria'),
      idTipoPromocion: _asId(json['id_tipo_promocion'], 'id_tipo_promocion'),
      lat: json['lat'] == null ? null : _asDouble(json['lat']),
      lng: json['lng'] == null ? null : _asDouble(json['lng']),
    );
  }

  Supermercado _supermercadoFromApi(Map<String, dynamic> json) {
    return Supermercado(
      id: _asInt(json['id']),
      nombre: _asString(json['nombre'], fallback: 'Sin nombre'),
      direccion: json['direccion']?.toString(),
      ciudad: json['ciudad']?.toString(),
      estado: _asString(json['estado'], fallback: 'activo'),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> _promotionToApi(Promocion promocion) {
    // Validar que los IDs de claves foráneas sean válidos (> 0)
    if (promocion.idSupermercado <= 0) {
      throw ValidationException(
        'El supermercado seleccionado no es válido (ID: ${promocion.idSupermercado})',
      );
    }
    if (promocion.idCategoria <= 0) {
      throw ValidationException(
        'La categoría seleccionada no es válida (ID: ${promocion.idCategoria})',
      );
    }
    if (promocion.idTipoPromocion <= 0) {
      throw ValidationException(
        'El tipo de promoción seleccionado no es válido (ID: ${promocion.idTipoPromocion})',
      );
    }
    if (promocion.idUsuario <= 0) {
      throw ValidationException(
        'El usuario no es válido (ID: ${promocion.idUsuario})',
      );
    }

    return {
      'codigo': promocion.codigo,
      'titulo': promocion.titulo,
      'descripcion': promocion.descripcion,
      'precio': promocion.precio,
      'descuento': promocion.descuento,
      'condicion_producto': promocion.condicionProducto,
      'ubicacion': promocion.ubicacion,
      'url': promocion.url,
      'foto': promocion.foto,
      'foto_es_local': promocion.fotoEsLocal,
      'tipo_vigencia': promocion.tipoVigencia,
      'fecha_inicio': promocion.fechaInicio,
      'fecha_fin': promocion.fechaFin,
      'estado': promocion.estado,
      'puntuacion_otorgada': promocion.puntuacionOtorgada,
      'vistas': promocion.vistas,
      'id_usuario': promocion.idUsuario,
      'id_supermercado': promocion.idSupermercado,
      'id_categoria': promocion.idCategoria,
      'id_tipo_promocion': promocion.idTipoPromocion,
      'lat': promocion.lat,
      'lng': promocion.lng,
    };
  }

  Map<String, dynamic> _supermercadoToApi(
    Supermercado supermercado, {
    bool includeId = true,
  }) {
    return {
      if (includeId) 'id': supermercado.id,
      'nombre': supermercado.nombre,
      'direccion': supermercado.direccion,
      'ciudad': supermercado.ciudad,
      'estado': supermercado.estado,
    };
  }

  PromocionHorario _promocionHorarioFromApi(Map<String, dynamic> json) {
    return PromocionHorario(
      id: _asInt(json['id']),
      diaSemana: _asString(json['dia_semana']),
      horaInicio: _asString(json['hora_inicio']),
      horaFin: _asString(json['hora_fin']),
      codigoPromocion: _asString(json['codigo_promocion']),
    );
  }

  Map<String, dynamic> _promocionHorarioToApi(PromocionHorario horario) {
    if (horario.codigoPromocion.trim().isEmpty) {
      throw ValidationException('La promoción del horario no es válida.');
    }

    return {
      'dia_semana': horario.diaSemana,
      'hora_inicio': horario.horaInicio,
      'hora_fin': horario.horaFin,
      'codigo_promocion': horario.codigoPromocion,
    };
  }

  Exception _mapApiException(ApiRequestException e) {
    if (e.statusCode == 400) {
      return ValidationException(e.message);
    }
    if (e.statusCode == 401 || e.statusCode == 403) {
      return UnauthorizedException(
        'Tu sesión no es válida. Inicia sesión de nuevo.',
      );
    }
    return ServerException(e.message);
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  /// Método específico para IDs de claves foráneas.
  /// Lanza excepción si el valor es null o 0 para evitar IDs inválidos.
  static int _asId(dynamic value, String fieldName) {
    final result = _asInt(value, fallback: 0);
    if (result <= 0) {
      throw ValidationException(
        'ID inválido para $fieldName: $value (debe ser mayor que 0)',
      );
    }
    return result;
  }

  static double _asDouble(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    final normalized = value.toString().replaceAll(',', '.').trim();
    return double.tryParse(normalized) ?? fallback;
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static String? _sanitizeImageUrl(dynamic value) {
    if (value == null) return null;
    final url = value.toString().trim();
    if (url.isEmpty) return null;
    if (url.toLowerCase().contains('via.placeholder.com')) return null;
    return url;
  }

  static String _normalizePromotionStatus(dynamic value) {
    final raw = _asString(value, fallback: 'pendiente').toLowerCase();
    if (raw == 'approved' || raw == 'aprobado' || raw == 'aprobada') {
      return 'aprobada';
    }
    if (raw == 'rejected' || raw == 'rechazado' || raw == 'rechazada') {
      return 'rechazada';
    }
    if (raw == 'pending') return 'pendiente';
    return raw;
  }
}
