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