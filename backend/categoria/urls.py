from django.urls import path

from .views import (
    CategoriaCreateView,
    CategoriaDeleteView,
    CategoriaDetailView,
    CategoriaListView,
    CategoriaUpdateView,
)

urlpatterns = [
    path('', CategoriaCreateView.as_view()),
    path('list/', CategoriaListView.as_view()),
    path('<int:id>/', CategoriaDetailView.as_view()),
    path('update/', CategoriaUpdateView.as_view()),
    path('delete/', CategoriaDeleteView.as_view()),
]
