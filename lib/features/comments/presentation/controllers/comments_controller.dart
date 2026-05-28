import 'package:app/features/comments/domain/entities/comentario.dart';
import 'package:app/features/comments/domain/usecases/comment_usecases.dart';

class CommentsController {
  final GetComentariosSyncUseCase _getComentariosSyncUseCase;
  final GetAllCommentsUseCase _getAllCommentsUseCase;
  final GetCommentsByPromotionUseCase _getCommentsByPromotionUseCase;
  final AddCommentUseCase _addCommentUseCase;
  final DeleteCommentUseCase _deleteCommentUseCase;

  CommentsController({
    required GetComentariosSyncUseCase getComentariosSyncUseCase,
    required GetAllCommentsUseCase getAllCommentsUseCase,
    required GetCommentsByPromotionUseCase getCommentsByPromotionUseCase,
    required AddCommentUseCase addCommentUseCase,
    required DeleteCommentUseCase deleteCommentUseCase,
  })  : _getComentariosSyncUseCase = getComentariosSyncUseCase,
        _getAllCommentsUseCase = getAllCommentsUseCase,
        _getCommentsByPromotionUseCase = getCommentsByPromotionUseCase,
        _addCommentUseCase = addCommentUseCase,
        _deleteCommentUseCase = deleteCommentUseCase;

  List<Comentario> getComentariosSync() => _getComentariosSyncUseCase.execute();
  List<Comentario> getComentariosByPromocionSync(String promotionCode) =>
      _getComentariosSyncUseCase.execute().where((c) => c.codigoPromocion == promotionCode).toList();
  Future<List<Comentario>> getAllComments() => _getAllCommentsUseCase.execute();
  Future<List<Comentario>> getCommentsByPromotion(String promotionCode) =>
      _getCommentsByPromotionUseCase.execute(promotionCode);
  Future<void> addComment(Comentario comentario) => _addCommentUseCase.execute(comentario);
  Future<void> deleteComment(int id) => _deleteCommentUseCase.execute(id);
}
