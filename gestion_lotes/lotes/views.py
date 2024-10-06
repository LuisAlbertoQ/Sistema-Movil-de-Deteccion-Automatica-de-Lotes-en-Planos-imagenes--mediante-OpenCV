from urllib.request import Request
import cv2
import numpy as np
from rest_framework import status
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate
from rest_framework.response import Response
from rest_framework.decorators import api_view
from django.contrib.auth.hashers import make_password
from .models import LogActividad, Usuario, Lote, Venta, Plano
from .serializers import LogActividadSerializer, LoteSerializer, PlanoSerializer, UsuarioSerializer, VentaSerializer

@api_view(['POST'])
def registro(request):
    data = request.data
    if 'username' not in data or 'password' not in data:
        return Response({'error': 'Username and password are required'}, status=status.HTTP_400_BAD_REQUEST)

    # Cifrar la contraseña
    password_hashed = make_password(data['password'])
    
    # Crear el usuario
    usuario = Usuario.objects.create(
        username=data['username'],
        nombre=data['nombre'],
        email=data['email'],
        password=password_hashed,
        rol=data.get('rol', 'comprador')
    )
    
    # Agregar registro al log de actividades
    LogActividad.objects.create(
        id_usuario=usuario,
        accion='Usuario registrado',
    )
    
    # Serializar el usuario
    serializer = UsuarioSerializer(usuario)
    return Response(serializer.data, status=status.HTTP_201_CREATED)


@api_view(['POST'])
def login(request):
    username = request.data.get('username')
    password = request.data.get('password')

    usuario = authenticate(request, username=username, password=password)

    if usuario is not None:
        return Response({'detail': 'Inicio de sesión exitoso', 'username': usuario.username}, status=status.HTTP_200_OK)
    else:
        return Response({'detail': 'No active account found with the given credentials'}, status=status.HTTP_401_UNAUTHORIZED)

# Función mejorada para detectar los lotes en la imagen
def detectar_lotes(imagen_path):
    # Cargar la imagen
    imagen = cv2.imread(imagen_path)
    
    # Convertir la imagen a escala de grises
    gris = cv2.cvtColor(imagen, cv2.COLOR_BGR2GRAY)
    
    # Aplicar suavizado para reducir ruido
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
    area_minima = 1000  # Ajusta según el tamaño de tus lotes
    
    # Procesar cada contorno
    for i, contorno in enumerate(contornos):
        area = cv2.contourArea(contorno)
        if area > area_minima:
            # Aproximar el contorno a un polígono
            epsilon = 0.02 * cv2.arcLength(contorno, True)
            approx = cv2.approxPolyDP(contorno, epsilon, True)
            
            # Obtener las coordenadas del lote
            x, y, w, h = cv2.boundingRect(contorno)
            
            # Verificar si es un contorno interno válido
            es_valido = True
            if jerarquia is not None:
                # Verificar la jerarquía del contorno
                padre = jerarquia[0][i][3]
                if padre != -1:
                    # Si tiene un padre, verificar el área relativa
                    area_padre = cv2.contourArea(contornos[padre])
                    if area / area_padre > 0.8:
                        es_valido = False
            
            if es_valido:
                lotes_detectados.append({
                    'coordenadas': f"{x},{y},{w},{h}",
                    'estado': 'disponible',
                    'poligono': approx.tolist()  # Guardar los puntos del polígono si es necesario
                })
    
    return lotes_detectados

@api_view(['POST'])
def subir_plano(request):
    if request.method == 'POST':
        serializer = PlanoSerializer(data=request.data)
        if serializer.is_valid():
            plano = serializer.save(subido_por=request.user)
            
            # Procesar la imagen para detectar lotes
            lotes = detectar_lotes(plano.imagen.path)
            
            # Guardar los lotes en la base de datos
            for lote_data in lotes:
                Lote.objects.create(
                    id_plano=plano,
                    coordenadas=lote_data['coordenadas'],
                    estado=lote_data['estado'],
                    precio=0.0
                )
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
def agregar_lote(request):
    serializer = LoteSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
def listar_lotes(request):
    estado = request.query_params.get('estado', None)  # Permite filtrar por estado
    if estado:
        lotes = Lote.objects.filter(estado=estado)
    else:
        lotes = Lote.objects.all()
    
    serializer = LoteSerializer(lotes, many=True)
    return Response(serializer.data)

@api_view(['GET'])
def detalle_lote(request, lote_id):
    try:
        lote = Lote.objects.get(id=lote_id)
    except Lote.DoesNotExist:
        return Response({'error': 'Lote no encontrado'}, status=status.HTTP_404_NOT_FOUND)

    serializer = LoteSerializer(lote)
    return Response(serializer.data)

@api_view(['POST'])
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

        # Actualizar estado del lote a vendido
        lote.estado = 'vendido'
        lote.save()

        serializer = VentaSerializer(venta)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    except Lote.DoesNotExist:
        return Response({'error': 'Lote no encontrado'}, status=status.HTTP_404_NOT_FOUND)
    except Usuario.DoesNotExist:
        return Response({'error': 'Comprador no encontrado'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['GET'])
def ver_log_actividad(request):
    log = LogActividad.objects.all()
    serializer = LogActividadSerializer(log, many=True)
    return Response(serializer.data)
