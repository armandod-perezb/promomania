import 'package:app/features/moderation/domain/entities/reporte.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart';

abstract class ModerationDataSource {
  List<Reporte> getAllReportes();
  List<Reporte> getReportesByUsuario(int userId);
  List<Reporte> getReportesByPromocion(String promotionCode);
  void addReporte(Reporte reporte);
  void updateReporte(Reporte reporte);
  void deleteReporte(int id);
}

class PromoModerationDataSource implements ModerationDataSource {
  final PromoService promoService;

  PromoModerationDataSource(this.promoService);

  @override
  List<Reporte> getAllReportes() {
    return promoService.getReportes();
  }

  @override
  List<Reporte> getReportesByUsuario(int userId) {
    return promoService.getReportesByUsuario(userId);
  }

  @override
  List<Reporte> getReportesByPromocion(String promotionCode) {
    return promoService.getReportesByPromocion(promotionCode);
  }

  @override
  void addReporte(Reporte reporte) {
    promoService.addReporte(reporte);
  }

  @override
  void updateReporte(Reporte reporte) {
    promoService.updateReporte(reporte);
  }

  @override
  void deleteReporte(int id) {
    promoService.deleteReporte(id);
  }
}
