import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gestion_lotes_frontend/components/decorative_background.dart';
import '../components/drawer_widget.dart';
import '../main.dart';

class HomeScreen extends StatelessWidget {
  final String token;
  final String rol;

  const HomeScreen({
    Key? key,
    required this.token, required this.rol,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inicio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.blue.shade600),
      ),
      drawer: CustomDrawer(
        token: token,
        rol: rol,
        onLogout: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
                (route) => false,
          );
        },
      ),
      body: Stack(
        children: [
          // Fondo con patrón de gradiente
          DecorativeBackground(),
          // Contenido principal
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo animado
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Align( // <-- Añade este widget Align
                                  alignment: Alignment.centerRight, // <-- Alinea la imagen al centro-derecha
                                  child: Image.asset(
                                    'assets/imagen/3322.jpg',
                                    width: 140,
                                    height: 140,
                                    fit: BoxFit.contain,
                                    // En caso de error al cargar la imagen, mostrar un ícono por defecto
                                    errorBuilder: (context, error, stackTrace){
                                      return Icon(
                                        Icons.business,
                                        size: 70,
                                        color: Colors.blue.shade700,
                                      );
                                    },
                                  ),
                                ), // <-- Cierra el widget Align
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // Título con animación
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: const Text(
                            'Bienvenido a L2 Sistema de Venta de Lotes',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Subtítulo con animación
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Text(
                            'Aquí podrás Escoger el Lote de tu Preferencia',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // Contenedor de información adicional
                    Container(
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
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 40,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Explore nuestra selección de lotes disponibles y encuentre la ubicación perfecta para su próximo hogar.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}