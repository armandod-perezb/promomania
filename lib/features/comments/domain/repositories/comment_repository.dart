import '../entities/comentario.dart';

/// Contrato de repositorio de comentarios; define las operaciones que consume la capa de dominio.
abstract class CommentRepository {
  List<Comentario> getComentariosSync();
  Future<List<Comentario>> getAllComments();
  Future<List<Comentario>> getCommentsByPromotion(String promotionCode);
  Future<List<Comentario>> getCommentsByUser(int userId);
  Future<void> addComment(Comentario comentario);
  Future<void> deleteComment(int id);
}
