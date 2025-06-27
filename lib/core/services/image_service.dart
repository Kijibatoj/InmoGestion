import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  static const Uuid _uuid = Uuid();

  /// Muestra un diálogo para seleccionar el origen de la imagen
  static Future<String?> showImageSourceDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.add_a_photo, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text('Agregar imagen'),
            ],
          ),
          content: const Text('¿De dónde quieres obtener la imagen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                final imagePath = await _pickImageFromGallery();
                if (context.mounted) {
                  Navigator.pop(context, imagePath);
                }
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Galería'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                final imagePath = await _pickImageFromCamera();
                if (context.mounted) {
                  Navigator.pop(context, imagePath);
                }
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Cámara'),
            ),
          ],
        );
      },
    );
  }

  /// Muestra un bottom sheet mejorado para seleccionar el origen de la imagen
  static Future<String?> showImageSourceBottomSheet(
    BuildContext context,
  ) async {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.add_a_photo,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Agregar imagen',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _ImageSourceButton(
                      icon: Icons.camera_alt,
                      label: 'Cámara',
                      onTap: () async {
                        final imagePath = await _pickImageFromCamera();
                        if (context.mounted) {
                          Navigator.pop(context, imagePath);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ImageSourceButton(
                      icon: Icons.photo_library,
                      label: 'Galería',
                      onTap: () async {
                        final imagePath = await _pickImageFromGallery();
                        if (context.mounted) {
                          Navigator.pop(context, imagePath);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  /// Selecciona imagen de la galería
  static Future<String?> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return await _saveImageToLocal(image.path);
      }
    } catch (e) {
      debugPrint('Error al seleccionar imagen de galería: $e');
    }
    return null;
  }

  /// Toma foto con la cámara
  static Future<String?> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return await _saveImageToLocal(image.path);
      }
    } catch (e) {
      debugPrint('Error al tomar foto: $e');
    }
    return null;
  }

  /// Guarda la imagen en almacenamiento local de la app
  static Future<String?> _saveImageToLocal(String imagePath) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = path.join(appDir.path, 'images');

      // Crear directorio si no existe
      await Directory(imagesDir).create(recursive: true);

      // Generar nombre único para la imagen
      final String fileName = '${_uuid.v4()}.jpg';
      final String newPath = path.join(imagesDir, fileName);

      // Copiar imagen al directorio de la app
      final File sourceFile = File(imagePath);
      await sourceFile.copy(newPath);

      return newPath;
    } catch (e) {
      debugPrint('Error al guardar imagen localmente: $e');
    }
    return null;
  }

  /// Elimina una imagen del almacenamiento local
  static Future<bool> deleteImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
        return true;
      }
    } catch (e) {
      debugPrint('Error al eliminar imagen: $e');
    }
    return false;
  }

  /// Verifica si un archivo de imagen existe
  static Future<bool> imageExists(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      return await imageFile.exists();
    } catch (e) {
      return false;
    }
  }
}

class _ImageSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
