import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.tokenEndpoint),
      headers: ApiConfig.jsonHeadersWithCharset,
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      String errorMessage = 'Error en el inicio de sesión';
      if (response.statusCode == 401) {
        errorMessage = 'Usuario o contraseña incorrectos';
      } else if (response.statusCode == 400) {
        errorMessage = 'Datos de inicio de sesión inválidos';
      }
      throw Exception(errorMessage);
    }
  }
}