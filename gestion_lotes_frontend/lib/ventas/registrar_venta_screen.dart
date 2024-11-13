import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrarVentaScreen extends StatefulWidget {
  final String token;
  final int idLote;
  final dynamic precio;
  final String nombreLote;
  final String rol;

  const RegistrarVentaScreen({
    Key? key,
    required this.token,
    required this.idLote,
    required this.precio,
    required this.nombreLote,
    required this.rol,
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
  bool mostrarListaCompradores = false;

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
        SnackBar(
          content: const Text(
            'Venta registrada exitosamente',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
      appBar: AppBar(
        title: Text('Registrar Venta'),
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Fondo con patrón de gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.white,
                  Colors.blue.shade50,
                ],
              ),
            ),
          ),
          // Círculos decorativos
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.05),
              ),
            ),
          ),
          // Contenido principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets .symmetric(horizontal: 30.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Título
                    const Text(
                      'Registrar Venta',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Texto de Lote
                    Text(
                      'Lote: ${widget.nombreLote}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Campos de texto
                    Column(
                      children: [
                        TextField(
                          controller: loteController,
                          decoration: InputDecoration(
                            labelText: 'ID del Lote',
                            labelStyle: TextStyle(color: Colors.grey.shade600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue, width: 1.0),
                            ),
                          ),
                          enabled: false,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          cursorColor: Colors.black,
                          controller: buscarCompradorController,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            labelText: 'Buscar Comprador',
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue, width: 1.0),
                            ),
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
                        const SizedBox(height: 16),

                        // Lista de compradores o campos adicionales
                        if (mostrarListaCompradores && compradorSeleccionadoId == null)
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
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
                          )
                        else if (compradorSeleccionadoId != null) ...[
                          TextField(
                            cursorColor: Colors.black,
                            controller: precioController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: 'Precio de Venta',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue, width: 1.0),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            cursorColor: Colors.black,
                            controller: condicionesController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: 'Condiciones',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue, width: 1.0),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                        ],
                        const SizedBox(height: 20),

                        // Botón de Registrar Venta
                        ElevatedButton(
                          onPressed: compradorSeleccionadoId == null ? null : registrarVenta,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            elevation: 3,
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: const Text(
                            'Registrar Venta',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}