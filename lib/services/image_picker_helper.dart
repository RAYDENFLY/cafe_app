import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickAndSaveImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image == null) return null;

      // Get app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String appPath = appDir.path;
      final String imagesPath = path.join(appPath, 'images');
      
      // Create images directory if it doesn't exist
      final Directory imagesDir = Directory(imagesPath);
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate unique filename
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final String savePath = path.join(imagesPath, fileName);

      // Copy image to app directory
      final File sourceFile = File(image.path);
      await sourceFile.copy(savePath);

      return savePath;
    } catch (e) {
      debugPrint('Error picking/saving image: $e');
      return null;
    }
  }

  static Future<String?> pickAndSaveImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image == null) return null;

      // Get app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String appPath = appDir.path;
      final String imagesPath = path.join(appPath, 'images');
      
      // Create images directory if it doesn't exist
      final Directory imagesDir = Directory(imagesPath);
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate unique filename
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final String savePath = path.join(imagesPath, fileName);

      // Copy image to app directory
      final File sourceFile = File(image.path);
      await sourceFile.copy(savePath);

      return savePath;
    } catch (e) {
      debugPrint('Error picking/saving image from camera: $e');
      return null;
    }
  }

  static void showImagePickerDialog(BuildContext context, Function(String?) onImageSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Gambar'),
          content: const Text('Pilih sumber gambar:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final imagePath = await pickAndSaveImageFromCamera();
                onImageSelected(imagePath);
              },
              child: const Text('Kamera'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final imagePath = await pickAndSaveImage();
                onImageSelected(imagePath);
              },
              child: const Text('Galeri'),
            ),
          ],
        );
      },
    );
  }

  static Widget buildImageWidget(String? imagePath, {double? width, double? height}) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        width: width ?? 100,
        height: height ?? 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.image,
          size: 40,
          color: Colors.grey[400],
        ),
      );
    }

    final file = File(imagePath);
    if (!file.existsSync()) {
      return Container(
        width: width ?? 100,
        height: height ?? 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.broken_image,
          size: 40,
          color: Colors.grey[400],
        ),
      );
    }

    return Container(
      width: width ?? 100,
      height: height ?? 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          file,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
