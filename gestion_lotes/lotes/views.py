from urllib.request import Request
import cv2
import numpy as np
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth import authenticate
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth.hashers import make_password
from .models import LogActividad, Usuario, Lote, Venta, Plano
from .serializers import LogActividadSerializer, LoteSerializer, PlanoSerializer, UsuarioSerializer, VentaSerializer, CompradoresSerializer
from .permissions import IsAdmin, IsAdminOrAgente, IsUsuario
from shapely.geometry import Polygon, MultiPolygon

@api_view(['POST'])
def registro(request):
    data = request.data
    if 'username' not in data or 'password' not in data:
        return Response({'error': 'Username and password are required'}, status=status.HTTP_400_BAD_REQUEST)

    password_hashed = make_password(data['password'])
    
    usuario = Usuario.objects.create(
        username=data['username'],
        nombre=data['nombre'],
        email=data['email'],
        password=password_hashed,
        rol=data.get('rol', 'usuario')  # Por defecto, asignamos el rol de usuario
    )
    
    LogActividad.objects.create(
        id_usuario=usuario,
        accion='Usuario registrado',
    )
    
    serializer = UsuarioSerializer(usuario)
    return Response(serializer.data, status=status.HTTP_201_CREATED)


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        data = super().validate(attrs)
        # Agregar datos personalizados a la respuesta
        data['username'] = self.user.username
        data['rol'] = self.user.rol
        data['email'] = self.user.email
        data['id'] = self.user.id
        return data

class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

@api_view(['POST'])
def login(request):
    username = request.data.get('username')
    password = request.data.get('password')
    
    usuario = authenticate(request, username=username, password=password)

    if usuario is not None:
        # Usar el serializador personalizado
        serializer = CustomTokenObtainPairSerializer()
        refresh = RefreshToken.for_user(usuario)
        
        return Response({
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'username': usuario.username,
            'rol': usuario.rol,
            'email': usuario.email,
            'id': usuario.id
        }, status=status.HTTP_200_OK)
    else:
        return Response({
            'detail': 'No active account found with the given credentials'
        }, status=status.HTTP_401_UNAUTHORIZED)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def obtener_perfil_usuario(request):
    usuario = request.user
    data = {
        "username": usuario.username,
        "email": usuario.email,
        "rol": usuario.rol
    }
    return Response(data)

