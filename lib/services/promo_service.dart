import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';
import '../models/supermercado.dart';
import '../models/categoria.dart';
import '../models/tipo_promocion.dart';
import '../models/promocion.dart';
import '../models/promocion_horario.dart';
import '../models/comentario.dart';
import '../models/valoracion.dart';
import '../models/favorito.dart';
import '../models/reporte.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'image_storage_service.dart';

class PromoService extends ChangeNotifier {
  // "Base de datos" en memoria
  List<Usuario> usuarios = [];
  List<Supermercado> supermercados = [];
  List<Categoria> categorias = [];
  List<TipoPromocion> tiposPromocion = [];
  List<Promocion> promociones = [];
  List<PromocionHorario> promocionesHorarios = [];
  List<Comentario> comentarios = [];
  List<Valoracion> valoraciones = [];
  List<Favorito> favoritos = [];
  List<Reporte> reportes = [];

  bool loaded = false;
  String? loadError;

  // Cache de imágenes en memoria para web
  final Map<String, Uint8List> _imageCache = {};

  // Instancia del servicio de almacenamiento de imágenes
  final ImageStorageService _imageStorage = ImageStorageService();

  // Getters para acceso a imágenes
  Uint8List? getImageBytes(String codigo) => _imageCache[codigo];

  void setImageBytes(String codigo, Uint8List bytes) {
    _imageCache[codigo] = bytes;
    notifyListeners();
  }

  void clearImageCache() {
    _imageCache.clear();
    notifyListeners();
  }

  /// Inicializa los datos desde el JSON
  Future<void> init() async {
    if (loaded) return;

    try {
      loadError = null;
      final response = await rootBundle.loadString(
        'assets/data/promomania_data.json',
      );
      final data = json.decode(response);

      // Cargar usuarios
      usuarios = (data['usuarios'] as List)
          .map((u) => Usuario.fromJson(u as Map<String, dynamic>))
          .toList();

      // Cargar supermercados
      supermercados = (data['supermercados'] as List)
          .map((s) => Supermercado.fromJson(s as Map<String, dynamic>))
          .toList();

      // Cargar categorías
      categorias = (data['categorias'] as List)
          .map((c) => Categoria.fromJson(c as Map<String, dynamic>))
          .toList();

      // Cargar tipos de promoción
      tiposPromocion = (data['tipos_promocion'] as List)
          .map((t) => TipoPromocion.fromJson(t as Map<String, dynamic>))
          .toList();

      // Cargar promociones
      promociones = (data['promociones'] as List)
          .map((p) => Promocion.fromJson(p as Map<String, dynamic>))
          .toList();

      // Cargar horarios de promociones
      promocionesHorarios = (data['promociones_horarios'] as List)
          .map((h) => PromocionHorario.fromJson(h as Map<String, dynamic>))
          .toList();

      // Cargar comentarios
      comentarios = (data['comentarios'] as List)
          .map((c) => Comentario.fromJson(c as Map<String, dynamic>))
          .toList();

      // Cargar valoraciones
      valoraciones = (data['valoraciones'] as List)
          .map((v) => Valoracion.fromJson(v as Map<String, dynamic>))
          .toList();

      // Cargar favoritos
      favoritos = (data['favoritos'] as List)
          .map((f) => Favorito.fromJson(f as Map<String, dynamic>))
          .toList();

      // Cargar reportes
      reportes = (data['reportes'] as List)
          .map((r) => Reporte.fromJson(r as Map<String, dynamic>))
          .toList();

      loaded = true;
      notifyListeners();
    } catch (e) {
      print('Error cargando datos: $e');
      loadError = e.toString();
      loaded = false;
      notifyListeners();
    }
  }

