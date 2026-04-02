from django.contrib.auth.hashers import make_password
from rest_framework import serializers

from .models import Usuario, UsuarioNotificacion

class UsuarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = '__all__'
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        return super().create(validated_data)

    def update(self, instance, validated_data):
        if 'password' in validated_data:
            validated_data['password'] = make_password(validated_data['password'])
        return super().update(instance, validated_data)


class UsuarioNotificacionSerializer(serializers.ModelSerializer):
    class Meta:
        model = UsuarioNotificacion
        fields = '__all__'