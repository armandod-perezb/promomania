import '../entities/comentario.dart';

abstract class CommentRepository {
  List<Comentario> getComentariosSync();
  Future<List<Comentario>> getAllComments();
  Future<List<Comentario>> getCommentsByPromotion(String promotionCode);
  Future<void> addComment(Comentario comentario);
  Future<void> deleteComment(int id);
}
