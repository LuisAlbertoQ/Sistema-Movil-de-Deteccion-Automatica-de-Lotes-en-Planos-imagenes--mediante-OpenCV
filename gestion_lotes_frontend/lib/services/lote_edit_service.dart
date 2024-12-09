import 'package:http/http.dart' as http;
import 'dart:convert';

class LoteService {
  static const String _baseUrl = 'http://192.168.1.46:8000';

  Future<dynamic> obtenerDetalleLote(int loteId, String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/lote/$loteId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('No se pudo obtener el detalle del lote');
    }
  }

  Future<void> actualizarLote(
      int loteId,
      String token,
      String nombre,
      String estado,
      double precio
      ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/editar-lote/$loteId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'nombre': nombre,
        'estado': estado,
        'precio': precio,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudo actualizar el lote');
    }
  }
}