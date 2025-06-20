from django.http import HttpResponseForbidden
from django.contrib.auth import get_user_model
from django.utils.deprecation import MiddlewareMixin
import logging

User = get_user_model()
logger = logging.getLogger(__name__)

class AdminAccessMiddleware(MiddlewareMixin):
    """
    Middleware para controlar el acceso al panel de administración
    """
    def process_request(self, request):
        # Solo aplicar a rutas del admin
        if request.path.startswith('/panel/'):
            # Permitir acceso a la página de login
            if request.path.startswith('/panel/login/'):
                return None
            
            # Verificar si el usuario está autenticado
            if not request.user.is_authenticated:
                return None  # Django redirigirá al login
            
            # Verificar si el usuario tiene permisos de admin o agente
            if not (request.user.is_superuser or 
                   request.user.rol in ['admin', 'agente']):
                logger.warning(f"Intento de acceso no autorizado al admin por {request.user.username}")
                return HttpResponseForbidden("No tienes permisos para acceder a esta área.")
        
        return None

class LoginAttemptMiddleware(MiddlewareMixin):
    """
    Middleware para rastrear intentos de login
    """
    def process_response(self, request, response):
        # Rastrear intentos de login fallidos
        if (request.path.startswith('/panel/login/') and 
            request.method == 'POST' and 
            response.status_code == 200 and
            'errorlist' in response.content.decode('utf-8')):
            
            username = request.POST.get('username', 'Unknown')
            logger.warning(f"Intento de login fallido para usuario: {username} desde IP: {request.META.get('REMOTE_ADDR')}")
        
        return response