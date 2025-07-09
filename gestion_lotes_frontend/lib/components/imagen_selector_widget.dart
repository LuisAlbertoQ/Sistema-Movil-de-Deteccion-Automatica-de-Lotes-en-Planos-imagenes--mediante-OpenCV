import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagenSelectorWidget extends StatefulWidget {
  final Function(File?) onImageSelected;

  const ImagenSelectorWidget({Key? key, required this.onImageSelected}) : super(key: key);

  @override
  _ImagenSelectorWidgetState createState() => _ImagenSelectorWidgetState();
}

class _ImagenSelectorWidgetState extends State<ImagenSelectorWidget> {
  File? _imagen;
  final ImagePicker _picker = ImagePicker();

  Future<void> _mostrarOpcionesSeleccion() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Seleccionar imagen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _OpcionSeleccion(
                    icono: Icons.camera_alt,
                    titulo: 'Cámara',
                    onTap: () {
                      Navigator.pop(context);
                      _tomarFoto();
                    },
                  ),
                  _OpcionSeleccion(
                    icono: Icons.photo_library,
                    titulo: 'Galería',
                    onTap: () {
                      Navigator.pop(context);
                      _seleccionarDeGaleria();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Future<void> _tomarFoto() async {
    // Verificar permisos de cámara
    final cameraStatus = await Permission.camera.request();

    if (cameraStatus.isGranted) {
      try {
        final pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          preferredCameraDevice: CameraDevice.rear,
        );

        if (pickedFile != null) {
          setState(() {
            _imagen = File(pickedFile.path);
          });
          widget.onImageSelected(_imagen);
        }
      } catch (e) {
        _mostrarError('Error al acceder a la cámara: $e');
      }
    } else if (cameraStatus.isDenied) {
      _mostrarDialogoPermisos('Cámara');
    } else if (cameraStatus.isPermanentlyDenied) {
      _mostrarDialogoConfiguracion('cámara');
    }
  }

  Future<void> _seleccionarDeGaleria() async {
    // Verificar permisos de almacenamiento
    final storageStatus = await Permission.photos.request();

    if (storageStatus.isGranted || storageStatus.isLimited) {
      try {
        final pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          setState(() {
            _imagen = File(pickedFile.path);
          });
          widget.onImageSelected(_imagen);
        }
      } catch (e) {
        _mostrarError('Error al acceder a la galería: $e');
      }
    } else if (storageStatus.isDenied) {
      _mostrarDialogoPermisos('Galería');
    } else if (storageStatus.isPermanentlyDenied) {
      _mostrarDialogoConfiguracion('galería');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _mostrarDialogoPermisos(String tipo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permiso de $tipo requerido'),
          content: Text('Esta aplicación necesita acceso a la $tipo para seleccionar imágenes.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (tipo == 'Cámara') {
                  _tomarFoto();
                } else {
                  _seleccionarDeGaleria();
                }
              },
              child: const Text('Reintentar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoConfiguracion(String tipo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permiso de $tipo denegado'),
          content: Text('Por favor, habilita el acceso a la $tipo en la configuración de la aplicación.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Configuración'),
            ),
          ],
        );
      },
    );
  }

  void _eliminarImagen() {
    setState(() {
      _imagen = null;
    });
    widget.onImageSelected(null);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _mostrarOpcionesSeleccion,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.blue.shade100,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: _imagen == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: Colors.blue.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Toca para seleccionar una imagen',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text(
                  'Cámara',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.photo_library, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text(
                  'Galería',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.file(
                _imagen!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: _eliminarImagen,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: _mostrarOpcionesSeleccion,
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpcionSeleccion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final VoidCallback onTap;

  const _OpcionSeleccion({
    required this.icono,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 40,
              color: Colors.blue.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}