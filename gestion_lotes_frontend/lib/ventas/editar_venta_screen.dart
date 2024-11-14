import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

    final url = Uri.parse('http://10.0.2.2:8000/editar-venta/${widget.ventaId}/');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode({
        'precio_venta': double.parse(_precioController.text),
        'condiciones': _condicionesController.text,
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
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

    final url = Uri.parse('http://10.0.2.2:8000/eliminar-venta/${widget.ventaId}/');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 204) {
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
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión'),
          backgroundColor: Colors.red,
        ),
      );
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
                      TextField(
                        cursorColor: Colors.black,
                        controller: _precioController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelText: 'Precio de Venta',
                          labelStyle: const TextStyle(
                            color: Colors.blue
                          ),
                          prefixIcon: Icon(Icons.attach_money, color: Colors.blue.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        cursorColor: Colors.black,
                        controller: _condicionesController,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelText: 'Condiciones',
                          labelStyle: const TextStyle(
                              color: Colors.blue
                          ),
                          prefixIcon: Icon(Icons.description, color: Colors.blue.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
}