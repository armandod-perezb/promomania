import 'package:app/features/comments/domain/entities/comentario.dart';
import 'package:app/features/comments/domain/repositories/comment_repository.dart';
import 'package:app/features/comments/infrastructure/datasources/comment_datasource.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentDataSource dataSource;

  CommentRepositoryImpl(this.dataSource);

  @override
  List<Comentario> getComentariosSync() => dataSource.getAllComments();

  @override
  Future<List<Comentario>> getAllComments() async {
    return dataSource.getAllComments();
  }

  @override
  Future<List<Comentario>> getCommentsByPromotion(String promotionCode) async {
    return dataSource.getCommentsByPromotion(promotionCode);
  }

  @override
  Future<void> addComment(Comentario comentario) async {
    dataSource.addComment(comentario);
  }

  @override
  Future<void> deleteComment(int id) async {
    dataSource.deleteComment(id);
  }
}
