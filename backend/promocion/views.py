from core.views import BaseModelViewSet

from .models import Promocion, PromocionHorario, TipoPromocion
from .serializers import PromocionHorarioSerializer, PromocionSerializer, TipoPromocionSerializer


class TipoPromocionViewSet(BaseModelViewSet):
    model = TipoPromocion
    serializer_class = TipoPromocionSerializer


class PromocionViewSet(BaseModelViewSet):
    model = Promocion
    serializer_class = PromocionSerializer


class PromocionHorarioViewSet(BaseModelViewSet):
    model = PromocionHorario
    serializer_class = PromocionHorarioSerializer
