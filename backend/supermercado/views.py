from core.views import CreateView, ListView, DetailView, UpdateView, DeleteView

from .models import Supermercado
from .serializers import SupermercadoSerializer


class SupermercadoCreateView(CreateView):
    model = Supermercado
    serializer_class = SupermercadoSerializer


class SupermercadoListView(ListView):
    model = Supermercado
    serializer_class = SupermercadoSerializer


class SupermercadoDetailView(DetailView):
    model = Supermercado
    serializer_class = SupermercadoSerializer


class SupermercadoUpdateView(UpdateView):
    model = Supermercado
    serializer_class = SupermercadoSerializer


class SupermercadoDeleteView(DeleteView):
    model = Supermercado
    serializer_class = SupermercadoSerializer
from django.shortcuts import render

# Create your views here.
