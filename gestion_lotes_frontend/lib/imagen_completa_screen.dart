import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'editar_lote_screen.dart';
import 'ventas/registrar_venta_screen.dart';
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

class _ImagenCompletaScreenState extends State<ImagenCompletaScreen> {
  List<Map<String, dynamic>> lotes = [];
  bool isLoading = true;
  String? error;
  Size imageSize = Size.zero;
  GlobalKey imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _obtenerLotes();
    _precargaImagen();
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
      final String url = 'http://10.0.2.2:8000/obtener-lotes/${widget.planoData['id']}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          lotes = List<Map<String, dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
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
                    children: lotes.map((lote) => _buildLoteOverlay(
                      lote,
                      imageWidth,
                      imageHeight,
                      imageSize.width,
                      imageSize.height,
                    )).toList(),
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

      //Determinar colores basados en el estado
      final bool isVendido = lote['estado']?.toLowerCase() == 'vendido';
      final Color borderColor = isVendido ? Colors.red : Colors.green;
      final Color fillColor = isVendido
          ? Colors.red.withOpacity(0.3)
          : Colors.green.withOpacity(0.3);

      return Positioned(
        left: x,
        top: y,
        width: width,
        height: height,
        child: GestureDetector(
          onTap: () => _mostrarDetallesLote(context, lote),
          behavior: HitTestBehavior.translucent,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue.withOpacity(0.7),
                width: 2,
              ),
              color: fillColor,
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      lote['nombre'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Colors.black,
                          )
                        ]
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print('Error al procesar lote ${lote['nombre']}: $e');
      return Container();
    }
  }

  void _mostrarDetallesLote(BuildContext context, Map<String, dynamic> lote) {
    showModalBottomSheet(
      backgroundColor: Colors.lightBlue.shade100,
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    'Detalles del Lote',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 16,),
                _buildDetalleItem('ID', lote['id']?.toString() ?? 'No disponible'),
                _buildDetalleItem('Nombre', lote['nombre'] ?? 'No disponible'),
                _buildDetalleItem('Estado', lote['estado'] ?? 'No disponible'),
                _buildDetalleItem('Precio', '\$${lote['precio'] ?? 'No disponible'}'),
                _buildDetalleItem('Área', '${lote['area_m2'] ?? 'No disponible'} m²'),
                _buildDetalleItem('Forma', lote['forma'] ?? 'No disponible'),
              ],

            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.rol == 'admin' || widget.rol == 'agente')
                  FloatingActionButton(
                    heroTag: 'registrarVenta',
                    onPressed: () {
                      Navigator.pop(context); // Cerrar el modal
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
                      ).then((_) {
                        _obtenerLotes();
                      });
                    },
                    backgroundColor: Colors.green.shade50,
                    child: Icon(
                        Icons.attach_money,
                        color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 16), // Espacio entre botones
                  if (widget.rol == 'admin')
                  FloatingActionButton(
                    heroTag: 'editarLote',
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
                      ).then((_) {
                        _obtenerLotes();
                      });
                    },
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(
                        Icons.edit,
                        color: Colors.blue.shade800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalleItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
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