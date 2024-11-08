from rest_framework import serializers
from .models import LogActividad, Lote, Plano, Usuario, Venta

class UsuarioSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = ['id', 'username', 'nombre', 'email', 'rol', 'fecha_registro']
        
class CompradoresSerializer(serializers.ModelSerializer):
    class Meta:
        model = Usuario
        fields = ['id', 'nombre', 'email']
        
class LoginSerializer(serializers.Serializer):
    username = serializers.CharField(required=True)
    password = serializers.CharField(required=True)

class PlanoSerializer(serializers.ModelSerializer):
    subido_por = serializers.CharField(source='subido_por.nombre', read_only=True)
    class Meta:
        model = Plano
        fields = ['id', 'nombre_plano','imagen', 'subido_por', 'fecha_subida']  # Incluye el campo subido_por
        
class LoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Lote
        fields = '__all__'  # Esto incluirá todos los campos del modelo Lote
        
class VentaSerializer(serializers.ModelSerializer):
    id_comprador = serializers.CharField(source='id_comprador.nombre', read_only=True)
    id_lote = serializers.CharField(source='id_lote.nombre', read_only=True)
    class Meta:
        model = Venta
        fields = ['id', 'id_lote', 'id_comprador', 'precio_venta', 'fecha_venta', 'condiciones']
        
class LogActividadSerializer(serializers.ModelSerializer):
    class Meta:
        model = LogActividad
        fields = ['id_usuario', 'accion', 'fecha']
