import 'package:flutter/material.dart';
import 'package:gestion_lotes_frontend/components/decorative_background.dart';
import '../services/venta_edit_service.dart';
import '../components/venta_form_field.dart';

class EditarVentaScreen extends StatefulWidget {
  final String token;
  final int ventaId;
  final double precio;
  final String condiciones;
  final String rol;

  const EditarVentaScreen({
    Key? key,
    required this.token,
    required this.ventaId,
    required this.precio,
    required this.condiciones,
    required this.rol,
  }) : super(key: key);

  @override
  _EditarVentaScreenState createState() => _EditarVentaScreenState();
}

class _EditarVentaScreenState extends State<EditarVentaScreen> {
  late TextEditingController _precioController;
  late TextEditingController _condicionesController;
  bool isLoading = false;
  final VentaService _ventaService = VentaService();

  @override
  void initState() {
    super.initState();
    _precioController = TextEditingController(text: widget.precio.toString());
    _condicionesController = TextEditingController(text: widget.condiciones.toString());
  }

  Future<void> actualizarVenta() async {
    setState(() {
      isLoading = true;
    });

    try {
      final success = await _ventaService.actualizarVenta(
        token: widget.token,
        ventaId: widget.ventaId,
        precio: double.parse(_precioController.text),
        condiciones: _condicionesController.text,
      );

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Venta actualizada correctamente',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Error al actualizar la venta',
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> eliminarVenta() async {
    bool confirmar = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue.shade50,
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Está seguro que desea eliminar esta venta?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    setState(() {
      isLoading = true;
    });

    try {
      final success = await _ventaService.eliminarVenta(
        token: widget.token,
        ventaId: widget.ventaId,
      );

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Venta eliminada correctamente',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar la venta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Editar Venta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.blue.shade600),
        actions: [
          if (widget.rol == 'admin')
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: isLoading ? null : eliminarVenta,
            ),
        ],
      ),
      body: Stack(
        children: [
          // Fondo con patrón de gradiente
          DecorativeBackground(),
          // Contenido principal
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Editar Detalles de Venta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      VentaFormField(
                        controller: _precioController,
                        labelText: 'Precio de Venta',
                        prefixIcon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      VentaFormField(
                        controller: _condicionesController,
                        labelText: 'Condiciones',
                        prefixIcon: Icons.description,
                      ),
                      const SizedBox(height: 32),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: actualizarVenta,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Guardar Cambios',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  @override
  void dispose() {
    _precioController.dispose();
    _condicionesController.dispose();
    super.dispose();
  }
}