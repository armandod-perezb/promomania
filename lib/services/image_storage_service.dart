import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

/// Servicio para guardar y recuperar imágenes en el almacenamiento del dispositivo
class ImageStorageService {
  static const String _imagesDir = 'promomania_images';

  /// Obtiene el directorio donde se guardan las imágenes
  Future<Directory> _getImagesDirectory() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDocDir.path}/$_imagesDir');
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    return imagesDir;
  }

  /// Guarda una imagen desde bytes y retorna la ruta
  /// 
  /// [bytes] - Los bytes de la imagen
  /// [fileName] - Nombre del archivo (opcional, se genera uno si no se proporciona)
  /// 
  /// Retorna la ruta relativa del archivo guardado
  Future<String> saveImageFromBytes(
    Uint8List bytes, {
    String? fileName,
  }) async {
    try {
      final directory = await _getImagesDirectory();
      
      // Generar nombre de archivo único si no se proporciona
      final filename = fileName ?? _generateUniqueFilename();
      final file = File('${directory.path}/$filename');
      
      // Guardar el archivo
      await file.writeAsBytes(bytes);
      
      return filename;
    } catch (e) {
      print('Error guardando imagen: $e');
      rethrow;
    }
  }

  /// Guarda una imagen desde una ruta temporal y retorna la ruta persistente
  /// 
  /// [tempPath] - Ruta temporal del archivo
  /// 
  /// Retorna la ruta relativa del archivo guardado
  Future<String> saveImageFromPath(String tempPath) async {
    try {
      final tempFile = File(tempPath);
      if (!await tempFile.exists()) {
        throw Exception('Archivo temporal no existe: $tempPath');
      }

      final bytes = await tempFile.readAsBytes();
      return saveImageFromBytes(bytes);
    } catch (e) {
      print('Error guardando imagen desde ruta: $e');
      rethrow;
    }
  }

  /// Obtiene la ruta completa de una imagen guardada
  Future<String> getFullImagePath(String fileName) async {
    final directory = await _getImagesDirectory();
    return '${directory.path}/$fileName';
  }

  /// Lee una imagen como bytes
  Future<Uint8List?> readImageBytes(String fileName) async {
    try {
      final fullPath = await getFullImagePath(fileName);
      final file = File(fullPath);
      
      if (!await file.exists()) {
        return null;
      }
      
      return await file.readAsBytes();
    } catch (e) {
      print('Error leyendo imagen: $e');
      return null;
    }
  }

  /// Elimina una imagen
  Future<bool> deleteImage(String fileName) async {
    try {
      final fullPath = await getFullImagePath(fileName);
      final file = File(fullPath);
      
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error eliminando imagen: $e');
      return false;
    }
  }

  /// Genera un nombre de archivo único basado en timestamp y hash
  String _generateUniqueFilename() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = md5.convert('$timestamp${DateTime.now().microsecond}'.codeUnits).toString();
    return 'img_${hash.substring(0, 8)}_$timestamp.jpg';
  }

  /// Verifica si una imagen existe
  Future<bool> imageExists(String fileName) async {
    try {
      final fullPath = await getFullImagePath(fileName);
      return await File(fullPath).exists();
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el tamaño de una imagen en bytes
  Future<int> getImageSize(String fileName) async {
    try {
      final fullPath = await getFullImagePath(fileName);
      final file = File(fullPath);
      
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Limpia todas las imágenes (usar con cuidado)
  Future<bool> clearAllImages() async {
    try {
      final directory = await _getImagesDirectory();
      
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        await directory.create(recursive: true);
      }
      
      return true;
    } catch (e) {
      print('Error limpiando imágenes: $e');
      return false;
    }
  }
}
