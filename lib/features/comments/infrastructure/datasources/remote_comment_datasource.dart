import 'package:app/core/errors/exceptions.dart';
import 'package:app/core/network/api_client.dart';
import 'package:app/core/network/api_exception.dart';
import 'package:app/features/comments/domain/entities/comentario.dart';

abstract class RemoteCommentDataSource {
  Future<List<Comentario>> getAllComments();
  Future<List<Comentario>> getCommentsByPromotion(String promotionCode);
  Future<Comentario> addComment(Comentario comentario);
  Future<void> deleteComment(int id);
}

class ApiRemoteCommentDataSource implements RemoteCommentDataSource {
  final ApiClient _client;

  ApiRemoteCommentDataSource(this._client);

  @override
  Future<List<Comentario>> getAllComments() async {
    try {
      final data = await _client.getAllPages('/comentarios/');
      return data
          .map((item) => _comentarioFromApi(item as Map<String, dynamic>))
          .toList();
    } on ApiRequestException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        throw UnauthorizedException('Tu sesión no es válida. Inicia sesión de nuevo.');
      }
      throw ServerException(e.message);
    }
  }

  @override
  Future<List<Comentario>> getCommentsByPromotion(String promotionCode) async {
    final all = await getAllComments();
    return all.where((c) => c.codigoPromocion == promotionCode).toList();
  }

  @override
  Future<Comentario> addComment(Comentario comentario) async {
    try {
      final created = await _client.post('/comentarios/', {
        'contenido': comentario.contenido,
        'fecha': comentario.fecha,
        'id_usuario': comentario.idUsuario,
        'codigo_promocion': comentario.codigoPromocion,
        'id_comment_reply': comentario.idCommentReply,
      }) as Map<String, dynamic>;
      return _comentarioFromApi(created);
    } on ApiRequestException catch (e) {
      if (e.statusCode == 400) throw ValidationException(e.message);
      if (e.statusCode == 401 || e.statusCode == 403) {
        throw UnauthorizedException('Tu sesión no es válida. Inicia sesión de nuevo.');
      }
      throw ServerException(e.message);
    }
  }

  @override
  Future<void> deleteComment(int id) async {
    try {
      await _client.delete('/comentarios/$id/');
    } on ApiRequestException catch (e) {
      if (e.statusCode == 404) return;
      if (e.statusCode == 401 || e.statusCode == 403) {
        throw UnauthorizedException('Tu sesión no es válida. Inicia sesión de nuevo.');
      }
      throw ServerException(e.message);
    }
  }

  Comentario _comentarioFromApi(Map<String, dynamic> json) {
    return Comentario(
      id: (json['id'] as num).toInt(),
      contenido: json['contenido'].toString(),
      fecha: json['fecha'].toString(),
      idUsuario: (json['id_usuario'] as num).toInt(),
      codigoPromocion: json['codigo_promocion'].toString(),
      idCommentReply: json['id_comment_reply'] == null
          ? null
          : (json['id_comment_reply'] as num).toInt(),
    );
  }
}
