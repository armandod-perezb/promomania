from core.views import BaseModelViewSet

from .models import Usuario, UsuarioNotificacion
from .serializers import UsuarioSerializer, UsuarioNotificacionSerializer


class UsuarioViewSet(BaseModelViewSet):
    model = Usuario
    serializer_class = UsuarioSerializer


class UsuarioNotificacionViewSet(BaseModelViewSet):
    model = UsuarioNotificacion
    serializer_class = UsuarioNotificacionSerializer
