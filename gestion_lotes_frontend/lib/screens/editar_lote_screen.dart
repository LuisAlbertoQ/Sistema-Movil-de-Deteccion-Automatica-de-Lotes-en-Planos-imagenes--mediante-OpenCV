import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestion_lotes_frontend/components/CustomDropdownField.dart';
import 'package:gestion_lotes_frontend/components/decorative_background.dart';// Importar el nuevo componente
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
  TextEditingController precioController = TextEditingController();

  // Variable para el dropdown de estado
  String? estadoSeleccionado;

  // Opciones para el dropdown
  final List<String> opcionesEstado = ['disponible', 'vendido'];

  // Instancia del servicio de lotes
  final LoteService _loteService = LoteService();

  Future<void> cargarDatosLote() async {
    try {
      var data = await _loteService.obtenerDetalleLote(widget.loteId, widget.token);
      setState(() {
        nombreController.text = data['nombre'];
        estadoSeleccionado = data['estado'];
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
    if (_formKey.currentState!.validate()) {
      try {
        final resultado = await _loteService.actualizarLote(
            widget.loteId,
            widget.token,
            nombreController.text,
            estadoSeleccionado ?? 'disponible',
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

        Navigator.pop(context, true);
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
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
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
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: const Text(
                          'Editar Lote',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Campos de entrada
                      Column(
                        children: [
                          // Campo Nombre
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              cursorColor: Colors.blue.shade600,
                              controller: nombreController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red.shade600, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelText: 'Nombre del Lote',
                                labelStyle: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: Icon(
                                  Icons.home_work_outlined,
                                  color: Colors.blue.shade600,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa el nombre del lote';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Dropdown Estado usando el componente personalizado
                          CustomDropdownField(
                            value: estadoSeleccionado,
                            items: opcionesEstado,
                            labelText: 'Estado del Lote',
                            hintText: 'Selecciona el estado',
                            onChanged: (String? nuevoEstado) {
                              setState(() {
                                estadoSeleccionado = nuevoEstado;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor selecciona un estado';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Campo Precio
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              cursorColor: Colors.blue.shade600,
                              controller: precioController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red.shade600, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelText: 'Precio',
                                labelStyle: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: Icon(
                                  Icons.attach_money,
                                  color: Colors.blue.shade600,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa el precio';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Por favor ingresa un precio válido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),

                      // Botón para guardar cambios
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade600, Colors.blue.shade800],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: actualizarLote,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Guardar Cambios',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
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