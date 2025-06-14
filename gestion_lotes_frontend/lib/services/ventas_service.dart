import 'package:gestion_lotes_frontend/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VentasService {
  static Future<List<dynamic>> fetchVentas(String token) async {
    final url = Uri.parse(ApiConfig.ventasEndpoint);
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