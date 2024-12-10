import 'package:http/http.dart' as http;
import 'dart:convert';

class VentasService {
  static Future<List<dynamic>> fetchVentas(String token) async {
    final url = Uri.parse('http://192.168.1.46:8000/listar-ventas/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener ventas');
    }
  }
}