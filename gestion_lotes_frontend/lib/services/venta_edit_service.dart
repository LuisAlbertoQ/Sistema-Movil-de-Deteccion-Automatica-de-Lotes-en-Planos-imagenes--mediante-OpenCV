import 'package:gestion_lotes_frontend/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VentaService {

  Future<bool> actualizarVenta({
    required String token,
    required int ventaId,
    required double precio,
    required String condiciones
  }) async {
    final url = Uri.parse(ApiConfig.editarVentaEndpoint(ventaId));
    final response = await http.put(
      url,
      headers: ApiConfig.authHeaders(token),
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
    final url = Uri.parse(ApiConfig.eliminarVentaEndpoint(ventaId));
    final response = await http.delete(
      url,
      headers: ApiConfig.authHeaders(token),
    );

    return response.statusCode == 204;
  }
}