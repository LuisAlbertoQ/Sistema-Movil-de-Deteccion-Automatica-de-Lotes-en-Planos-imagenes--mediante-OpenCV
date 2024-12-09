class Lote {
  int id;
  String nombre;
  String estado;
  double precio;

  Lote({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.precio,
  });

  // Método de fábrica para crear un Lote desde un mapa JSON
  factory Lote.fromJson(Map<String, dynamic> json) {
    return Lote(
      id: json['id'],
      nombre: json['nombre'],
      estado: json['estado'],
      precio: json['precio'].toDouble(),
    );
  }

  // Método para convertir un Lote a un mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'estado': estado,
      'precio': precio,
    };
  }
}