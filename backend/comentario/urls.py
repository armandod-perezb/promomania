from django.urls import path

from .views import (
    ComentarioCreateView,
    ComentarioDeleteView,
    ComentarioDetailView,
    ComentarioListView,
    ComentarioUpdateView,
)

urlpatterns = [
    path('', ComentarioCreateView.as_view()),
    path('list/', ComentarioListView.as_view()),
    path('<int:id>/', ComentarioDetailView.as_view()),
    path('update/', ComentarioUpdateView.as_view()),
    path('delete/', ComentarioDeleteView.as_view()),
]
