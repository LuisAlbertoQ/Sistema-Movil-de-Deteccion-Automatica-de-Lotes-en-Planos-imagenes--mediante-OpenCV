from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.forms import UserCreationForm, UserChangeForm
from django import forms
from .models import Usuario, Plano, Lote, Venta, LogActividad

class UsuarioCreationForm(UserCreationForm):
    """Formulario personalizado para crear usuarios"""
    email = forms.EmailField(required=True)
    nombre = forms.CharField(max_length=100, required=True)
    rol = forms.ChoiceField(choices=Usuario.ROLES, required=True)

    class Meta:
        model = Usuario
        fields = ("username", "email", "nombre", "rol")

    def save(self, commit=True):
        user = super().save(commit=False)
        user.email = self.cleaned_data["email"]
        user.nombre = self.cleaned_data["nombre"]
        user.rol = self.cleaned_data["rol"]
        if commit:
            user.save()
        return user

class UsuarioChangeForm(UserChangeForm):
    """Formulario personalizado para editar usuarios"""
    class Meta:
        model = Usuario
        fields = ("username", "email", "nombre", "rol", "is_active", "is_staff")

@admin.register(Usuario)
class UsuarioAdmin(UserAdmin):
    """Administrador personalizado para el modelo Usuario"""
    add_form = UsuarioCreationForm
    form = UsuarioChangeForm
    model = Usuario
    
    # Campos que se muestran en la lista
    list_display = ('username', 'email', 'nombre', 'rol', 'is_active', 'fecha_registro')
    list_filter = ('rol', 'is_active', 'is_staff', 'fecha_registro')
    search_fields = ('username', 'email', 'nombre')
    ordering = ('username',)
    
    # Configuración para el formulario de agregar usuario
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'email', 'nombre', 'rol', 'password1', 'password2'),
        }),
    )
    
    # Configuración para el formulario de editar usuario
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        ('Información Personal', {'fields': ('nombre', 'email')}),
        ('Permisos', {'fields': ('rol', 'is_active', 'is_staff', 'is_superuser')}),
        ('Fechas Importantes', {'fields': ('last_login', 'fecha_registro')}),
    )
    
    readonly_fields = ('fecha_registro', 'last_login')
    
    def save_model(self, request, obj, form, change):
        """Personaliza el guardado del modelo"""
        if not change:  # Si es un nuevo usuario
            # Asignar permisos de staff basado en el rol
            if obj.rol in ['admin', 'agente']:
                obj.is_staff = True
        
        super().save_model(request, obj, form, change)
        
        # Registrar en el log de actividad
        if not change:
            LogActividad.objects.create(
                id_usuario=obj,
                accion=f'Usuario {obj.username} creado por {request.user.username} con rol {obj.rol}'
            )
        else:
            LogActividad.objects.create(
                id_usuario=obj,
                accion=f'Usuario {obj.username} modificado por {request.user.username}'
            )

@admin.register(Plano)
class PlanoAdmin(admin.ModelAdmin):
    """Administrador para el modelo Plano"""
    list_display = ('nombre_plano', 'subido_por', 'fecha_subida')
    list_filter = ('fecha_subida', 'subido_por')
    search_fields = ('nombre_plano', 'subido_por__username')
    readonly_fields = ('fecha_subida',)
    
    def save_model(self, request, obj, form, change):
        if not change:  # Si es un nuevo plano
            obj.subido_por = request.user
        super().save_model(request, obj, form, change)

@admin.register(Lote)
class LoteAdmin(admin.ModelAdmin):
    """Administrador para el modelo Lote"""
    list_display = ('nombre', 'id_plano', 'estado', 'precio', 'area_m2', 'forma')
    list_filter = ('estado', 'forma', 'id_plano')
    search_fields = ('nombre', 'id_plano__nombre_plano')
    list_editable = ('estado', 'precio')
    
    fieldsets = (
        ('Información Básica', {
            'fields': ('nombre', 'id_plano', 'estado')
        }),
        ('Detalles Técnicos', {
            'fields': ('coordenadas', 'area_m2', 'forma')
        }),
        ('Información Comercial', {
            'fields': ('precio',)
        }),
    )

@admin.register(Venta)
class VentaAdmin(admin.ModelAdmin):
    """Administrador para el modelo Venta"""
    list_display = ('id', 'id_lote', 'id_comprador', 'precio_venta', 'fecha_venta')
    list_filter = ('fecha_venta', 'id_lote__id_plano')
    search_fields = ('id_lote__nombre', 'id_comprador__username', 'id_comprador__nombre')
    readonly_fields = ('fecha_venta',)
    
    def save_model(self, request, obj, form, change):
        super().save_model(request, obj, form, change)
        
        # Marcar el lote como vendido
        if obj.id_lote:
            obj.id_lote.estado = 'vendido'
            obj.id_lote.save()
        
        # Registrar en el log
        LogActividad.objects.create(
            id_usuario=request.user,
            accion=f'Venta registrada por {request.user.username}: Lote {obj.id_lote.nombre} vendido a {obj.id_comprador.nombre}'
        )

@admin.register(LogActividad)
class LogActividadAdmin(admin.ModelAdmin):
    """Administrador para el modelo LogActividad"""
    list_display = ('id_usuario', 'accion', 'fecha')
    list_filter = ('fecha', 'id_usuario')
    search_fields = ('accion', 'id_usuario__username')
    readonly_fields = ('fecha',)
    
    def has_add_permission(self, request):
        """Prevenir la creación manual de logs"""
        return False
    
    def has_change_permission(self, request, obj=None):
        """Prevenir la edición de logs"""
        return False
    
    def has_delete_permission(self, request, obj=None):
        """Solo superusuarios pueden eliminar logs"""
        return request.user.is_superuser

# Personalización del sitio de administración
admin.site.site_header = "Administración de Lotes"
admin.site.site_title = "Lotes Admin"
admin.site.index_title = "Panel de Administración"