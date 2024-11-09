import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditarVentaScreen extends StatefulWidget {
  final String token;
  final int ventaId;
  final double precio;
  final String condiciones;

  const EditarVentaScreen({
    Key? key,
    required this.token,
    required this.ventaId,
    required this.precio,
    required this.condiciones,
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
      Navigator.pop(context, true); // Vuelve a la lista de ventas y actualiza
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venta actualizada correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar la venta')),
      );
    }
  }

  Future<void> eliminarVenta() async {
    // Mostrar diálogo de confirmación
    bool confirmar = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
        // Si la eliminación fue exitosa, volver a la pantalla anterior
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Venta eliminada correctamente'),
            backgroundColor: Colors.green,
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
        title: const Text('Editar Venta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: isLoading ? null : eliminarVenta,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _precioController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio de Venta'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _condicionesController,
              decoration: const InputDecoration(labelText: 'Condiciones'),
            ),
            const SizedBox(height: 32),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: actualizarVenta,
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
