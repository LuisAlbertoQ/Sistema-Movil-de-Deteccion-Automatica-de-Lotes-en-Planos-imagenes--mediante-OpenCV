from urllib.request import Request
import cv2
import numpy as np
from rest_framework import status
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth.hashers import make_password
from .models import LogActividad, Usuario, Lote, Venta, Plano
from .serializers import LogActividadSerializer, LoteSerializer, PlanoSerializer, UsuarioSerializer, VentaSerializer
from .permissions import IsAdmin, IsAdminOrAgente, IsUsuario

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
def detectar_lotes(imagen_path, precio_base_por_m2=5, factor_ubicacion=0.9):
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
    
    # Obtener dimensiones de la imagen
    alto, ancho = imagen.shape[:2]
    area_total_imagen = alto * ancho
    
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
                padre = jerarquia[0][i][3]
                if padre != -1:
                    area_padre = cv2.contourArea(contornos[padre])
                    if area / area_padre > 0.8:
                        es_valido = False
            
            if es_valido:
                # Calcular el área relativa del lote respecto al área total de la imagen
                area_relativa = area / area_total_imagen

                # Estimar área en metros cuadrados (asumiendo que la imagen representa un área de 10000 m2)
                area_estimada_m2 = area_relativa * 10000  # Ajusta este valor según tus necesidades

                # Calcular el precio basado en el área estimada y factores adicionales
                precio = area_estimada_m2 * precio_base_por_m2 * factor_ubicacion

                # Determinar la forma del lote
                forma = "rectangular" if len(approx) == 4 else "irregular"

                lotes_detectados.append({
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
            plano = serializer.save(subido_por=request.user)
            
            LogActividad.objects.create(
            id_usuario=request.user,
            accion=f'Plano {plano.id} subido'    
        )
            
            lotes = detectar_lotes(plano.imagen.path)
            for lote_data in lotes:
                Lote.objects.create(
                    id_plano=plano,
                    coordenadas=lote_data['coordenadas'],
                    estado=lote_data['estado'],
                    precio=lote_data['precio']
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
    return Response(serializer.data)


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
def elimnimar_venta(request, venta_id):
    try:
        venta = Venta.objects.get(id=venta_id)
        venta.delete()
        
        LogActividad.objects.create(
            id_usuario=request.user,
            accion=f'Venta {venta_id} eliminado'    
        )
        
        return Response({'detail:''Venta eliminada exsitosamente'}, status=status.HTTP_204_NO_CONTENT)
    except Venta.DoesNotExist:
        return Response({'error': 'Venta no encontrada'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['PUT'])
@permission_classes([IsAuthenticated, IsAdmin])
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
@permission_classes([IsAuthenticated, IsAdmin])
def ver_log_actividad(request):
    log = LogActividad.objects.all()
    serializer = LogActividadSerializer(log, many=True)
    return Response(serializer.data)
