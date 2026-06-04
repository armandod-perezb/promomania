import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para guardar y recuperar imágenes en el almacenamiento del dispositivo
class ImageStorageService {
  static const String _imagesDir = 'promomania_images';

  // Para web: almacenar imágenes en memoria usando Map
  static final Map<String, Uint8List> _webImageCache = {};

  /// Obtiene el directorio donde se guardan las imágenes (solo nativo)
  Future<Directory?> _getImagesDirectory() async {
    if (kIsWeb) {
      return null; // Web no usa directorios físicos
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDocDir.path}/$_imagesDir');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  /// Guarda una imagen desde bytes y retorna la ruta/identificador
  ///
  /// [bytes] - Los bytes de la imagen
  /// [fileName] - Nombre del archivo (opcional, se genera uno si no se proporciona)
  ///
  /// Retorna el identificador de la imagen (filename nativo o key para web)
  Future<String> saveImageFromBytes(Uint8List bytes, {String? fileName}) async {
    try {
      final filename = fileName ?? _generateUniqueFilename();

      if (kIsWeb) {
        // WEB: Guardar en memoria (Map)
        _webImageCache[filename] = bytes;

        // Opcional: persistir en localStorage usando base64
        await _saveImageToWebStorage(filename, bytes);

        print('✅ Imagen guardada en WEB: $filename');
        return filename;
      } else {
        // NATIVO: Guardar en sistema de archivos
        final directory = await _getImagesDirectory();
        if (directory == null)
          throw Exception('No se pudo obtener el directorio');

        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(bytes);

        print('✅ Imagen guardada en NATIVO: ${directory.path}/$filename');
        return filename;
      }
    } catch (e) {
      print('❌ Error guardando imagen: $e');
      rethrow;
    }
  }

  /// Guarda una imagen desde una ruta temporal
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

  /// Obtiene la ruta completa o URL de una imagen guardada
  Future<String> getFullImagePath(String fileName) async {
    if (kIsWeb) {
      // Web: retornar un identificador (no una ruta real)
      return 'web_image_$fileName';
    }

    final directory = await _getImagesDirectory();
    return '${directory?.path}/$fileName';
  }

  /// Lee una imagen como bytes
  Future<Uint8List?> readImageBytes(String fileName) async {
    try {
      final dataUrlBytes = dataUrlToBytes(fileName);
      if (dataUrlBytes != null) return dataUrlBytes;

      if (kIsWeb) {
        // WEB: Leer desde cache en memoria
        if (_webImageCache.containsKey(fileName)) {
          return _webImageCache[fileName];
        }

        // Intentar recuperar de localStorage
        return await _loadImageFromWebStorage(fileName);
      } else {
        // NATIVO: Leer desde archivo
        final directory = await _getImagesDirectory();
        if (directory == null) return null;

        final file = File('${directory.path}/$fileName');
        if (!await file.exists()) return null;

        return await file.readAsBytes();
      }
    } catch (e) {
      print('Error leyendo imagen: $e');
      return null;
    }
  }

  /// Elimina una imagen
  Future<bool> deleteImage(String fileName) async {
    try {
      if (kIsWeb) {
        // WEB: Eliminar de cache
        _webImageCache.remove(fileName);
        await _removeImageFromWebStorage(fileName);
        return true;
      } else {
        // NATIVO: Eliminar archivo
        final directory = await _getImagesDirectory();
        if (directory == null) return false;

        final file = File('${directory.path}/$fileName');
        if (await file.exists()) {
          await file.delete();
          return true;
        }
        return false;
      }
    } catch (e) {
      print('Error eliminando imagen: $e');
      return false;
    }
  }

  /// Verifica si una imagen existe
  Future<bool> imageExists(String fileName) async {
    try {
      if (kIsWeb) {
        return _webImageCache.containsKey(fileName) ||
            await _webStorageContains(fileName);
      }

      final directory = await _getImagesDirectory();
      if (directory == null) return false;

      final file = File('${directory.path}/$fileName');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el tamaño de una imagen en bytes
  Future<int> getImageSize(String fileName) async {
    try {
      if (kIsWeb) {
        final bytes = await readImageBytes(fileName);
        return bytes?.length ?? 0;
      }

      final directory = await _getImagesDirectory();
      if (directory == null) return 0;

      final file = File('${directory.path}/$fileName');
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Limpia todas las imágenes
  Future<bool> clearAllImages() async {
    try {
      if (kIsWeb) {
        _webImageCache.clear();
        await _clearWebStorage();
        return true;
      }

      final directory = await _getImagesDirectory();
      if (directory != null && await directory.exists()) {
        await directory.delete(recursive: true);
        await directory.create(recursive: true);
      }
      return true;
    } catch (e) {
      print('Error limpiando imágenes: $e');
      return false;
    }
  }

  // ==================== MÉTODOS DE SOPORTE PARA WEB ====================

  /// Guardar imagen en localStorage (web persistente)
  Future<void> _saveImageToWebStorage(String key, Uint8List bytes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64String = Uri.encodeComponent(String.fromCharCodes(bytes));
      await prefs.setString('img_$key', base64String);
    } catch (e) {
      print('Error guardando en localStorage: $e');
    }
  }

  /// Cargar imagen desde localStorage
  Future<Uint8List?> _loadImageFromWebStorage(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final base64String = prefs.getString('img_$key');
      if (base64String != null) {
        final bytes = Uri.decodeComponent(base64String).codeUnits;
        final uint8list = Uint8List.fromList(bytes);
        _webImageCache[key] = uint8list; // Cachear para futuros accesos
        return uint8list;
      }
      return null;
    } catch (e) {
      print('Error cargando desde localStorage: $e');
      return null;
    }
  }

  /// Verificar si existe en localStorage
  Future<bool> _webStorageContains(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('img_$key');
    } catch (e) {
      return false;
    }
  }

  /// Eliminar de localStorage
  Future<void> _removeImageFromWebStorage(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('img_$key');
    } catch (e) {
      print('Error eliminando de localStorage: $e');
    }
  }

  /// Limpiar localStorage
  Future<void> _clearWebStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('img_'));
      for (var key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('Error limpiando localStorage: $e');
    }
  }

  /// Genera un nombre de archivo único
  String _generateUniqueFilename() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = md5
        .convert('$timestamp${DateTime.now().microsecond}'.codeUnits)
        .toString();
    return 'img_${hash.substring(0, 8)}_$timestamp.jpg';
  }

  static bool isDataImageUrl(String? value) {
    if (value == null) return false;
    return value.trim().toLowerCase().startsWith('data:image/');
  }

  static String imageBytesToDataUrl(Uint8List bytes) {
    final mimeType = _detectMimeType(bytes);
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }

  static Uint8List? dataUrlToBytes(String? value) {
    if (!isDataImageUrl(value)) return null;

    final dataUrl = value!.trim();
    final commaIndex = dataUrl.indexOf(',');
    if (commaIndex == -1) return null;

    final metadata = dataUrl.substring(0, commaIndex).toLowerCase();
    final payload = dataUrl.substring(commaIndex + 1);

    try {
      if (metadata.contains(';base64')) {
        return base64Decode(payload);
      }
      return Uint8List.fromList(utf8.encode(Uri.decodeComponent(payload)));
    } catch (_) {
      return null;
    }
  }

  static String _detectMimeType(Uint8List bytes) {
    if (bytes.length >= 4) {
      if (bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        return 'image/png';
      }
      if (bytes[0] == 0x47 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x38) {
        return 'image/gif';
      }
      if (bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46) {
        return 'image/webp';
      }
    }
    return 'image/jpeg';
  }
}
