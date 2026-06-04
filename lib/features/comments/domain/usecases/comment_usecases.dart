import '../entities/comentario.dart';
import '../repositories/comment_repository.dart';

class GetComentariosSyncUseCase {
  final CommentRepository repository;
  GetComentariosSyncUseCase(this.repository);
  List<Comentario> execute() => repository.getComentariosSync();
}

class GetAllCommentsUseCase {
  final CommentRepository repository;

  GetAllCommentsUseCase(this.repository);

  Future<List<Comentario>> execute() {
    return repository.getAllComments();
  }
}

class GetCommentsByPromotionUseCase {
  final CommentRepository repository;

  GetCommentsByPromotionUseCase(this.repository);

  Future<List<Comentario>> execute(String promotionCode) {
    return repository.getCommentsByPromotion(promotionCode);
  }
}

class GetCommentsByUserUseCase {
  final CommentRepository repository;

  GetCommentsByUserUseCase(this.repository);

  Future<List<Comentario>> execute(int userId) {
    return repository.getCommentsByUser(userId);
  }
}

class AddCommentUseCase {
  final CommentRepository repository;

  AddCommentUseCase(this.repository);

  Future<void> execute(Comentario comentario) {
    return repository.addComment(comentario);
  }
}

class DeleteCommentUseCase {
  final CommentRepository repository;

  DeleteCommentUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deleteComment(id);
  }
}
