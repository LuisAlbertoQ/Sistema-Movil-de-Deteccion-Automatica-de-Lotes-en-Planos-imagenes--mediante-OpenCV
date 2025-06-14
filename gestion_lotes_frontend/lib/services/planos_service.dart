import 'package:gestion_lotes_frontend/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/plano_model.dart';

class PlanosService {

  // Obtener lista de planos
  static Future<List<PlanoModel>> obtenerPlanos(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.planosEndpoint),
        headers: ApiConfig.authHeaders(token),
      ).timeout(
        ApiConfig.requestTimeout,
        onTimeout: () {
          throw Exception('Tiempo de espera agotado. Verifica tu conexión.');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((plano) => PlanoModel.fromJson(plano)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor, vuelva a iniciar sesión.');
      } else {
        throw Exception('Error al obtener los planos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Método para obtener la URL base
  static String getBaseUrl() {
    return ApiConfig.baseUrl;
  }
}