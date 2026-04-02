from core.views import CreateView, ListView, DetailView, UpdateView, DeleteView

from .models import Promocion, PromocionHorario, TipoPromocion
from .serializers import PromocionHorarioSerializer, PromocionSerializer, TipoPromocionSerializer


class TipoPromocionCreateView(CreateView):
    model = TipoPromocion
    serializer_class = TipoPromocionSerializer


class TipoPromocionListView(ListView):
    model = TipoPromocion
    serializer_class = TipoPromocionSerializer


class TipoPromocionDetailView(DetailView):
    model = TipoPromocion
    serializer_class = TipoPromocionSerializer


class TipoPromocionUpdateView(UpdateView):
    model = TipoPromocion
    serializer_class = TipoPromocionSerializer


class TipoPromocionDeleteView(DeleteView):
    model = TipoPromocion
    serializer_class = TipoPromocionSerializer


class PromocionCreateView(CreateView):
    model = Promocion
    serializer_class = PromocionSerializer


class PromocionListView(ListView):
    model = Promocion
    serializer_class = PromocionSerializer


class PromocionDetailView(DetailView):
    model = Promocion
    serializer_class = PromocionSerializer
    lookup_field = 'codigo'
    lookup_url_kwarg = 'id'


class PromocionUpdateView(UpdateView):
    model = Promocion
    serializer_class = PromocionSerializer
    lookup_field = 'codigo'
    request_lookup_field = 'codigo'


class PromocionDeleteView(DeleteView):
    model = Promocion
    serializer_class = PromocionSerializer
    lookup_field = 'codigo'
    request_lookup_field = 'codigo'


class PromocionHorarioCreateView(CreateView):
    model = PromocionHorario
    serializer_class = PromocionHorarioSerializer


class PromocionHorarioListView(ListView):
    model = PromocionHorario
    serializer_class = PromocionHorarioSerializer


class PromocionHorarioDetailView(DetailView):
    model = PromocionHorario
    serializer_class = PromocionHorarioSerializer


class PromocionHorarioUpdateView(UpdateView):
    model = PromocionHorario
    serializer_class = PromocionHorarioSerializer


class PromocionHorarioDeleteView(DeleteView):
    model = PromocionHorario
    serializer_class = PromocionHorarioSerializer
from django.shortcuts import render

# Create your views here.
