class LogActividad {
  final String usuario;
  final String accion;
  final String fecha;

  LogActividad({
    required this.usuario,
    required this.accion,
    required this.fecha
  });

  factory LogActividad.fromJson(Map<String, dynamic> json) {
    return LogActividad(
      usuario: json['id_usuario'].toString(),
      accion: json['accion'],
      fecha: json['fecha'],
    );
  }
}