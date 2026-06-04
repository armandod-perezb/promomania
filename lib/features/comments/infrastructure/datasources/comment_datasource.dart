import 'package:app/features/comments/domain/entities/comentario.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart';

/// Contrato de fuente de datos de comentarios; separa el origen concreto de la informacion del resto de la app.
abstract class CommentDataSource {
  List<Comentario> getAllComments();
  List<Comentario> getCommentsByPromotion(String promotionCode);
  List<Comentario> getCommentsByUser(int userId);
  void addComment(Comentario comentario);
  void deleteComment(int id);
}

/// Fuente de datos de comentarios; obtiene y transforma informacion desde servicios o almacenamiento local.
class PromoCommentDataSource implements CommentDataSource {
  final PromoService promoService;

  PromoCommentDataSource(this.promoService);

  @override
  List<Comentario> getAllComments() {
    return promoService.getComentarios();
  }

  @override
  List<Comentario> getCommentsByPromotion(String promotionCode) {
    return promoService.getComentariosByPromocion(promotionCode);
  }

  @override
  List<Comentario> getCommentsByUser(int userId) {
    return promoService.getComentariosByUsuario(userId);
  }

  @override
  void addComment(Comentario comentario) {
    promoService.addComentario(comentario);
  }

  @override
  void deleteComment(int id) {
    promoService.deleteComentario(id);
  }
}