  /// Obtiene la ruta del archivo de datos persistentes
  Future<File> _getDataFile() async {
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();

      return File('${directory.path}/promomania_data.json');
    } else {
      // Para web, usar un archivo virtual en memoria (no persistente)
      return File('promomania_data.json');
    }
  }

  /// Carga promociones guardadas localmente (persistencia)
  Future<void> loadLocalPromociones() async {
    try {
      if (!kIsWeb) {
        // NATIVO: Usar archivo
        final file = await _getDataFile();

        if (!await file.exists()) {
          print('No hay datos persistentes locales');
          return;
        }

        final content = await file.readAsString();
        final data = json.decode(content) as Map<String, dynamic>;

        // Cargar promociones locales
        if (data['promociones'] != null) {
          promociones = (data['promociones'] as List)
              .map((p) => Promocion.fromJson(p as Map<String, dynamic>))
              .toList();
        }

        // Cargar horarios locales
        if (data['promociones_horarios'] != null) {
          promocionesHorarios = (data['promociones_horarios'] as List)
              .map((h) => PromocionHorario.fromJson(h as Map<String, dynamic>))
              .toList();
        }
      } else {
        // WEB: Usar SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final dataString = prefs.getString('promomania_data');
        
        if (dataString != null) {
          final data = json.decode(dataString) as Map<String, dynamic>;

          // Cargar promociones locales
          if (data['promociones'] != null) {
            promociones = (data['promociones'] as List)
                .map((p) => Promocion.fromJson(p as Map<String, dynamic>))
                .toList();
          }

          // Cargar horarios locales
          if (data['promociones_horarios'] != null) {
            promocionesHorarios = (data['promociones_horarios'] as List)
                .map((h) => PromocionHorario.fromJson(h as Map<String, dynamic>))
                .toList();
          }
        } else {
          print('No hay datos persistentes en web');
          return;
        }
      }

      print('Datos persistentes cargados correctamente');
    } catch (e) {
      print('Error cargando datos persistentes: $e');
    }
  }

  /// Guarda los datos en almacenamiento persistente
  Future<void> _saveLocalData() async {
    try {
      final data = {
        'promociones': promociones.map((p) => p.toJson()).toList(),
        'promociones_horarios': promocionesHorarios
            .map((h) => h.toJson())
            .toList(),
      };

      if (!kIsWeb) {
        // NATIVO: Usar archivo
        final file = await _getDataFile();
        await file.writeAsString(json.encode(data), flush: true);
      } else {
        // WEB: Usar SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('promomania_data', json.encode(data));
      }
      
      print('Datos guardados correctamente');
    } catch (e) {
      print('Error guardando datos: $e');
    }
  }

  // ========== USUARIOS ==========
  Usuario? getUsuario(int id) {
    try {
      return usuarios.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  Usuario? getUsuarioByEmail(String email) {
    try {
      return usuarios.firstWhere((u) => u.correo == email);
    } catch (e) {
      return null;
    }
  }

  List<Usuario> getUsuarios() => usuarios;

  void addUsuario(Usuario usuario) {
    usuarios.add(usuario);
    notifyListeners();
  }

  void updateUsuario(Usuario usuario) {
    final index = usuarios.indexWhere((u) => u.id == usuario.id);
    if (index != -1) {
      usuarios[index] = usuario;
      notifyListeners();
    }
  }

  void deleteUsuario(int id) {
    usuarios.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  // ========== PROMOCIONES ==========
  List<Promocion> getPromociones() => promociones;

  List<Promocion> getPromocionesAprobadas() =>
      promociones.where((p) => p.estado == 'aprobada').toList();

  List<Promocion> getPromocionesById(int idUsuario) =>
      promociones.where((p) => p.idUsuario == idUsuario).toList();

  Promocion? getPromocionByCodigo(String codigo) {
    try {
      return promociones.firstWhere((p) => p.codigo == codigo);
    } catch (e) {
      return null;
    }
  }

  List<Promocion> getPromocionesByCategoria(int idCategoria) =>
      promociones.where((p) => p.idCategoria == idCategoria).toList();

  List<Promocion> getPromocionesBySupermercado(int idSupermercado) =>
      promociones.where((p) => p.idSupermercado == idSupermercado).toList();

  void addPromocion(Promocion promocion) {
    promociones.add(promocion);
    notifyListeners();
    _saveLocalData(); // Guardar cambios
  }

  void updatePromocion(Promocion promocion) {
    final index = promociones.indexWhere((p) => p.codigo == promocion.codigo);
    if (index != -1) {
      promociones[index] = promocion;
      notifyListeners();
      _saveLocalData(); // Guardar cambios
    }
  }

  void deletePromocion(String codigo) {
    promociones.removeWhere((p) => p.codigo == codigo);
    notifyListeners();
    _saveLocalData(); // Guardar cambios
  }

  // ========== HORARIOS DE PROMOCION ==========
  List<PromocionHorario> getPromocionesHorarios() => promocionesHorarios;

  List<PromocionHorario> getPromocionesHorariosByCodigo(
    String codigoPromocion,
  ) => promocionesHorarios
      .where((h) => h.codigoPromocion == codigoPromocion)
      .toList();

  void addPromocionHorario(PromocionHorario promocionHorario) {
    promocionesHorarios.add(promocionHorario);
    notifyListeners();
    _saveLocalData(); // Guardar cambios
  }

  void updatePromocionHorario(PromocionHorario promocionHorario) {
    final index = promocionesHorarios.indexWhere(
      (h) => h.id == promocionHorario.id,
    );
    if (index != -1) {
      promocionesHorarios[index] = promocionHorario;
      notifyListeners();
      _saveLocalData(); // Guardar cambios
    }
  }

  void deletePromocionHorario(int id) {
    promocionesHorarios.removeWhere((h) => h.id == id);
    notifyListeners();
    _saveLocalData(); // Guardar cambios
  }

  void incrementarVistas(String codigo) {
    final index = promociones.indexWhere((p) => p.codigo == codigo);
    if (index != -1) {
      final promo = promociones[index];
      promociones[index] = promo.copyWith(vistas: promo.vistas + 1);
      notifyListeners();
      _saveLocalData(); // Guardar cambios
    }
  }

  // ========== SUPERMERCADOS ==========
  List<Supermercado> getSupermercados() => supermercados;

  Supermercado? getSupermercado(int id) {
    try {
      return supermercados.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateSupermercado(Supermercado updated) {
    final index = supermercados.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      supermercados[index] = updated;
      notifyListeners();
    }
  }

  void addSupermercado(Supermercado supermercado) {
    supermercados.add(supermercado);
    notifyListeners();
  }

  void deleteSupermercado(int id) {
    supermercados.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // ========== CATEGORIAS ==========
  List<Categoria> getCategorias() => categorias;

  Categoria? getCategoria(int id) {
    try {
      return categorias.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // ========== TIPOS PROMOCION ==========
  List<TipoPromocion> getTiposPromocion() => tiposPromocion;

  TipoPromocion? getTipoPromocion(int id) {
    try {
      return tiposPromocion.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // ========== COMENTARIOS ==========
  List<Comentario> getComentarios() => comentarios;

  List<Comentario> getComentariosByPromocion(String codigoPromocion) =>
      comentarios.where((c) => c.codigoPromocion == codigoPromocion).toList();

  void addComentario(Comentario comentario) {
    comentarios.add(comentario);
    notifyListeners();
  }

  void deleteComentario(int id) {
    comentarios.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // ========== VALORACIONES ==========
  List<Valoracion> getValoraciones() => valoraciones;

  List<Valoracion> getValoracionesByPromocion(String codigoPromocion) =>
      valoraciones.where((v) => v.codigoPromocion == codigoPromocion).toList();

  int contarValoracionesPositivas(String codigoPromocion) =>
      getValoracionesByPromocion(
        codigoPromocion,
      ).where((v) => v.tipo == 'positiva').length;

  int contarValoracionesNegativas(String codigoPromocion) =>
      getValoracionesByPromocion(
        codigoPromocion,
      ).where((v) => v.tipo == 'negativa').length;

  void addValoracion(Valoracion valoracion) {
    valoraciones.add(valoracion);
    notifyListeners();
  }

  void deleteValoracion(int id) {
    valoraciones.removeWhere((v) => v.id == id);
    notifyListeners();
  }

  // ========== FAVORITOS ==========
  List<Favorito> getFavoritos() => favoritos;

  List<Favorito> getFavoritosByUsuario(int idUsuario) =>
      favoritos.where((f) => f.idUsuario == idUsuario).toList();

  bool isFavorito(int idUsuario, String codigoPromocion) => favoritos.any(
    (f) => f.idUsuario == idUsuario && f.codigoPromocion == codigoPromocion,
  );

  void addFavorito(Favorito favorito) {
    if (!isFavorito(favorito.idUsuario, favorito.codigoPromocion)) {
      favoritos.add(favorito);
      notifyListeners();
    }
  }

  void removeFavorito(int idUsuario, String codigoPromocion) {
    favoritos.removeWhere(
      (f) => f.idUsuario == idUsuario && f.codigoPromocion == codigoPromocion,
    );
    notifyListeners();
  }

  void toggleFavorito(int idUsuario, String codigoPromocion) {
    if (isFavorito(idUsuario, codigoPromocion)) {
      removeFavorito(idUsuario, codigoPromocion);
    } else {
      addFavorito(
        Favorito(
          id: (favoritos.isNotEmpty ? favoritos.last.id : 0) + 1,
          idUsuario: idUsuario,
          codigoPromocion: codigoPromocion,
          fecha: DateTime.now().toIso8601String(),
        ),
      );
    }
  }

  // ========== REPORTES ==========
  List<Reporte> getReportes() => reportes;

  List<Reporte> getReportesByUsuario(int idUsuario) =>
      reportes.where((r) => r.idUsuario == idUsuario).toList();

  List<Reporte> getReportesByPromocion(String codigoPromocion) =>
      reportes.where((r) => r.codigoPromocion == codigoPromocion).toList();

  void addReporte(Reporte reporte) {
    reportes.add(reporte);
    notifyListeners();
  }

  void updateReporte(Reporte reporte) {
    final index = reportes.indexWhere((r) => r.id == reporte.id);
    if (index != -1) {
      reportes[index] = reporte;
      notifyListeners();
    }
  }

  void deleteReporte(int id) {
    reportes.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // ========== HELPER METHODS FOR UI ==========

  /// Obtiene flash deals - top N promociones por descuento (o vistas si descuento es null)
  List<Promocion> getFlashDeals({int limit = 5}) {
    final aprobadas = getPromocionesAprobadas();
    aprobadas.sort((a, b) {
      // Primero ordenar por descuento (mayor a menor)
      if (a.descuento != null && b.descuento != null) {
        return b.descuento!.compareTo(a.descuento!);
      }
      // Si una tiene descuento y la otra no, la que tiene descuento va primero
      if (a.descuento != null) return -1;
      if (b.descuento != null) return 1;
      // Si ninguna tiene descuento, ordenar por vistas
      return b.vistas.compareTo(a.vistas);
    });
    return aprobadas.take(limit).toList();
  }

  /// Obtiene nearby stores - simula distancia/tiempo por id hasta tener GPS
  List<Map<String, dynamic>> getNearbyStores({int limit = 5}) {
    final supermercadosConPromos = <int, List<Promocion>>{};

    // Agrupar promociones por supermercado
    for (final promo in getPromocionesAprobadas()) {
      if (!supermercadosConPromos.containsKey(promo.idSupermercado)) {
        supermercadosConPromos[promo.idSupermercado] = [];
      }
      supermercadosConPromos[promo.idSupermercado]!.add(promo);
    }

    final nearbyStores = <Map<String, dynamic>>[];

    for (final entry in supermercadosConPromos.entries) {
      final supermercado = getSupermercado(entry.key);
      if (supermercado != null) {
        // Simular distancia/tiempo por id (más pequeño = más cercano)
        final simulatedDistance = (entry.key * 0.5 + 1.0).toStringAsFixed(1);
        final simulatedTime = '${entry.key * 2 + 5} min';

        nearbyStores.add({
          'supermercado': supermercado,
          'promociones': entry.value,
          'distancia': '$simulatedDistance km',
          'tiempo': simulatedTime,
        });
      }
    }

    // Ordenar por distancia (simulada por id)
    nearbyStores.sort(
      (a, b) => a['supermercado'].id.compareTo(b['supermercado'].id),
    );

    return nearbyStores.take(limit).toList();
  }

  /// Calcula urgencia de una promoción
  String getPromocionUrgency(Promocion promo) {
    if (promo.tipoVigencia == 'permanente' || promo.fechaFin == null) {
      return 'noRush';
    }

    try {
      final fechaFin = DateTime.parse(promo.fechaFin!);
      final ahora = DateTime.now();
      final diferencia = fechaFin.difference(ahora);

      if (diferencia.isNegative) {
        return 'expired';
      } else if (diferencia.inDays <= 1) {
        return 'today';
      } else if (diferencia.inDays <= 7) {
        return 'thisWeek';
      } else {
        return 'noRush';
      }
    } catch (e) {
      return 'noRush';
    }
  }

  /// Obtiene promociones por urgencia para un usuario
  Map<String, List<Promocion>> getPromocionesByUrgency(int idUsuario) {
    final favoritos = getFavoritosByUsuario(idUsuario);
    final promocionesFavoritas = favoritos
        .map((f) => getPromocionByCodigo(f.codigoPromocion))
        .where((p) => p != null)
        .cast<Promocion>()
        .toList();

    final result = <String, List<Promocion>>{
      'today': [],
      'thisWeek': [],
      'noRush': [],
    };

    for (final promo in promocionesFavoritas) {
      final urgency = getPromocionUrgency(promo);
      if (urgency != 'expired') {
        result[urgency]!.add(promo);
      }
    }

    return result;
  }

  /// Obtiene emoji y color por categoría
  Map<String, String> getCategoriaStyle(int idCategoria) {
    final categoria = getCategoria(idCategoria);
    if (categoria == null) {
      return {'emoji': '📦', 'color': '#808080'};
    }

    final styles = <String, Map<String, String>>{
      'Electrónica': {'emoji': '📱', 'color': '#2196F3'},
      'Alimentos': {'emoji': '🍎', 'color': '#4CAF50'},
      'Ropa': {'emoji': '👕', 'color': '#FF9800'},
    };

    return styles[categoria.nombre] ?? {'emoji': '📦', 'color': '#808080'};
  }

  /// Calcula precio con descuento
  double getPrecioConDescuento(Promocion promo) {
    if (promo.descuento == null || promo.descuento == 0) {
      return promo.precio;
    }
    return promo.precio * (1 - promo.descuento! / 100);
  }

  /// Obtiene rating promedio de una promoción
  double getPromocionRating(String codigoPromocion) {
    final valoraciones = getValoracionesByPromocion(codigoPromocion);
    if (valoraciones.isEmpty) return 0.0;

    final positivas = valoraciones.where((v) => v.tipo == 'positiva').length;
    return (positivas / valoraciones.length) * 5.0; // Escala de 0 a 5
  }

  /// Obtiene número de reseñas de una promoción
  int getPromocionReviewsCount(String codigoPromocion) {
    return getComentariosByPromocion(codigoPromocion).length;
  }

  // ========== MÉTODOS DE GESTIÓN DE IMÁGENES ==========

  /// Guarda una imagen para una promoción
  Future<String?> savePromotionImage(String codigoPromocion, Uint8List bytes) async {
    try {
      if (!_isValidImageBytes(bytes)) {
        print('❌ Bytes de imagen inválidos');
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'promo_${codigoPromocion}_$timestamp.jpg';

      final savedFileName = await _imageStorage.saveImageFromBytes(bytes, fileName: fileName);

      final promocionIndex = promociones.indexWhere((p) => p.codigo == codigoPromocion);
      if (promocionIndex != -1) {
        final updatedPromocion = promociones[promocionIndex].copyWith(
          foto: savedFileName,
          fotoEsLocal: true,
        );
        promociones[promocionIndex] = updatedPromocion;
        notifyListeners();
        await _saveLocalData();
      }

      _imageCache[codigoPromocion] = bytes;

      print('✅ Imagen guardada para promoción $codigoPromocion: $savedFileName');
      return savedFileName;
    } catch (e) {
      print('❌ Error guardando imagen para promoción $codigoPromocion: $e');
      return null;
    }
  }

  /// Obtiene los bytes de una imagen de promoción
  Future<Uint8List?> getPromotionImageBytes(String codigoPromocion) async {
    try {
      print('🔍 getPromotionImageBytes: Buscando promoción con código $codigoPromocion');
      final promocion = getPromocionByCodigo(codigoPromocion);
      
      if (promocion == null) {
        print('❌ getPromotionImageBytes: Promoción no encontrada');
        return null;
      }
      
      if (promocion.foto == null) {
        print('❌ getPromotionImageBytes: Promoción sin foto');
        return null;
      }

      print('🔍 getPromotionImageBytes: Foto=${promocion.foto}, EsLocal=${promocion.fotoEsLocal}');
      
      if (promocion.fotoEsLocal || !_isUrl(promocion.foto!)) {
        print('🔍 getPromotionImageBytes: Leyendo imagen local');
        final bytes = await _imageStorage.readImageBytes(promocion.foto!);
        print('🔍 getPromotionImageBytes: Bytes leídos=${bytes != null ? bytes.length : 'null'}');
        return bytes;
      } else {
        print('🔍 getPromotionImageBytes: Descargando imagen remota');
        final bytes = await _downloadAndCacheImage(codigoPromocion, promocion.foto!);
        print('🔍 getPromotionImageBytes: Bytes descargados=${bytes != null ? bytes.length : 'null'}');
        return bytes;
      }
    } catch (e) {
      print('❌ Error obteniendo imagen para promoción $codigoPromocion: $e');
      return null;
    }
  }

  /// Descarga y cachea una imagen desde URL
  Future<Uint8List?> _downloadAndCacheImage(String codigoPromocion, String url) async {
    try {
      if (_imageCache.containsKey(codigoPromocion)) {
        return _imageCache[codigoPromocion];
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        if (_isValidImageBytes(bytes)) {
          _imageCache[codigoPromocion] = bytes;
          return bytes;
        }
      }
      return null;
    } catch (e) {
      print('❌ Error descargando imagen desde $url: $e');
      return null;
    }
  }

  /// Verifica si un string es una URL
  bool _isUrl(String str) {
    return str.startsWith('http://') || str.startsWith('https://');
  }

  /// Valida si los bytes corresponden a una imagen válida
  bool _isValidImageBytes(Uint8List bytes) {
    if (bytes.length < 4) return false;

    final headers = bytes.take(4).toList();
    
    // JPEG: FF D8 FF
    if (headers[0] == 0xFF && headers[1] == 0xD8 && headers[2] == 0xFF) {
      return true;
    }
    
    // PNG: 89 50 4E 47
    if (headers[0] == 0x89 && headers[1] == 0x50 && headers[2] == 0x4E && headers[3] == 0x47) {
      return true;
    }
    
    // GIF: 47 49 46 38
    if (headers[0] == 0x47 && headers[1] == 0x49 && headers[2] == 0x46 && headers[3] == 0x38) {
      return true;
    }
    
    // WebP: 52 49 46 46 ... 57 45 42 50
    if (headers[0] == 0x52 && headers[1] == 0x49 && headers[2] == 0x46 && headers[3] == 0x46) {
      return true;
    }
    
    // BMP: 42 4D
    if (headers[0] == 0x42 && headers[1] == 0x4D) {
      return true;
    }
    
    return false;
  }

  /// Precarga imágenes de promociones para mejor rendimiento
  Future<void> preloadPromotionImages(List<String> codigosPromocion) async {
    for (final codigo in codigosPromocion) {
      await getPromotionImageBytes(codigo);
    }
    print('✅ Imágenes precargadas para ${codigosPromocion.length} promociones');
  }
}
