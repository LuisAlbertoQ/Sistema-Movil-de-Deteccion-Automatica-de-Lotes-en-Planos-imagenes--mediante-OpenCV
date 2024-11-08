import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrarVentaScreen extends StatefulWidget {
  final String token;
  final int idLote;
  final dynamic precio;
  final String nombreLote;

  const RegistrarVentaScreen({
    Key? key,
    required this.token,
    required this.idLote,
    required this.precio,
    required this.nombreLote,
  }) : super(key: key);

  @override
  _RegistrarVentaScreenState createState() => _RegistrarVentaScreenState();
}

class _RegistrarVentaScreenState extends State<RegistrarVentaScreen> {
  late TextEditingController loteController;
  late TextEditingController precioController;
  final TextEditingController condicionesController = TextEditingController();
  final TextEditingController buscarCompradorController = TextEditingController();

  int? compradorSeleccionadoId;
  List<Map<String, dynamic>> compradores = [];
  List<Map<String, dynamic>> compradoresFiltrados = [];
  bool mostrarListaCompradores = false; // Nuevo estado para controlar la visibilidad

  @override
  void initState() {
    super.initState();
    loteController = TextEditingController(text: widget.idLote.toString());
    precioController = TextEditingController(text: widget.precio?.toString() ?? '0.0');
    _cargarCompradores();
  }

  Future<void> _cargarCompradores() async {
    final url = Uri.parse('http://10.0.2.2:8000/compradores/');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${widget.token}',
    });

    if (response.statusCode == 200) {
      setState(() {
        compradores = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        compradoresFiltrados = compradores;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar la lista de compradores')),
      );
    }
  }

  void _filtrarCompradores(String query) {
    setState(() {
      compradoresFiltrados = compradores
          .where((comprador) => comprador['nombre']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> registrarVenta() async {
    final url = Uri.parse('http://10.0.2.2:8000/venta/');
    final body = jsonEncode({
      'id_lote': widget.idLote,
      'id_comprador': compradorSeleccionadoId,
      'precio_venta': precioController.text.trim(),
      'condiciones': condicionesController.text.trim(),
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Venta registrada exitosamente')),
      );
      Navigator.pop(context);
    } else {
      final errorMsg = jsonDecode(response.body)['error'] ?? 'Error al registrar venta';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Venta')),
      body: GestureDetector(
        onTap: () {
          // Ocultar la lista si se toca fuera del campo de búsqueda
          setState(() {
            mostrarListaCompradores = false;
          });
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Lote: ${widget.nombreLote}'),
              TextField(
                controller: loteController,
                decoration: InputDecoration(labelText: 'ID del Lote'),
                keyboardType: TextInputType.number,
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: buscarCompradorController,
                decoration: InputDecoration(
                  labelText: 'Buscar Comprador',
                  suffixIcon: compradorSeleccionadoId != null
                      ? IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        compradorSeleccionadoId = null;
                        buscarCompradorController.clear();
                      });
                    },
                  )
                      : null,
                ),
                onTap: () {
                  setState(() {
                    mostrarListaCompradores = true;
                  });
                },
                onChanged: (value) {
                  _filtrarCompradores(value);
                  setState(() {
                    mostrarListaCompradores = true;
                  });
                },
              ),
              const SizedBox(height: 8),
              if (mostrarListaCompradores && compradorSeleccionadoId == null)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView.builder(
                      itemCount: compradoresFiltrados.length,
                      itemBuilder: (context, index) {
                        final comprador = compradoresFiltrados[index];
                        return ListTile(
                          title: Text(comprador['nombre']),
                          onTap: () {
                            setState(() {
                              compradorSeleccionadoId = comprador['id'];
                              buscarCompradorController.text = comprador['nombre'];
                              mostrarListaCompradores = false;
                            });
                            FocusScope.of(context).unfocus();
                          },
                        );
                      },
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      TextField(
                        controller: precioController,
                        decoration: InputDecoration(labelText: 'Precio de Venta'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: condicionesController,
                        decoration: InputDecoration(labelText: 'Condiciones'),
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: compradorSeleccionadoId == null ? null : registrarVenta,
                child: Text('Registrar Venta'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}