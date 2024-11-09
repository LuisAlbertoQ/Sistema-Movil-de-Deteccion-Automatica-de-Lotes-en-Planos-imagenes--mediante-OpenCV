import 'package:flutter/material.dart';
import 'package:gestion_lotes_frontend/ventas/listar_ventas_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home_screen.dart';
import '../listado_planos_screen.dart';
import '../main.dart';

class CustomDrawer extends StatefulWidget {
  final String token;
  final VoidCallback onLogout;

  const CustomDrawer({
    Key? key,
    required this.token,
    required this.onLogout,
  }) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String username = '';
  String email = '';
  String rol = '';

  @override
  void initState() {
    super.initState();
    obtenerPerfilUsuario();
  }

  // Método para obtener el perfil del usuario desde el backend
  Future<void> obtenerPerfilUsuario() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/obtener-perfil/'), // URL de la función obtener_perfil_usuario
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        username = data['username'];
        email = data['email'];
        rol = data['rol'];
      });
    } else {
      // Manejo de errores si no se obtiene el perfil
      print('Error al obtener el perfil del usuario');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            accountName: Text(
              '$username ($rol)', // Mostrar el nombre de usuario y el rol
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              email,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.blue,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Inicio'),
            onTap: () {
              Navigator.pop(context); // Cierra el drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(token: widget.token),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Planos'),
            onTap: () {
              Navigator.pop(context); // Cierra el drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ListadoPlanosScreen(token: widget.token),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.attach_money),
            title: Text('Ventas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListarVentasScreen(token: widget.token),
                ),
              );
            },
          ),
          Expanded(child: Container()), // Espaciador
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Cerrar Sesión'),
                  content: Text('¿Está seguro que desea cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Cierra el diálogo
                        widget.onLogout(); // Ejecuta la función de logout
                      },
                      child: Text(
                        'Cerrar Sesión',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

