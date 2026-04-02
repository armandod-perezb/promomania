from core.views import CreateView, ListView, DetailView, UpdateView, DeleteView

from .models import Reporte
from .serializers import ReporteSerializer


class ReporteCreateView(CreateView):
    model = Reporte
    serializer_class = ReporteSerializer


class ReporteListView(ListView):
    model = Reporte
    serializer_class = ReporteSerializer


class ReporteDetailView(DetailView):
    model = Reporte
    serializer_class = ReporteSerializer


class ReporteUpdateView(UpdateView):
    model = Reporte
    serializer_class = ReporteSerializer


class ReporteDeleteView(DeleteView):
    model = Reporte
    serializer_class = ReporteSerializer
from django.shortcuts import render

# Create your views here.
