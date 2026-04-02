from core.views import CreateView, ListView, DetailView, UpdateView, DeleteView

from .models import Comentario
from .serializers import ComentarioSerializer


class ComentarioCreateView(CreateView):
    model = Comentario
    serializer_class = ComentarioSerializer


class ComentarioListView(ListView):
    model = Comentario
    serializer_class = ComentarioSerializer


class ComentarioDetailView(DetailView):
    model = Comentario
    serializer_class = ComentarioSerializer


class ComentarioUpdateView(UpdateView):
    model = Comentario
    serializer_class = ComentarioSerializer


class ComentarioDeleteView(DeleteView):
    model = Comentario
    serializer_class = ComentarioSerializer
from django.shortcuts import render

# Create your views here.
