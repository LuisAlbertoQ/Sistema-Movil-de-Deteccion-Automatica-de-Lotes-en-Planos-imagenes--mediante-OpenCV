import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterService {
  static const String _baseUrl = 'http://192.168.1.46:8000/registro/';

  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String password,
    required String email,
    required String nombre,
    String rol = 'usuario',
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept-Charset': 'utf-8'
        },
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