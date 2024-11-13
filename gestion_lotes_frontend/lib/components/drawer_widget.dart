import 'package:flutter/material.dart';
import 'package:gestion_lotes_frontend/ventas/listar_ventas_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home_screen.dart';
import '../listado_planos_screen.dart';
import '../main.dart';

class CustomDrawer extends StatefulWidget {
  final String token;
  final String rol;
  final VoidCallback onLogout;

  const CustomDrawer({
    Key? key,
    required this.token,
    required this.onLogout,
    required this.rol,
  }) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> with SingleTickerProviderStateMixin {
  String username = '';
  String email = '';
  String rol = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    obtenerPerfilUsuario();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> obtenerPerfilUsuario() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/obtener-perfil/'),
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
        print('Error al obtener el perfil del usuario');
      }
    } catch (e) {
      print('Error de conexión: $e');
    }
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.blue.shade700, size: 26),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.grey.shade800,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      hoverColor: Colors.blue.shade50,
      selectedTileColor: Colors.blue.shade50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade700,
                      Colors.blue.shade500,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        username,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          rol.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildDrawerItem(
                icon: Icons.home,
                title: 'Inicio',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(token: widget.token, rol: widget.rol,),
                    ),
                  );
                },
              ),
              _buildDrawerItem(
                icon: Icons.map,
                title: 'Planos',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListadoPlanosScreen(token: widget.token, rol: widget.rol,),
                    ),
                  );
                },
              ),
              if (widget.rol == 'admin' || widget.rol == 'agente')
              _buildDrawerItem(
                icon: Icons.attach_money,
                title: 'Ventas',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListarVentasScreen(token: widget.token, rol: widget.rol,),
                    ),
                  );
                },
              ),
              Expanded(child: Container()),
              Divider(color: Colors.grey.withOpacity(0.3)),
              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Cerrar Sesión',
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: Colors.blue.shade100, // Color de fondo del diálogo
                      title: Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700, // Color del título
                        ),
                      ),
                      content: Text(
                        '¿Está seguro que desea cerrar sesión?',
                        style: TextStyle(color: Colors.grey.shade600), // Color del contenido
                      ),
                      actions: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400), // Color del borde
                            borderRadius: BorderRadius.circular(8), // Bordes redondeados
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onLogout();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Espaciado del botón
                            decoration: BoxDecoration(
                              color: Colors.red.shade400, // Color de fondo del botón
                              borderRadius: BorderRadius.circular(8), // Bordes redondeados
                            ),
                            child: const Text(
                              'Cerrar Sesión',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
        ),
      ),
    );
  }
}