# Función detectar los lotes en la imagen
def detectar_lotes(imagen_path, precio_base_por_m2=5, factor_ubicacion=0.9, area_minima=500, area_maxima=0.5):
    # Cargar la imagen
    imagen = cv2.imread(imagen_path)
    
    # Convertir la imagen a escala de grises
    gris = cv2.cvtColor(imagen, cv2.COLOR_BGR2GRAY)
    
    # Aplicar suavizado para reducir el ruido
    gris = cv2.GaussianBlur(gris, (5, 5), 0)
    
    # Aplicar un umbral adaptativo para mejorar la segmentación
    umbral = cv2.adaptiveThreshold(gris, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
                                   cv2.THRESH_BINARY_INV, 11, 2)
    
    # Dilatar y erosionar para mejorar la detección de bordes
    kernel = np.ones((3,3), np.uint8)
    umbral = cv2.dilate(umbral, kernel, iterations=1)
    umbral = cv2.erode(umbral, kernel, iterations=1)
    
    # Encontrar contornos, incluyendo los internos
    contornos, jerarquia = cv2.findContours(umbral, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
    
    lotes_detectados = []
    
    # Obtener dimensiones de la imagen
    alto, ancho = imagen.shape[:2]
    area_total_imagen = alto * ancho
    
    # Procesar cada contorno
    for i, contorno in enumerate(contornos):
        area = cv2.contourArea(contorno)
        
        # Filtrar contornos por área
        if area_minima <= area <= area_total_imagen * area_maxima:
            # Aproximar el contorno a un polígono
            epsilon = 0.02 * cv2.arcLength(contorno, True)
            approx = cv2.approxPolyDP(contorno, epsilon, True)
            
            # Obtener las coordenadas del lote
            x, y, w, h = cv2.boundingRect(contorno)
            
            # Verificar si es un contorno interno válido
            es_valido = True
            
            # Verificar si el contorno es el borde de la imagen
            if (x <= 1 and y <= 1) or (x + w >= ancho - 1) or (y + h >= alto - 1):
                es_valido = False
            
            # Verificar jerarquía
            if jerarquia is not None:
                # Verificar si tiene padre
                padre = jerarquia[0][i][3]
                if padre != -1:
                    area_padre = cv2.contourArea(contornos[padre])
                    if area / area_padre > 0.8:
                        es_valido = False
                        
                # Verificar si tiene hijos (si tiene hijos, probablemente es un contorno exterior)
                hijo = jerarquia[0][i][2]
                if hijo != -1:
                    es_valido = False
            
            if es_valido:
                # Calcular el área relativa del lote respecto al área total de la imagen
                area_relativa = area / area_total_imagen

                # Estimar área en metros cuadrados (asumiendo que la imagen representa un área de 10000 m2)
                area_estimada_m2 = area_relativa * 10000  # Ajusta este valor según tus necesidades

                # Calcular el precio basado en el área estimada y factores adicionales
                precio = area_estimada_m2 * precio_base_por_m2 * factor_ubicacion

                # Determinar la forma del lote
                polygon = Polygon(approx.reshape(-1, 2))
                if polygon.is_valid:
                    if len(approx) == 4:
                        forma = "rectangular"
                    else:
                        forma = "irregular"
                else:
                    forma = "compleja"

                # Asignar un nombre al lote
                nombre_lote = f"Lote {len(lotes_detectados) + 1}"

                lotes_detectados.append({
                    'nombre': nombre_lote,
                    'coordenadas': f"{x},{y},{w},{h}",
                    'estado': 'disponible',
                    'poligono': approx.tolist(),
                    'area_m2': round(area_estimada_m2, 2),
                    'forma': forma,
                    'precio': round(precio, 2)
                })
    
    return lotes_detectados


@api_view(['POST'])
@permission_classes([IsAuthenticated, IsAdmin])
def subir_plano(request):
    if request.method == 'POST':
        serializer = PlanoSerializer(data=request.data)
        
        if serializer.is_valid():
            # Guardar el plano con el usuario autenticado
            plano = serializer.save(subido_por=request.user)
            
            # Registrar la actividad de subida de plano
            LogActividad.objects.create(
                id_usuario=request.user,
                accion=f'Plano {plano.id} subido'
            )
            
            # Llamar a la función de detección de lotes y procesar los lotes detectados
            lotes = detectar_lotes(plano.imagen.path)
            for lote_data in lotes:
                Lote.objects.create(
                    id_plano=plano,
                    nombre=lote_data['nombre'],  # Asignar el nombre del lote
                    coordenadas=lote_data['coordenadas'],
                    estado=lote_data['estado'],
                    precio=lote_data['precio'],
                    area_m2=lote_data['area_m2'],
                    forma=lote_data['forma']
                )
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def listar_planos(request):
    planos = Plano.objects.all()
    serializer = PlanoSerializer(planos, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)  # Enviar la respuesta en formato JSON

'''
@api_view(['POST'])
def agregar_lote(request):
    serializer = LoteSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
'''
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def obtener_lotes_por_plano(request, plano_id):
    try:
        #Filtra los lotes segun el ID del plano
        lotes = Lote.objects.filter(id_plano=plano_id)
        serializer = LoteSerializer(lotes, many=True)
        return Response(serializer.data, status=200)
    except Lote.DoesNotExist:
        return Response({'error': 'No se encontraron lotes para este plano'}, status=status.HTTP_404_NOT_FOUND)


@api_view(['GET'])
@permission_classes([IsAuthenticated])  # Cualquier usuario autenticado puede ver los lotes
def listar_lotes(request):
    estado = request.query_params.get('estado', None)
    if estado:
        lotes = Lote.objects.filter(estado=estado)
    else:
        lotes = Lote.objects.all()
    
    serializer = LoteSerializer(lotes, many=True)
    return Response(serializer.data)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated, IsAdminOrAgente])  # Solo los usuarios con permisos pueden eliminar
def eliminar_lote(request, lote_id):
    try:
        lote = Lote.objects.get(id=lote_id)
        lote.delete()
        
        LogActividad.objects.create(
            id_usuario=request.user,
            accion=f'Venta {lote_id} eliminado'    
        )
                
        return Response({'detail': 'Lote eliminado exitosamente'}, status=status.HTTP_204_NO_CONTENT)
    except Lote.DoesNotExist:
        return Response({'error': 'Lote no encontrado'}, status=status.HTTP_404_NOT_FOUND)
    
