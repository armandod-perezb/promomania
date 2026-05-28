import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/network/api_exception.dart';
import 'package:app/features/interactions/domain/entities/favorito.dart';

abstract class RemoteFavoriteDataSource {
  Future<List<Favorito>> getFavoritosByUsuario(int userId);
  Future<Favorito?> findFavorito(int userId, String promotionCode);
  Future<Favorito> addFavorito(int userId, String promotionCode);
  Future<void> deleteFavorito(int favoritoId);
}

class ApiRemoteFavoriteDataSource implements RemoteFavoriteDataSource {
  final ApiClient _client;

  ApiRemoteFavoriteDataSource(this._client);

  @override
  Future<List<Favorito>> getFavoritosByUsuario(int userId) async {
    try {
      final all = await _client.getAllPages('/favoritos/');
      return all
          .map((item) => _favoritoFromApi(item as Map<String, dynamic>))
          .where((fav) => fav.idUsuario == userId)
          .toList();
    } on ApiRequestException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        throw UnauthorizedException('Tu sesión no es válida. Inicia sesión de nuevo.');
      }
      throw ServerException(e.message);
    }
  }

  @override
  Future<Favorito?> findFavorito(int userId, String promotionCode) async {
    final favoritos = await getFavoritosByUsuario(userId);
    for (final favorito in favoritos) {
      if (favorito.codigoPromocion == promotionCode) {
        return favorito;
      }
    }
    return null;
  }

  @override
  Future<Favorito> addFavorito(int userId, String promotionCode) async {
    try {
      final created = await _client.post('/favoritos/', {
        'id_usuario': userId,
        'codigo_promocion': promotionCode,
        'fecha': DateTime.now().toIso8601String(),
      }) as Map<String, dynamic>;
      return _favoritoFromApi(created);
    } on ApiRequestException catch (e) {
      if (e.statusCode == 400) {
        final existing = await findFavorito(userId, promotionCode);
        if (existing != null) {
          return existing;
        }
        throw ValidationException(e.message);
      }
      if (e.statusCode == 401 || e.statusCode == 403) {
        throw UnauthorizedException('Tu sesión no es válida. Inicia sesión de nuevo.');
      }
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> deleteFavorito(int favoritoId) async {
    try {
      await _client.delete('/favoritos/$favoritoId/');
    } on ApiRequestException catch (e) {
      if (e.statusCode == 404) {
        return;
      }
      if (e.statusCode == 401 || e.statusCode == 403) {
        throw UnauthorizedException('Tu sesión no es válida. Inicia sesión de nuevo.');
      }
      throw ServerException(e.message);
    }
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

  Favorito _favoritoFromApi(Map<String, dynamic> json) {
    return Favorito(
      id: _asInt(json['id']),
      idUsuario: _asInt(json['id_usuario']),
      codigoPromocion: _asString(json['codigo_promocion']),
      fecha: _asString(json['fecha']),
    );
  }
}
