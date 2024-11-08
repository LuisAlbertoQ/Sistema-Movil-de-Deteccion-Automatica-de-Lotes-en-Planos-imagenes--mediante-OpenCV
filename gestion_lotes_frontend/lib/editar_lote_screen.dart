import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditarLoteScreen extends StatefulWidget {
  final int loteId;  // Recibe el ID del lote desde la pantalla anterior
  final String token; // Token para la autenticación

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
      Uri.parse('http://10.0.2.2:8000/lote/${widget.loteId}'), // Cambia a 'detalle-lote'
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
      appBar: AppBar(title: Text('Editar Lote')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextFormField(
                controller: estadoController,
                decoration: InputDecoration(labelText: 'Estado'),
              ),
              TextFormField(
                controller: precioController,
                decoration: InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: actualizarLote,
                child: Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
