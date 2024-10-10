from rest_framework.permissions import BasePermission

class IsAdmin(BasePermission):
    """
    Permiso para verificar si el usuario es administrador.
    """
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.rol == 'admin'

class IsAgenteInmobiliario(BasePermission):
    """
    Permiso para verificar si el usuario es agente inmobiliario.
    """
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.rol == 'agente'

class IsUsuario(BasePermission):
    """
    Permiso para verificar si el usuario es un usuario común.
    """
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.rol == 'usuario'