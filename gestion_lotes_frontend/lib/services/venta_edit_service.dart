import 'package:http/http.dart' as http;
import 'dart:convert';

class VentaService {
  static const String _baseUrl = 'http://192.168.1.53:8000';

  Future<bool> actualizarVenta({
    required String token,
    required int ventaId,
    required double precio,
    required String condiciones
  }) async {
    final url = Uri.parse('$_baseUrl/editar-venta/$ventaId/');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'precio_venta': precio,
        'condiciones': condiciones,
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> eliminarVenta({
    required String token,
    required int ventaId
  }) async {
    final url = Uri.parse('$_baseUrl/eliminar-venta/$ventaId/');
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 204;
  }
}