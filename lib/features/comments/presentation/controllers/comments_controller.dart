import 'package:app/features/comments/domain/entities/comentario.dart';
import 'package:app/features/comments/domain/usecases/comment_usecases.dart';

/// Controlador de comentarios; coordina casos de uso y expone operaciones para la capa de presentacion.
class CommentsController {
  final GetComentariosSyncUseCase _getComentariosSyncUseCase;
  final GetAllCommentsUseCase _getAllCommentsUseCase;
  final GetCommentsByPromotionUseCase _getCommentsByPromotionUseCase;
  final GetCommentsByUserUseCase _getCommentsByUserUseCase;
  final AddCommentUseCase _addCommentUseCase;
  final DeleteCommentUseCase _deleteCommentUseCase;

  CommentsController({
    required GetComentariosSyncUseCase getComentariosSyncUseCase,
    required GetAllCommentsUseCase getAllCommentsUseCase,
    required GetCommentsByPromotionUseCase getCommentsByPromotionUseCase,
    required GetCommentsByUserUseCase getCommentsByUserUseCase,
    required AddCommentUseCase addCommentUseCase,
    required DeleteCommentUseCase deleteCommentUseCase,
  }) : _getComentariosSyncUseCase = getComentariosSyncUseCase,
       _getAllCommentsUseCase = getAllCommentsUseCase,
       _getCommentsByPromotionUseCase = getCommentsByPromotionUseCase,
       _getCommentsByUserUseCase = getCommentsByUserUseCase,
       _addCommentUseCase = addCommentUseCase,
       _deleteCommentUseCase = deleteCommentUseCase;

  List<Comentario> getComentariosSync() => _getComentariosSyncUseCase.execute();
  List<Comentario> getComentariosByPromocionSync(String promotionCode) =>
      _getComentariosSyncUseCase
          .execute()
          .where((c) => c.codigoPromocion == promotionCode)
          .toList();
  List<Comentario> getComentariosByUsuarioSync(int userId) =>
      _getComentariosSyncUseCase
          .execute()
          .where((c) => c.idUsuario == userId)
          .toList();
  Future<List<Comentario>> getAllComments() => _getAllCommentsUseCase.execute();
  Future<List<Comentario>> getCommentsByPromotion(String promotionCode) =>
      _getCommentsByPromotionUseCase.execute(promotionCode);
  Future<List<Comentario>> getCommentsByUser(int userId) =>
      _getCommentsByUserUseCase.execute(userId);
  Future<void> addComment(Comentario comentario) =>
      _addCommentUseCase.execute(comentario);
  Future<void> deleteComment(int id) => _deleteCommentUseCase.execute(id);
}
