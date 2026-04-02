from core.views import CreateView, ListView, DetailView, UpdateView, DeleteView

from .models import Valoracion
from .serializers import ValoracionSerializer


class ValoracionCreateView(CreateView):
    model = Valoracion
    serializer_class = ValoracionSerializer


class ValoracionListView(ListView):
    model = Valoracion
    serializer_class = ValoracionSerializer


class ValoracionDetailView(DetailView):
    model = Valoracion
    serializer_class = ValoracionSerializer


class ValoracionUpdateView(UpdateView):
    model = Valoracion
    serializer_class = ValoracionSerializer


class ValoracionDeleteView(DeleteView):
    model = Valoracion
    serializer_class = ValoracionSerializer
from django.shortcuts import render

# Create your views here.
