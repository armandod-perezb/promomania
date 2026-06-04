import '../entities/comentario.dart';
import '../repositories/comment_repository.dart';

/// Caso de uso para obtener comentarios desde cache local; mantiene la regla de negocio fuera de la interfaz.
class GetComentariosSyncUseCase {
  final CommentRepository repository;
  GetComentariosSyncUseCase(this.repository);
  List<Comentario> execute() => repository.getComentariosSync();
}

/// Caso de uso para obtener todos los comentarios; mantiene la regla de negocio fuera de la interfaz.
class GetAllCommentsUseCase {
  final CommentRepository repository;

  GetAllCommentsUseCase(this.repository);

  Future<List<Comentario>> execute() {
    return repository.getAllComments();
  }
}

/// Caso de uso para obtener comentarios de una promocion; mantiene la regla de negocio fuera de la interfaz.
class GetCommentsByPromotionUseCase {
  final CommentRepository repository;

  GetCommentsByPromotionUseCase(this.repository);

  Future<List<Comentario>> execute(String promotionCode) {
    return repository.getCommentsByPromotion(promotionCode);
  }
}

/// Caso de uso para obtener comentarios de un usuario; mantiene la regla de negocio fuera de la interfaz.
class GetCommentsByUserUseCase {
  final CommentRepository repository;

  GetCommentsByUserUseCase(this.repository);

  Future<List<Comentario>> execute(int userId) {
    return repository.getCommentsByUser(userId);
  }
}

/// Caso de uso para agregar un comentario; mantiene la regla de negocio fuera de la interfaz.
class AddCommentUseCase {
  final CommentRepository repository;

  AddCommentUseCase(this.repository);

  Future<void> execute(Comentario comentario) {
    return repository.addComment(comentario);
  }
}

/// Caso de uso para eliminar un comentario; mantiene la regla de negocio fuera de la interfaz.
class DeleteCommentUseCase {
  final CommentRepository repository;

  DeleteCommentUseCase(this.repository);

  Future<void> execute(int id) {
    return repository.deleteComment(id);
  }
}
