import 'package:flutter/material.dart';
import 'package:gestion_lotes_frontend/components/drawer_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'components/home_screen.dart';
import 'listado_planos_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context, String username, String password) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/token/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      // Cerrar el indicador de carga
      Navigator.pop(context);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['access'];
        final refreshToken = data['refresh'];
        final userName = data['username'];
        final userEmail = data['email'];
        final userId = data['id'];

        // Navegar a la pantalla de inicio
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(token: token.toString()),
          ),
        );
      } else {
        // Manejar errores específicos según el código de estado
        String errorMessage = 'Error en el inicio de sesión';
        if (response.statusCode == 401) {
          errorMessage = 'Usuario o contraseña incorrectos';
        } else if (response.statusCode == 400) {
          errorMessage = 'Datos de inicio de sesión inválidos';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final username = usernameController.text.trim();
                final password = passwordController.text.trim();

                if (username.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Por favor, completa todos los campos'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                login(context, username, password);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}