import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  // Claves para SharedPreferences
  static const String _tokenKey = 'auth_token';
  static const String _rolKey = 'user_rol';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';

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

      // NUEVO: Guardar datos de autenticación
      await _saveAuthData(data, username);

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

  // NUEVO: Método para guardar datos de autenticación
  static Future<void> _saveAuthData(Map<String, dynamic> data, String username) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, data['access'] ?? '');
    await prefs.setString(_rolKey, data['rol'] ?? '');
    await prefs.setString(_usernameKey, username);

    // Si tu API retorna user_id, guárdalo también
    if (data.containsKey('user_id')) {
      await prefs.setString(_userIdKey, data['user_id'].toString());
    }
  }

  // NUEVO: Método para obtener el token guardado
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // NUEVO: Método para obtener el rol guardado
  static Future<String?> getRol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rolKey);
  }

  // NUEVO: Método para obtener el username guardado
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  // NUEVO: Método para obtener todos los datos de autenticación
  static Future<Map<String, String?>> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString(_tokenKey),
      'rol': prefs.getString(_rolKey),
      'username': prefs.getString(_usernameKey),
      'user_id': prefs.getString(_userIdKey),
    };
  }

  // NUEVO: Método para verificar si está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // NUEVO: Método para cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_rolKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_userIdKey);
  }

  // NUEVO: Método para limpiar todos los datos (opcional)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}