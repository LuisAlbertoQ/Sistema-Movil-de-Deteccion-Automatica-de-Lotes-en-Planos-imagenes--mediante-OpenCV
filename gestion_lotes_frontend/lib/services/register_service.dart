import 'dart:convert';
import 'package:gestion_lotes_frontend/config/api_config.dart';
import 'package:http/http.dart' as http;

class RegisterService {
  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String password,
    required String email,
    required String nombre,
    String rol = 'usuario',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerEndpoint),
        headers: ApiConfig.jsonHeadersWithCharset,
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
          'nombre': nombre,
          'rol': rol,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return responseBody;
      } else {
        // Manejo de errores específicos
        if (responseBody.containsKey('username')) {
          throw Exception(responseBody['username']);
        } else if (responseBody.containsKey('email')) {
          throw Exception(responseBody['email']);
        } else if (responseBody.containsKey('password')) {
          throw Exception(responseBody['password']);
        } else {
          throw Exception(responseBody['detail'] ?? 'Error al registrar');
        }
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}