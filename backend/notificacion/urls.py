from django.urls import path

from .views import (
    NotificacionCreateView,
    NotificacionDeleteView,
    NotificacionDetailView,
    NotificacionListView,
    NotificacionUpdateView,
)

urlpatterns = [
    path('', NotificacionCreateView.as_view()),
    path('list/', NotificacionListView.as_view()),
    path('<int:id>/', NotificacionDetailView.as_view()),
    path('update/', NotificacionUpdateView.as_view()),
    path('delete/', NotificacionDeleteView.as_view()),
]
