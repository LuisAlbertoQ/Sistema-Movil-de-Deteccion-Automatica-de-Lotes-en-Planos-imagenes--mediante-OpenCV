class VentaModel {
  final int id;
  final int idComprador;
  final int idLote;
  final double precioVenta;
  final String? condiciones;

  VentaModel({
    required this.id,
    required this.idComprador,
    required this.idLote,
    required this.precioVenta,
    this.condiciones,
  });

  factory VentaModel.fromJson(Map<String, dynamic> json) {
    return VentaModel(
      id: json['id'],
      idComprador: json['id_comprador'],
      idLote: json['id_lote'],
      precioVenta: double.parse(json['precio_venta'].toString()),
      condiciones: json['condiciones'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'id_comprador': idComprador,
    'id_lote': idLote,
    'precio_venta': precioVenta,
    'condiciones': condiciones,
  };
}