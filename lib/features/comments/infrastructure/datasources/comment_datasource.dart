import 'package:app/features/comments/domain/entities/comentario.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart';

abstract class CommentDataSource {
  List<Comentario> getAllComments();
  List<Comentario> getCommentsByPromotion(String promotionCode);
  void addComment(Comentario comentario);
  void deleteComment(int id);
}

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
  void addComment(Comentario comentario) {
    promoService.addComentario(comentario);
  }

  @override
  void deleteComment(int id) {
    promoService.deleteComentario(id);
  }
}
