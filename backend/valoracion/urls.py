from django.urls import path

from .views import (
    ValoracionCreateView,
    ValoracionDeleteView,
    ValoracionDetailView,
    ValoracionListView,
    ValoracionUpdateView,
)

urlpatterns = [
    path('', ValoracionCreateView.as_view()),
    path('list/', ValoracionListView.as_view()),
    path('<int:id>/', ValoracionDetailView.as_view()),
    path('update/', ValoracionUpdateView.as_view()),
    path('delete/', ValoracionDeleteView.as_view()),
]
