from core.views import CreateView, ListView, DetailView, UpdateView, DeleteView

from .models import Favorito
from .serializers import FavoritoSerializer


class FavoritoCreateView(CreateView):
    model = Favorito
    serializer_class = FavoritoSerializer


class FavoritoListView(ListView):
    model = Favorito
    serializer_class = FavoritoSerializer


class FavoritoDetailView(DetailView):
    model = Favorito
    serializer_class = FavoritoSerializer


class FavoritoUpdateView(UpdateView):
    model = Favorito
    serializer_class = FavoritoSerializer


class FavoritoDeleteView(DeleteView):
    model = Favorito
    serializer_class = FavoritoSerializer
from django.shortcuts import render

# Create your views here.
