from django.urls import path

from .views import (
    UsuarioCreateView,
    UsuarioDeleteView,
    UsuarioDetailView,
    UsuarioListView,
    UsuarioNotificacionCreateView,
    UsuarioNotificacionDeleteView,
    UsuarioNotificacionDetailView,
    UsuarioNotificacionListView,
    UsuarioNotificacionUpdateView,
    UsuarioUpdateView,
)

urlpatterns = [
    path('', UsuarioCreateView.as_view()),
    path('list/', UsuarioListView.as_view()),
    path('<int:id>/', UsuarioDetailView.as_view()),
    path('update/', UsuarioUpdateView.as_view()),
    path('delete/', UsuarioDeleteView.as_view()),
    path('notificacion/', UsuarioNotificacionCreateView.as_view()),
    path('notificacion/list/', UsuarioNotificacionListView.as_view()),
    path('notificacion/<int:id>/', UsuarioNotificacionDetailView.as_view()),
    path('notificacion/update/', UsuarioNotificacionUpdateView.as_view()),
    path('notificacion/delete/', UsuarioNotificacionDeleteView.as_view()),
]