@api_view(['PUT'])
@permission_classes([IsAuthenticated, IsAdminOrAgente])  # Permisos necesarios
def editar_lote(request, lote_id):
    try:
        lote = Lote.objects.get(id=lote_id)
    except Lote.DoesNotExist:
        return Response({'error': 'Lote no encontrado'}, status=status.HTTP_404_NOT_FOUND)
    
    serializer = LoteSerializer(lote, data=request.data, partial=True)  # partial=True para permitir actualizaciones parciales
    if serializer.is_valid():
        serializer.save()
        
        LogActividad.objects.create(
            id_usuario=request.user,
            accion=f'Lote {lote.id} editado'    
        )
        return Response(serializer.data, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def detalle_lote(request, lote_id):
    try:
        lote = Lote.objects.get(id=lote_id)
    except Lote.DoesNotExist:
        return Response({'error': 'Lote no encontrado'}, status=status.HTTP_404_NOT_FOUND)

    serializer = LoteSerializer(lote)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated, IsAdminOrAgente])
def registrar_venta(request):
    try:
        lote = Lote.objects.get(id=request.data['id_lote'])
        comprador = Usuario.objects.get(id=request.data['id_comprador'])

        venta = Venta.objects.create(
            id_lote=lote,
            id_comprador=comprador,
            precio_venta=request.data['precio_venta'],
            condiciones=request.data.get('condiciones', '')
        )

        lote.estado = 'vendido'
        lote.save()
        
        LogActividad.objects.create(
            id_usuario=request.user,
            accion=f'Venta {venta.id} registrada'    
        )

        serializer = VentaSerializer(venta)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    except Lote.DoesNotExist:
        return Response({'error': 'Lote no encontrado'}, status=status.HTTP_404_NOT_FOUND)
    except Usuario.DoesNotExist:
        return Response({'error': 'Comprador no encontrado'}, status=status.HTTP_404_NOT_FOUND)
    
@api_view(['GET'])
@permission_classes([IsAuthenticated, IsAdminOrAgente])
def listar_ventas(request):
    # Filtrar por comprador si se proporciona en los parámetros de la consulta
    id_comprador = request.query_params.get('id_comprador', None)
    id_lote = request.query_params.get('id_lote', None)
    
    # Si se proporciona el comprador, filtrar por el comprador
    if id_comprador:
        ventas = Venta.objects.filter(id_comprador=id_comprador)
    # Si se proporciona el lote, filtrar por el lote
    elif id_lote:
        ventas = Venta.objects.filter(id_lote=id_lote)
    else:
        ventas = Venta.objects.all()
    
    serializer = VentaSerializer(ventas, many=True)
    return Response(serializer.data, status=status.HTTP_200_OK)


@api_view(['DELETE'])
@permission_classes([IsAuthenticated, IsAdmin])
def eliminar_venta(request, venta_id):
    try:
        venta = Venta.objects.get(id=venta_id)
        lote = venta.id_lote
        venta.delete()
        
        lote.estado = 'disponible'
        lote.save()
        
        LogActividad.objects.create(
            id_usuario=request.user,
            accion=f'Venta {venta_id} eliminada y lote {lote.id} marcado como disponible'    
        )
        
        return Response({'detail:''Venta eliminada exitosamente'}, status=status.HTTP_204_NO_CONTENT)
    except Venta.DoesNotExist:
        return Response({'error': 'Venta no encontrada'}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({
            'error': f'Error al procesar la solicitud: {str(e)}'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['PUT'])
@permission_classes([IsAuthenticated, IsAdminOrAgente])
def editar_venta(request, venta_id):
    try:
        venta = Venta.objects.get(id=venta_id)
    except Venta.DoesNotExist:
        return Response({'error': 'Venta no encontrada'}, status=status.HTTP_404_NOT_FOUND)
    
    serializer = VentaSerializer(venta, data=request.data, partial=True)  # partial=True permite actualizar campos específicos
    if serializer.is_valid():
        serializer.save()
        
        LogActividad.objects.create(
            id_usuario=request.user,
            accion=f'Venta {venta_id} editada'    
        )
        return Response(serializer.data, status=status.HTTP_200_OK)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def listar_compradores(request):
    compradores = Usuario.objects.filter(rol='Usuario')
    serializer = CompradoresSerializer(compradores, many=True)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([IsAuthenticated, IsAdmin])
def ver_log_actividad(request):
    log = LogActividad.objects.all()
    serializer = LogActividadSerializer(log, many=True)
    return Response(serializer.data)
