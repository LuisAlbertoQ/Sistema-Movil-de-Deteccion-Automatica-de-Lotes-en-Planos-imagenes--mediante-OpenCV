"""
URL configuration for gestion_lotes project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from django.urls import path
from django.conf import settings
from django.conf.urls.static import static


from lotes import views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/token/', views.CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('registro/', views.registro, name='registro'),
    path('subir-plano/', views.subir_plano, name='subir_plano'),
    path('lotes/', views.listar_lotes, name='listar_lotes'),
    path('lote/<int:lote_id>/', views.detalle_lote, name='detalle_lote'),
    path('venta/', views.registrar_venta, name='registrar_venta'),
    path('log-actividad/', views.ver_log_actividad, name='ver_log_actividad'),
    path('eliminar-lote/<int:lote_id>', views.eliminar_lote, name='eliminar_lote'),
    path('eliminar-venta/<int:venta_id>/', views.eliminar_venta, name='eliminar_venta'),
    path('listar-ventas/', views.listar_ventas, name='listar_ventas'),
    path('listar-planos/', views.listar_planos, name='listar_planos'),
    path('editar-lote/<int:lote_id>', views.editar_lote, name='editar_lote'),
    path('editar-venta/<int:venta_id>/', views.editar_venta, name='editar_venta'),
    path('obtener-lotes/<int:plano_id>/', views.obtener_lotes_por_plano, name='obtener_lotes_por_plano'),
    path('obtener-perfil/', views.obtener_perfil_usuario, name='obtener_perfil_usuario'),
    path('compradores/', views.listar_compradores, name='listar_compradores'),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)