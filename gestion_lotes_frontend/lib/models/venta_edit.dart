class Venta {
  final int id;
  double precio;
  String condiciones;

  Venta({
    required this.id,
    required this.precio,
    required this.condiciones,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['id'],
      precio: json['precio_venta'].toDouble(),
      condiciones: json['condiciones'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'precio_venta': precio,
      'condiciones': condiciones,
    };
  }
}