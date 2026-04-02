from rest_framework import serializers

from .models import Promocion, PromocionHorario, TipoPromocion


class TipoPromocionSerializer(serializers.ModelSerializer):
    class Meta:
        model = TipoPromocion
        fields = '__all__'


class PromocionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Promocion
        fields = '__all__'


class PromocionHorarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = PromocionHorario
        fields = '__all__'
