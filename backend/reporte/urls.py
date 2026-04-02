from django.urls import path

from .views import (
    ReporteCreateView,
    ReporteDeleteView,
    ReporteDetailView,
    ReporteListView,
    ReporteUpdateView,
)

urlpatterns = [
    path('', ReporteCreateView.as_view()),
    path('list/', ReporteListView.as_view()),
    path('<int:id>/', ReporteDetailView.as_view()),
    path('update/', ReporteUpdateView.as_view()),
    path('delete/', ReporteDeleteView.as_view()),
]
