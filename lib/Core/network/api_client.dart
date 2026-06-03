import 'dart:convert';
import 'dart:io';

import 'package:app/core/errors/exceptions.dart' as domain;
import 'package:app/core/network/api_exception.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// Cliente HTTP centralizado para la API REST del backend Django.
///
/// Usa el patrón Singleton (`ApiClient.instance`).
/// Después del login, llama a [setToken] para adjuntar el Bearer token
/// en todas las peticiones autenticadas.
///
/// URL base por plataforma:
///   - Android emulator : http://10.0.2.2:8001/api
///   - iOS simulator    : http://localhost:8001/api
///   - Dispositivo real : http://<IP-de-tu-máquina>:8001/api
///   - Web              : http://localhost:8001/api
class ApiClient {
  static final ApiClient instance = ApiClient._();
  ApiClient._();

  static String get baseUrl {
    if (kIsWeb) return 'https://backend-promomania.onrender.com/api';
    try {
      if (Platform.isAndroid)
        return 'https://backend-promomania.onrender.com/api';
    } catch (_) {}
    return 'https://backend-promomania.onrender.com/api';
  }

  String? _token;
  final http.Client _http = http.Client();

  void setToken(String? token) => _token = token;
  String? get token => _token;
  bool get hasToken => _token != null && _token!.isNotEmpty;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null && _token!.isNotEmpty) 'Authorization': 'Bearer $_token',
  };

  // ─── GET ────────────────────────────────────────────────────────────────

  Future<dynamic> get(String path) async {
    try {
      final res = await _http
          .get(Uri.parse('${baseUrl}$path'), headers: _headers)
          .timeout(const Duration(seconds: 30));
      return _handle(res);
    } on ApiRequestException {
      rethrow;
    } on domain.NetworkException {
      rethrow;
    } catch (e) {
      throw domain.NetworkException('Error de conexión: $e');
    }
  }

  // ─── POST ───────────────────────────────────────────────────────────────

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final res = await _http
          .post(
            Uri.parse('${baseUrl}$path'),
            headers: _headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));
      return _handle(res);
    } on ApiRequestException {
      rethrow;
    } on domain.NetworkException {
      rethrow;
    } catch (e) {
      throw domain.NetworkException('Error de conexión: $e');
    }
  }

  // ─── PUT ────────────────────────────────────────────────────────────────

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    try {
      final res = await _http
          .put(
            Uri.parse('${baseUrl}$path'),
            headers: _headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));
      return _handle(res);
    } on ApiRequestException {
      rethrow;
    } on domain.NetworkException {
      rethrow;
    } catch (e) {
      throw domain.NetworkException('Error de conexión: $e');
    }
  }

  // ─── PATCH ──────────────────────────────────────────────────────────────

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    try {
      final res = await _http
          .patch(
            Uri.parse('${baseUrl}$path'),
            headers: _headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));
      return _handle(res);
    } on ApiRequestException {
      rethrow;
    } on domain.NetworkException {
      rethrow;
    } catch (e) {
      throw domain.NetworkException('Error de conexión: $e');
    }
  }

  // ─── DELETE ─────────────────────────────────────────────────────────────

  Future<void> delete(String path) async {
    try {
      final res = await _http
          .delete(Uri.parse('${baseUrl}$path'), headers: _headers)
          .timeout(const Duration(seconds: 30));
      _handle(res);
    } on ApiRequestException {
      rethrow;
    } on domain.NetworkException {
      rethrow;
    } catch (e) {
      throw domain.NetworkException('Error de conexión: $e');
    }
  }

  // ─── Paginación ─────────────────────────────────────────────────────────

  /// Obtiene TODOS los resultados de un endpoint paginado siguiendo `next`.
  Future<List<dynamic>> getAllPages(String path) async {
    final results = <dynamic>[];
    String? nextUrl = '${baseUrl}$path';

    while (nextUrl != null) {
      try {
        final res = await _http
            .get(Uri.parse(nextUrl), headers: _headers)
            .timeout(const Duration(seconds: 30));
        final data = _handle(res);

        if (data is Map<String, dynamic> && data.containsKey('results')) {
          results.addAll(data['results'] as List);
          nextUrl = data['next'] as String?;
        } else if (data is List) {
          results.addAll(data);
          nextUrl = null;
        } else {
          nextUrl = null;
        }
      } catch (e) {
        if (results.isEmpty) rethrow;
        break;
      }
    }

    return results;
  }

  // ─── Respuesta ──────────────────────────────────────────────────────────

  dynamic _handle(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) return null;
      return json.decode(body);
    }

    String message;
    try {
      // Detectar si la respuesta es HTML (error de servidor/no encontrado)
      final trimmedBody = body.trim();
      if (trimmedBody.startsWith('<!DOCTYPE') ||
          trimmedBody.startsWith('<html') ||
          trimmedBody.contains('<head>') ||
          trimmedBody.toLowerCase().contains('page not found') ||
          trimmedBody.toLowerCase().contains('<title>')) {
        message =
            'No se pudo conectar al servidor. '
            'Verifica que el backend esté corriendo en $baseUrl';
      } else {
        final decoded = json.decode(body);
        if (decoded is Map) {
          message =
              decoded['detail']?.toString() ??
              decoded['error']?.toString() ??
              decoded['non_field_errors']?.toString() ??
              (decoded.isNotEmpty
                  ? decoded.values.first?.toString() ?? 'Error desconocido'
                  : 'Error desconocido');
        } else {
          message = body;
        }
      }
    } catch (_) {
      message = body.isNotEmpty ? body : 'Error ${response.statusCode}';
    }

    throw ApiRequestException(response.statusCode, message);
  }
}
