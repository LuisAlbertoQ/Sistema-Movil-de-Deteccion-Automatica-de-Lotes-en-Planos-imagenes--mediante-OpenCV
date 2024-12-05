import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/log_actividad_model.dart';

class LogActividadService {
  static const String baseUrl = "http://192.168.1.46:8000/log-actividad/";

  static Future<List<LogActividad>> fetchLogs(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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