from core.views import CreateView, ListView, DetailView, UpdateView, DeleteView

from .models import Notificacion
from .serializers import NotificacionSerializer


class NotificacionCreateView(CreateView):
    model = Notificacion
    serializer_class = NotificacionSerializer


class NotificacionListView(ListView):
    model = Notificacion
    serializer_class = NotificacionSerializer


class NotificacionDetailView(DetailView):
    model = Notificacion
    serializer_class = NotificacionSerializer


class NotificacionUpdateView(UpdateView):
    model = Notificacion
    serializer_class = NotificacionSerializer


class NotificacionDeleteView(DeleteView):
    model = Notificacion
    serializer_class = NotificacionSerializer
from django.shortcuts import render

# Create your views here.
