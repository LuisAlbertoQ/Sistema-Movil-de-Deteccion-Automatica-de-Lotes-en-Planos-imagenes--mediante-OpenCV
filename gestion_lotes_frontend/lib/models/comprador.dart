class Comprador {
  final int id;
  final String nombre;

  Comprador({
    required this.id,
    required this.nombre,
  });

  factory Comprador.fromJson(Map<String, dynamic> json) {
    return Comprador(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}