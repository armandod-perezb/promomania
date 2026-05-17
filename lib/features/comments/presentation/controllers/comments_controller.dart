import 'package:app/features/comments/domain/entities/comentario.dart';
import 'package:app/features/comments/domain/usecases/comment_usecases.dart';

class CommentsController {
  final GetAllCommentsUseCase _getAllCommentsUseCase;
  final GetCommentsByPromotionUseCase _getCommentsByPromotionUseCase;
  final AddCommentUseCase _addCommentUseCase;
  final DeleteCommentUseCase _deleteCommentUseCase;

  CommentsController({
    required GetAllCommentsUseCase getAllCommentsUseCase,
    required GetCommentsByPromotionUseCase getCommentsByPromotionUseCase,
    required AddCommentUseCase addCommentUseCase,
    required DeleteCommentUseCase deleteCommentUseCase,
  }) : _getAllCommentsUseCase = getAllCommentsUseCase,
       _getCommentsByPromotionUseCase = getCommentsByPromotionUseCase,
       _addCommentUseCase = addCommentUseCase,
       _deleteCommentUseCase = deleteCommentUseCase;

  Future<List<Comentario>> getAllComments() {
    return _getAllCommentsUseCase.execute();
  }

  Future<List<Comentario>> getCommentsByPromotion(String promotionCode) {
    return _getCommentsByPromotionUseCase.execute(promotionCode);
  }

  Future<void> addComment(Comentario comentario) {
    return _addCommentUseCase.execute(comentario);
  }

  Future<void> deleteComment(int id) {
    return _deleteCommentUseCase.execute(id);
  }
}
