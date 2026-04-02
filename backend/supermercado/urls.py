from django.urls import path

from .views import (
    SupermercadoCreateView,
    SupermercadoDeleteView,
    SupermercadoDetailView,
    SupermercadoListView,
    SupermercadoUpdateView,
)

urlpatterns = [
    path('', SupermercadoCreateView.as_view()),
    path('list/', SupermercadoListView.as_view()),
    path('<int:id>/', SupermercadoDetailView.as_view()),
    path('update/', SupermercadoUpdateView.as_view()),
    path('delete/', SupermercadoDeleteView.as_view()),
]
