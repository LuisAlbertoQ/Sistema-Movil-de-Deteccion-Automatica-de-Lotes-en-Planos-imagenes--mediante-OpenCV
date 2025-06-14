import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class LoteService {

  Future<dynamic> obtenerDetalleLote(int loteId, String token) async {
    final response = await http.get(
      Uri.parse(ApiConfig.loteEndpoint(loteId)),
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
      Uri.parse(ApiConfig.editarLoteEndpoint(loteId)),
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