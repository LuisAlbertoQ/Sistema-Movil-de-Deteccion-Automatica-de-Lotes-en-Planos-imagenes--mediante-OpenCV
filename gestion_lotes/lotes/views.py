from urllib.request import Request
from rest_framework import status
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate
from rest_framework.response import Response
from rest_framework.decorators import api_view
from django.contrib.auth.hashers import make_password
from .models import LogActividad, Usuario, Lote, Venta
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
        # Aquí puedes generar un token o simplemente confirmar que el login es exitoso
        return Response({'detail': 'Inicio de sesión exitoso', 'username': usuario.username}, status=status.HTTP_200_OK)
    else:
        return Response({'detail': 'No active account found with the given credentials'}, status=status.HTTP_401_UNAUTHORIZED)

@api_view(['POST'])
def subir_plano(request):
    if request.method == 'POST':
        serializer = PlanoSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(subido_por=request.user)  # Guardamos el plano con el usuario que lo subió
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
        return Response({'error': 'Comprador no encontrado'}, status=status.HTTP_404_NOT_FOUND)  # Agregar este return

@api_view(['GET'])
def ver_log_actividad(request):
    log = LogActividad.objects.all()
    serializer = LogActividadSerializer(log, many=True)
    return Response(serializer.data)