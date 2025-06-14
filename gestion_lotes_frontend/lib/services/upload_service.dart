import 'dart:io';
import 'package:gestion_lotes_frontend/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class PlanoService {
  final String token;
  PlanoService(this.token);

  Future<bool> subirPlano(File imagen, String nombrePlano) async {
    try {
      final mimeTypeData = lookupMimeType(imagen.path, headerBytes: [0xFF, 0xD8])?.split('/');

      var request = http.MultipartRequest('POST', Uri.parse(ApiConfig.uploadPlanoEndpoint));

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['nombre_plano'] = nombrePlano;

      request.files.add(
        http.MultipartFile.fromBytes(
          'imagen',
          await imagen.readAsBytes(),
          filename: imagen.path.split('/').last,
          contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
        ),
      );

      var response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      print('Error al subir plano: $e');
      return false;
    }
  }
}