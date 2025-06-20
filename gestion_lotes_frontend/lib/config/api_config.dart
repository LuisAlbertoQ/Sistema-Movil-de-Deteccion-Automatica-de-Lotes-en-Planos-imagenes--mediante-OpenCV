// lib/config/api_config.dart
class ApiConfig {
  // Cambiar solo esta URL cuando necesites
  static const String baseUrl = 'http://172.22.8.28:8000';

  // Endpoints específicos
  static const String tokenEndpoint = '$baseUrl/api/token/';
  static const String registerEndpoint = '$baseUrl/registro/';
  static const String logActividadEndpoint = '$baseUrl/log-actividad/';
  static const String uploadPlanoEndpoint = '$baseUrl/subir-plano/';
  static const String compradoresEndpoint = '$baseUrl/compradores/';
  static const String ventasEndpoint = '$baseUrl/listar-ventas/';
  static const String ventaEndpoint = '$baseUrl/venta/';
  static const String planosEndpoint = '$baseUrl/listar-planos/';
  static const String perfilUsuarioEndpoint = '$baseUrl/obtener-perfil/';

  // Métodos para endpoints dinámicos
  static String loteEndpoint(int loteId) => '$baseUrl/lote/$loteId';
  static String editarLoteEndpoint(int loteId) => '$baseUrl/editar-lote/$loteId';
  static String editarVentaEndpoint(int ventaId) => '$baseUrl/editar-venta/$ventaId/';
  static String eliminarVentaEndpoint(int ventaId) => '$baseUrl/eliminar-venta/$ventaId/';

  // Headers comunes
  static Map<String, String> get jsonHeaders => {
    'Content-Type': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  static Map<String, String> get jsonHeadersWithCharset => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept-Charset': 'utf-8'
  };

  // Configuración de timeouts
  static const Duration requestTimeout = Duration(seconds: 10);
}