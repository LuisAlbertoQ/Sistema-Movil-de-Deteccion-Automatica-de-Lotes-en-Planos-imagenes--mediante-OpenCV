import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gestion_lotes_frontend/config/api_config.dart';
import 'package:gestion_lotes_frontend/screens/editar_lote_screen.dart';
import 'package:gestion_lotes_frontend/screens/registrar_venta_screen.dart';
import 'package:http/http.dart' as http;

class ImagenCompletaScreen extends StatefulWidget {
  final String imageUrl;
  final String nombrePlano;
  final Map<String, dynamic> planoData;
  final String token;
  final String rol;

  const ImagenCompletaScreen({
    Key? key,
    required this.imageUrl,
    required this.nombrePlano,
    required this.planoData,
    required this.token,
    required this.rol,
  }) : super(key: key);

  @override
  _ImagenCompletaScreenState createState() => _ImagenCompletaScreenState();
}

class _ImagenCompletaScreenState extends State<ImagenCompletaScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> lotes = [];
  bool isLoading = true;
  String? error;
  Size imageSize = Size.zero;
  GlobalKey imageKey = GlobalKey();

  // Controladores de animación para cada lote
  Map<int, AnimationController> _animationControllers = {};
  Map<int, Animation<double>> _pulseAnimations = {};

  @override
  void initState() {
    super.initState();
    _obtenerLotes();
    _precargaImagen();
  }

  @override
  void dispose() {
    // Limpiar controladores de animación
    _animationControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _initializeAnimations() {
    // Limpiar animaciones anteriores
    _animationControllers.values.forEach((controller) => controller.dispose());
    _animationControllers.clear();
    _pulseAnimations.clear();

    // Crear animaciones para cada lote disponible
    for (int i = 0; i < lotes.length; i++) {
      final lote = lotes[i];
      final bool isVendido = lote['estado']?.toLowerCase() == 'vendido';

      if (!isVendido) {
        final controller = AnimationController(
          duration: const Duration(milliseconds: 1500),
          vsync: this,
        );

        final animation = Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Curves.fastOutSlowIn,
        ));

        _animationControllers[i] = controller;
        _pulseAnimations[i] = animation;

        // Iniciar animación con un delay aleatorio para que no todos pulsen al mismo tiempo
        Future.delayed(Duration(milliseconds: i * 200), () {
          if (mounted && _animationControllers.containsKey(i)) {
            controller.repeat(reverse: true);
          }
        });
      }
    }
  }

  Future<void> _precargaImagen() async {
    final ImageProvider imageProvider = CachedNetworkImageProvider(widget.imageUrl);
    final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);

    stream.addListener(ImageStreamListener((ImageInfo imageInfo, bool _) {
      setState(() {
        imageSize = Size(
          imageInfo.image.width.toDouble(),
          imageInfo.image.height.toDouble(),
        );
      });
    }));
  }

  Future<void> _obtenerLotes() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final String url = ApiConfig.obtenerLotesEndpoint(widget.planoData['id']);

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConfig.authHeaders(widget.token),
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        setState(() {
          lotes = List<Map<String, dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
        _initializeAnimations();
      } else {
        setState(() {
          error = 'Error al obtener los lotes: ${response.statusCode}';
          isLoading = false;
        });
        _mostrarError('Error al obtener los lotes: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = 'Error de conexión: $e';
        isLoading = false;
      });
      _mostrarError('Error de conexión: $e');
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Reintentar',
          onPressed: _obtenerLotes,
          textColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPhotoViewWithOverlays() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcular el tamaño de la imagen manteniendo la relación de aspecto
        double imageAspectRatio = imageSize.width / imageSize.height;
        double containerAspectRatio = constraints.maxWidth / constraints.maxHeight;

        double imageWidth;
        double imageHeight;

        if (containerAspectRatio > imageAspectRatio) {
          // La imagen es más alta que el contenedor
          imageHeight = constraints.maxHeight;
          imageWidth = imageHeight * imageAspectRatio;
        } else {
          // La imagen es más ancha que el contenedor
          imageWidth = constraints.maxWidth;
          imageHeight = imageWidth / imageAspectRatio;
        }

        // Calcular offsets para centrar la imagen
        double offsetX = (constraints.maxWidth - imageWidth) / 2;
        double offsetY = (constraints.maxHeight - imageHeight) / 2;

        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: Colors.black,
          child: Stack(
            children: [
              Positioned(
                left: offsetX,
                top: offsetY,
                width: imageWidth,
                height: imageHeight,
                child: Image(
                  key: imageKey,
                  image: CachedNetworkImageProvider(widget.imageUrl),
                  fit: BoxFit.contain,
                ),
              ),
              if (!isLoading && error == null)
                Positioned(
                  left: offsetX,
                  top: offsetY,
                  width: imageWidth,
                  height: imageHeight,
                  child: Stack(
                    children: lotes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final lote = entry.value;
                      return _buildLoteOverlay(
                        lote,
                        index,
                        imageWidth,
                        imageHeight,
                        imageSize.width,
                        imageSize.height,
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoteOverlay(
      Map<String, dynamic> lote,
      int index,
      double containerWidth,
      double containerHeight,
      double originalWidth,
      double originalHeight,
      ) {
    try {
      final coordenadasStr = lote['coordenadas'];
      final List<String> coords = coordenadasStr.split(',');

      if (coords.length != 4) {
        print('Error: Formato de coordenadas inválido para lote ${lote['nombre']}');
        return Container();
      }

      // Convertir coordenadas originales a coordenadas escaladas
      final double scaleX = containerWidth / originalWidth;
      final double scaleY = containerHeight / originalHeight;

      final double x = double.parse(coords[0]) * scaleX;
      final double y = double.parse(coords[1]) * scaleY;
      final double width = double.parse(coords[2]) * scaleX;
      final double height = double.parse(coords[3]) * scaleY;

      // Determinar colores basados en el estado
      final bool isVendido = lote['estado']?.toLowerCase() == 'vendido';

      // Colores mejorados
      Color borderColor;
      Color fillColor;
      Color shadowColor;

      if (isVendido) {
        borderColor = Colors.red.shade600;
        fillColor = Colors.red.withOpacity(0.2);
        shadowColor = Colors.red.withOpacity(0.3);
      } else {
        borderColor = Colors.green.shade600;
        fillColor = Colors.green.withOpacity(0.15);
        shadowColor = Colors.green.withOpacity(0.4);
      }

      Widget loteWidget = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: 2.5,
          ),
          color: fillColor,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Indicador de esquina para lotes disponibles
            if (!isVendido)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  lote['nombre'] ?? '',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 2.0,
                          color: Colors.black,
                        )
                      ]
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      // Aplicar animación solo a lotes disponibles
      if (!isVendido && _pulseAnimations.containsKey(index)) {
        loteWidget = AnimatedBuilder(
          animation: _pulseAnimations[index]!,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimations[index]!.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3 * _pulseAnimations[index]!.value),
                      blurRadius: 12 * _pulseAnimations[index]!.value,
                      spreadRadius: 2 * _pulseAnimations[index]!.value,
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: loteWidget,
        );
      }

      return Positioned(
        left: x,
        top: y,
        width: width,
        height: height,
        child: GestureDetector(
          onTap: () => _mostrarDetallesLote(context, lote),
          behavior: HitTestBehavior.translucent,
          child: loteWidget,
        ),
      );
    } catch (e) {
      print('Error al procesar lote ${lote['nombre']}: $e');
      return Container();
    }
  }

  void _mostrarDetallesLote(BuildContext context, Map<String, dynamic> lote) {
    final bool isVendido = lote['estado']?.toString().toLowerCase() == 'vendido';
    final Color primaryColor = isVendido ? Colors.red.shade700 : Colors.blue.shade700;
    final Color backgroundColor = isVendido ? Colors.red.shade50 : Colors.blue.shade50;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: backgroundColor,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Detalles del Lote',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Detalles del lote
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildFormField(
                    label: 'Nombre',
                    value: lote['nombre'] ?? 'No disponible',
                    icon: Icons.tag,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 16),
                  _buildStatusField(
                    label: 'Estado',
                    value: lote['estado'] ?? 'No disponible',
                    color: primaryColor,
                    isVendido: isVendido,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    label: 'Precio',
                    value: '\$${lote['precio'] ?? 'No disponible'}',
                    icon: Icons.attach_money,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    label: 'Área',
                    value: '${lote['area_m2'] ?? 'No disponible'} m²',
                    icon: Icons.aspect_ratio,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    label: 'Forma',
                    value: lote['forma'] ?? 'No disponible',
                    icon: Icons.polyline,
                    color: primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón de Vender - Solo mostrar si NO está vendido y el rol es adecuado
                if (!isVendido && (widget.rol == 'admin' || widget.rol == 'agente'))
                  _buildActionButton(
                    context: context,
                    icon: Icons.attach_money,
                    label: 'Vender',
                    color: Colors.green,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrarVentaScreen(
                            token: widget.token,
                            rol: widget.rol,
                            idLote: lote['id'],
                            precio: lote['precio'],
                            nombreLote: lote['nombre'],
                          ),
                        ),
                      ).then((_) => _obtenerLotes());
                    },
                  ),

                // Botón de Editar - Solo mostrar si NO está vendido y es admin
                if (!isVendido && widget.rol == 'admin')
                  _buildActionButton(
                    context: context,
                    icon: Icons.edit,
                    label: 'Editar',
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditarLoteScreen(
                            loteId: lote['id'],
                            token: widget.token,
                          ),
                        ),
                      ).then((_) => _obtenerLotes());
                    },
                  ),

                // Botón de Cerrar - Siempre visible
                _buildActionButton(
                  context: context,
                  icon: Icons.close,
                  label: 'Cerrar',
                  color: Colors.grey,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool isEditable = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Icon(icon, color: color),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusField({
    required String label,
    required String value,
    required Color color,
    required bool isVendido,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isVendido ? Colors.red.shade50 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isVendido ? Colors.red.shade300 : Colors.blue.shade300,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isVendido ? Colors.red.shade700 : Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                isVendido ? Icons.check_circle : Icons.assignment_turned_in,
                color: isVendido ? Colors.red.shade700 : Colors.blue.shade700,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: FloatingActionButton(
            heroTag: UniqueKey(),
            onPressed: onPressed,
            backgroundColor: color,
            elevation: 0,
            mini: true,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nombrePlano),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _obtenerLotes,
            color: Colors.blue,
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildPhotoViewWithOverlays(),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}