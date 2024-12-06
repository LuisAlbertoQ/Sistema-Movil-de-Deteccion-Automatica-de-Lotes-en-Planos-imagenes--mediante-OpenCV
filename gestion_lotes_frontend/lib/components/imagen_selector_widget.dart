import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagenSelectorWidget extends StatefulWidget {
  final Function(File?) onImageSelected;

  const ImagenSelectorWidget({Key? key, required this.onImageSelected}) : super(key: key);

  @override
  _ImagenSelectorWidgetState createState() => _ImagenSelectorWidgetState();
}

class _ImagenSelectorWidgetState extends State<ImagenSelectorWidget> {
  File? _imagen;
  final ImagePicker _picker = ImagePicker();

  Future<void> _seleccionarImagen() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _seleccionarImagen,
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
              Icons.cloud_upload_outlined,
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
            Text(
              'Formato: JPG, PNG',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
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
                bottom: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    onPressed: _seleccionarImagen,
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
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