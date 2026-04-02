from django.urls import path

from .views import (
    PromocionCreateView,
    PromocionDeleteView,
    PromocionDetailView,
    PromocionHorarioCreateView,
    PromocionHorarioDeleteView,
    PromocionHorarioDetailView,
    PromocionHorarioListView,
    PromocionHorarioUpdateView,
    PromocionListView,
    PromocionUpdateView,
    TipoPromocionCreateView,
    TipoPromocionDeleteView,
    TipoPromocionDetailView,
    TipoPromocionListView,
    TipoPromocionUpdateView,
)

urlpatterns = [
    path('tipo/', TipoPromocionCreateView.as_view()),
    path('tipo/list/', TipoPromocionListView.as_view()),
    path('tipo/<int:id>/', TipoPromocionDetailView.as_view()),
    path('tipo/update/', TipoPromocionUpdateView.as_view()),
    path('tipo/delete/', TipoPromocionDeleteView.as_view()),
    path('', PromocionCreateView.as_view()),
    path('list/', PromocionListView.as_view()),
    path('<str:id>/', PromocionDetailView.as_view()),
    path('update/', PromocionUpdateView.as_view()),
    path('delete/', PromocionDeleteView.as_view()),
    path('horario/', PromocionHorarioCreateView.as_view()),
    path('horario/list/', PromocionHorarioListView.as_view()),
    path('horario/<int:id>/', PromocionHorarioDetailView.as_view()),
    path('horario/update/', PromocionHorarioUpdateView.as_view()),
    path('horario/delete/', PromocionHorarioDeleteView.as_view()),
]
