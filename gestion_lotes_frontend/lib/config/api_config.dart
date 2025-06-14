class ApiConfig {
  // Cambiar solo esta URL cuando necesites
  static const String _baseUrl = 'http://192.168.1.53:8000';

  // Endpoints específicos
  static const String tokenEndpoint = '$_baseUrl/api/token/';
  static const String registerEndpoint = '$_baseUrl/registro/';
  static const String logActividadEndpoint = '$_baseUrl/log-actividad/';
  static const String uploadPlanoEndpoint = '$_baseUrl/subir-plano/';
  static const String compradoresEndpoint = '$_baseUrl/compradores/';
  static const String ventasEndpoint = '$_baseUrl/listar-ventas/';
  static const String ventaEndpoint = '$_baseUrl/venta/';
  static const String obtenerLotesEndpoint = '$_baseUrl/obtener-lotes/';

  // Métodos para endpoints dinámicos
  static String loteEndpoint(int loteId) => '$_baseUrl/lote/$loteId';
  static String editarLoteEndpoint(int loteId) => '$_baseUrl/editar-lote/$loteId';
  static String editarVentaEndpoint(int ventaId) => '$_baseUrl/editar-venta/$ventaId/';
  static String eliminarVentaEndpoint(int ventaId) => '$_baseUrl/eliminar-venta/$ventaId/';

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
  };
}