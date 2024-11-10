import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditarLoteScreen extends StatefulWidget {
  final int loteId;
  final String token;

  EditarLoteScreen({required this.loteId, required this.token});

  @override
  _EditarLoteScreenState createState() => _EditarLoteScreenState();
}

class _EditarLoteScreenState extends State<EditarLoteScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de los campos
  TextEditingController nombreController = TextEditingController();
  TextEditingController estadoController = TextEditingController();
  TextEditingController precioController = TextEditingController();

  // Método para cargar datos del lote
  Future<void> cargarDatosLote() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/lote/${widget.loteId}'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        nombreController.text = data['nombre'];
        estadoController.text = data['estado'];
        precioController.text = data['precio'].toString();
      });
    } else {
      // Manejo del error si no se pudo obtener el detalle del lote
    }
  }

  // Método para actualizar datos del lote
  Future<void> actualizarLote() async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8000/editar-lote/${widget.loteId}'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'nombre': nombreController.text,
        'estado': estadoController.text,
        'precio': double.parse(precioController.text),
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context); // Volver a la pantalla anterior
    } else {
      // Manejar error si no se pudo actualizar
    }
  }

  @override
  void initState() {
    super.initState();
    cargarDatosLote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Lote'),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 30.0, vertical: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Título
                      const Text(
                        'Editar Lote',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Campos de texto
                      Column(
                        children: [
                          TextField(
                            cursorColor: Colors.black,
                            controller: nombreController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: 'Nombre',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue, width: 1.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16), // Espacio entre campos
                          TextFormField(
                            cursorColor: Colors.black,
                            controller: estadoController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: 'Estado',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue, width: 1.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            cursorColor: Colors.black,
                            controller: precioController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: 'Precio',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blue, width: 1.0),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                      // Botón para guardar cambios
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          elevation: 3,
                        ),
                        onPressed: actualizarLote,
                        child: const Text(
                          'Guardar Cambios',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
