from core.views import CreateView, ListView, DetailView, UpdateView, DeleteView

from .models import Usuario, UsuarioNotificacion
from .serializers import UsuarioSerializer, UsuarioNotificacionSerializer


class UsuarioCreateView(CreateView):
    model = Usuario
    serializer_class = UsuarioSerializer


class UsuarioListView(ListView):
    model = Usuario
    serializer_class = UsuarioSerializer


class UsuarioDetailView(DetailView):
    model = Usuario
    serializer_class = UsuarioSerializer


class UsuarioUpdateView(UpdateView):
    model = Usuario
    serializer_class = UsuarioSerializer


class UsuarioDeleteView(DeleteView):
    model = Usuario
    serializer_class = UsuarioSerializer


class UsuarioNotificacionCreateView(CreateView):
    model = UsuarioNotificacion
    serializer_class = UsuarioNotificacionSerializer


class UsuarioNotificacionListView(ListView):
    model = UsuarioNotificacion
    serializer_class = UsuarioNotificacionSerializer


class UsuarioNotificacionDetailView(DetailView):
    model = UsuarioNotificacion
    serializer_class = UsuarioNotificacionSerializer


class UsuarioNotificacionUpdateView(UpdateView):
    model = UsuarioNotificacion
    serializer_class = UsuarioNotificacionSerializer


class UsuarioNotificacionDeleteView(DeleteView):
    model = UsuarioNotificacion
    serializer_class = UsuarioNotificacionSerializer
