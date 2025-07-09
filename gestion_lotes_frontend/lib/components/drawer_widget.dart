import 'package:flutter/material.dart';
import 'package:gestion_lotes_frontend/config/api_config.dart';
import 'package:gestion_lotes_frontend/screens/listado_planos_screen.dart';
import 'package:gestion_lotes_frontend/screens/listar_ventas_screen.dart';
import 'package:gestion_lotes_frontend/screens/log_actividad_screen.dart';
import 'package:gestion_lotes_frontend/services/auth_service.dart'; // AGREGADO
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../screens/home_screen.dart';
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

class _CustomDrawerState extends State<CustomDrawer> with TickerProviderStateMixin {
  String username = '';
  String email = '';
  String rol = '';
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
    _fadeController.forward();
    obtenerPerfilUsuario();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> obtenerPerfilUsuario() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.perfilUsuarioEndpoint),
        headers: ApiConfig.authHeaders(widget.token),
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

  // MÉTODO MEJORADO PARA CERRAR SESIÓN
  Future<void> _performLogout() async {
    try {
      // Primero limpiar los datos del AuthService
      await AuthService.logout();

      // Luego navegar a MainScreen y limpiar todo el stack
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      print('Error durante el logout: $e');
      // Aún así navegar para evitar que el usuario se quede bloqueado
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
        );
      }
    }
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    bool isSelected = false,
    bool isLogout = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isSelected ? Colors.blue.shade100.withOpacity(0.7) : Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: isLogout ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
          highlightColor: isLogout ? Colors.red.withOpacity(0.05) : Colors.blue.withOpacity(0.05),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isLogout
                        ? Colors.red.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? Colors.blue.shade700,
                    size: 22,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor ?? Colors.grey.shade800,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (!isLogout)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 30,
      ),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade800,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.person_rounded,
              size: 40,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 16),
          Text(
            username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              rol.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey.shade50,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildUserProfile(),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      icon: Icons.home_rounded,
                      title: 'Inicio',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(token: widget.token, rol: widget.rol),
                          ),
                        );
                      },
                    ),

                    _buildDrawerItem(
                      icon: Icons.map_rounded,
                      title: 'Planos',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListadoPlanosScreen(token: widget.token, rol: widget.rol),
                          ),
                        );
                      },
                    ),

                    if (widget.rol == 'admin' || widget.rol == 'agente')
                      _buildDrawerItem(
                        icon: Icons.monetization_on_rounded,
                        title: 'Ventas',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListarVentasScreen(token: widget.token, rol: widget.rol),
                            ),
                          );
                        },
                      ),

                    if (widget.rol == 'admin')
                      _buildDrawerItem(
                        icon: Icons.history_rounded,
                        title: 'Historial',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LogActividadScreen(token: widget.token),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.grey.shade300,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              _buildDrawerItem(
                icon: Icons.logout_rounded,
                title: 'Cerrar Sesión',
                iconColor: Colors.red.shade600,
                textColor: Colors.red.shade600,
                isLogout: true,
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.white,
                      elevation: 10,
                      title: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.logout_rounded,
                              color: Colors.red.shade600,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Cerrar Sesión',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      content: Text(
                        '¿Está seguro que desea cerrar sesión?',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      actionsPadding: EdgeInsets.all(20),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(120, 48),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context); // Cerrar el diálogo
                            await _performLogout(); // CAMBIO PRINCIPAL: usar el método mejorado
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(130, 50),
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Cerrar Sesión',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}