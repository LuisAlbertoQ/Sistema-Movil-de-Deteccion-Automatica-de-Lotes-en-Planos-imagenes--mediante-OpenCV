import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

import '../models/log_actividad_model.dart';

class LogActividadService {
  static Future<List<LogActividad>> fetchLogs(String token) async {
    final response = await http.get(
      Uri.parse(ApiConfig.logActividadEndpoint),
      headers: ApiConfig.authHeaders(token),
    );

    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((log) => LogActividad.fromJson(log))
          .toList();
    } else {
      throw Exception('Error al obtener logs de actividad');
    }
  }
}