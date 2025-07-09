class LogActividad {
  final String usuario;
  final String accion;
  final String fecha;
  final String tipoAccion;

  LogActividad({
    required this.usuario,
    required this.accion,
    required this.fecha,
    required this.tipoAccion,
  });

  factory LogActividad.fromJson(Map<String, dynamic> json) {
    return LogActividad(
      usuario: json['id_usuario'].toString(),
      accion: json['accion'],
      fecha: json['fecha'],
      tipoAccion: json['tipo_accion'] ?? 'otro',
    );
  }
}