from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager

class UsuarioManager(BaseUserManager):
    def create_user(self, username, email, password=None, **extra_fields):
        if not email:
            raise ValueError('El email debe ser proporcionado')
        if not username:
            raise ValueError('El nombre de usuario debe ser proporcionado')
        
        email = self.normalize_email(email)
        user = self.model(username=username, email=email, **extra_fields)
        user.set_password(password)  # Hash de la contraseña
        user.save(using=self._db)
        return user

    def create_superuser(self, username, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        return self.create_user(username, email, password, **extra_fields)

class Usuario(AbstractBaseUser):
    ROLES = [
        ('admin', 'Administrador'),
        ('agente', 'Agente Inmobiliario'),
        ('usuario', 'Usuario')
    ]
    
    username = models.CharField(max_length=150, unique=True)
    nombre = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    rol = models.CharField(max_length=10, choices=ROLES, default='usuario')
    fecha_registro = models.DateTimeField(auto_now_add=True)

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = UsuarioManager()

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email']

    def __str__(self):
        return self.username

class Plano(models.Model):
    nombre_plano = models.CharField(max_length=100)
    imagen = models.ImageField(upload_to='planos/')
    subido_por = models.ForeignKey('Usuario', on_delete=models.CASCADE)
    fecha_subida = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.archivo_plano.name

class Lote(models.Model):
    ESTADO_LOTE = [
        ('disponible', 'Disponible'),
        ('vendido', 'Vendido')
    ]
    id_plano = models.ForeignKey(Plano, on_delete=models.CASCADE)
    nombre = models.CharField(max_length=100)
    coordenadas = models.TextField()  # Almacena las coordenadas del lote
    estado = models.CharField(max_length=10, choices=ESTADO_LOTE, default='disponible')
    precio = models.DecimalField(max_digits=10, decimal_places=2)
    area_m2 = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    forma = models.CharField(max_length=50, null=True, blank=True)

    def __str__(self):
        return f"Lote {self.id} - Estado: {self.estado}"

class Venta(models.Model):
    id_lote = models.ForeignKey(Lote, on_delete=models.SET_NULL, null=True)
    id_comprador = models.ForeignKey(Usuario, on_delete=models.SET_NULL, null=True)
    precio_venta = models.DecimalField(max_digits=10, decimal_places=2)
    fecha_venta = models.DateTimeField(auto_now_add=True)
    condiciones = models.TextField()

class LogActividad(models.Model):
    id_usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)  # Cambia 'User' por tu modelo de usuario si es necesario
    accion = models.CharField(max_length=255)
    fecha = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.accion} - {self.fecha} por {self.id_usuario}"
