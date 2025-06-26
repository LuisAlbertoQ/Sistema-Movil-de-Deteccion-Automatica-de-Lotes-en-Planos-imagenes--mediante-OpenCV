import 'package:gestion_lotes_frontend/core/utils/time_utils.dart';

class Plano {
  final String nombre;
  final String urlImagen;
  final DateTime fechaSubida;

  Plano({
    required this.nombre,
    required this.urlImagen,
    required this.fechaSubida,
  });

  factory Plano.fromJson(Map<String, dynamic> json) {
    return Plano(
      nombre: json['nombre_plano'],
      urlImagen: json['url_imagen'],
      fechaSubida: DateTime.parse(json['fecha_subida']),
    );
  }
}

class PlanoModel {
  final int? id;
  final String? nombrePlano;
  final String? imagen;
  final String? subidoPor;
  final String? fechaSubida;

  PlanoModel({
    this.id,
    this.nombrePlano,
    this.imagen,
    this.subidoPor,
    this.fechaSubida,
  });

  factory PlanoModel.fromJson(Map<String, dynamic> json) {
    return PlanoModel(
      id: json['id'],
      nombrePlano: json['nombre_plano'],
      imagen: json['imagen'],
      subidoPor: json['subido_por'],
      fechaSubida: json['fecha_subida'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_plano': nombrePlano,
      'imagen': imagen,
      'subido_por': subidoPor,
      'fecha_subida': fechaSubida,
    };
  }

  // Getter para obtener la URL completa de la imagen
  String getImageUrl(String baseUrl) {
    return imagen != null ? '$baseUrl$imagen' : '';
  }

  // Getter para verificar si tiene nombre
  String get displayName {
    return nombrePlano ?? 'Sin nombre';
  }

  // Getter para verificar si tiene usuario
  String get displaySubidoPor {
    return subidoPor ?? 'Desconocido';
  }

  DateTime? get fechaSubidaLocal {
    if (fechaSubida == null) return null;
    return TimeUtils.parseFromApi(fechaSubida!);
  }

  // Método para formatear la fecha ya convertida
  String get fechaSubidaFormateada {
    if (fechaSubida == null) return 'No disponible';
    return TimeUtils.formatToLimaTime(
        TimeUtils.parseFromApi(fechaSubida!),
        format: 'dd/MM/yyyy HH:mm'
    );
  }
}