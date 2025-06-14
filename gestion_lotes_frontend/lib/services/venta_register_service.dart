import 'package:http/http.dart' as http;
import 'dart:convert';

class VentaService {
  final String baseUrl = 'http://192.168.1.53:8000';

  Future<List<dynamic>> obtenerCompradores(String token) async {
    final url = Uri.parse('$baseUrl/compradores/');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar la lista de compradores');
    }
  }

  Future<bool> registrarVenta({
    required String token,
    required int idLote,
    required int idComprador,
    required String precioVenta,
    required String condiciones,
  }) async {
    final url = Uri.parse('$baseUrl/venta/');
    final body = jsonEncode({
      'id_lote': idLote,
      'id_comprador': idComprador,
      'precio_venta': precioVenta,
      'condiciones': condiciones,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    return response.statusCode == 201;
  }
}