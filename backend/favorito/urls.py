from django.urls import path

from .views import (
    FavoritoCreateView,
    FavoritoDeleteView,
    FavoritoDetailView,
    FavoritoListView,
    FavoritoUpdateView,
)

urlpatterns = [
    path('', FavoritoCreateView.as_view()),
    path('list/', FavoritoListView.as_view()),
    path('<int:id>/', FavoritoDetailView.as_view()),
    path('update/', FavoritoUpdateView.as_view()),
    path('delete/', FavoritoDeleteView.as_view()),
]
