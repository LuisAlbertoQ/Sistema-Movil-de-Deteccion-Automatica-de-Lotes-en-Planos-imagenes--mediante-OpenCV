import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestion_lotes_frontend/components/decorative_background.dart';
import '../services/lote_edit_service.dart';

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

  // Instancia del servicio de lotes
  final LoteService _loteService = LoteService();

  Future<void> cargarDatosLote() async {
    try {
      var data = await _loteService.obtenerDetalleLote(widget.loteId, widget.token);
      setState(() {
        nombreController.text = data['nombre'];
        estadoController.text = data['estado'];
        precioController.text = data['precio'].toString();
      });
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar los datos del lote')),
      );
    }
  }

  Future<void> actualizarLote() async {
    try {
      final resultado = await _loteService.actualizarLote(
          widget.loteId,
          widget.token,
          nombreController.text,
          estadoController.text,
          double.parse(precioController.text)
      );

      // Mostrar SnackBar de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Lote actualizado correctamente',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context, true); // Pasar true para indicar actualización exitosa
    } catch (e) {
      // Mostrar SnackBar de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Error al actualizar el lote',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
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
          DecorativeBackground(),
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
                              labelStyle: const TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.blue, width: 1.0),
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
                              labelStyle: const TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.blue, width: 1.0),
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