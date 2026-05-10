import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app/core/storage/image_storage_service.dart';
import 'package:app/features/catalog/domain/entities/categoria.dart';
import 'package:app/features/comments/domain/entities/comentario.dart';
import 'package:app/features/interactions/domain/entities/favorito.dart';
import 'package:app/features/promotions/domain/entities/promocion.dart';
import 'package:app/features/promotions/domain/entities/promocion_horario.dart';
import 'package:app/features/moderation/domain/entities/reporte.dart';
import 'package:app/features/promotions/domain/entities/supermercado.dart';
import 'package:app/features/catalog/domain/entities/tipo_promocion.dart';
import 'package:app/features/users/domain/entities/usuario.dart';
import 'package:app/features/interactions/domain/entities/valoracion.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PromoLocalDataSource {
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

  final Map<String, Uint8List> imageCache = {};
  final ImageStorageService imageStorage;

  PromoLocalDataSource({ImageStorageService? imageStorage})
    : imageStorage = imageStorage ?? ImageStorageService();

  Future<void> init() async {
    if (loaded) return;

    try {
      loadError = null;
      final response = await rootBundle.loadString(
        'assets/data/promomania_data.json',
      );
      final data = json.decode(response);

      usuarios = (data['usuarios'] as List)
          .map((u) => Usuario.fromJson(u as Map<String, dynamic>))
          .toList();
      supermercados = (data['supermercados'] as List)
          .map((s) => Supermercado.fromJson(s as Map<String, dynamic>))
          .toList();
      categorias = (data['categorias'] as List)
          .map((c) => Categoria.fromJson(c as Map<String, dynamic>))
          .toList();
      tiposPromocion = (data['tipos_promocion'] as List)
          .map((t) => TipoPromocion.fromJson(t as Map<String, dynamic>))
          .toList();
      promociones = (data['promociones'] as List)
          .map((p) => Promocion.fromJson(p as Map<String, dynamic>))
          .toList();
      promocionesHorarios = (data['promociones_horarios'] as List)
          .map((h) => PromocionHorario.fromJson(h as Map<String, dynamic>))
          .toList();
      comentarios = (data['comentarios'] as List)
          .map((c) => Comentario.fromJson(c as Map<String, dynamic>))
          .toList();
      valoraciones = (data['valoraciones'] as List)
          .map((v) => Valoracion.fromJson(v as Map<String, dynamic>))
          .toList();
      favoritos = (data['favoritos'] as List)
          .map((f) => Favorito.fromJson(f as Map<String, dynamic>))
          .toList();
      reportes = (data['reportes'] as List)
          .map((r) => Reporte.fromJson(r as Map<String, dynamic>))
          .toList();

      loaded = true;
    } catch (e) {
      loadError = e.toString();
      loaded = false;
    }
  }

  Future<File> _getDataFile() async {
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      return File('${directory.path}/promomania_data.json');
    }
    return File('promomania_data.json');
  }

  Future<void> loadLocalPromociones() async {
    try {
      if (!kIsWeb) {
        final file = await _getDataFile();
        if (!await file.exists()) return;

        final content = await file.readAsString();
        final data = json.decode(content) as Map<String, dynamic>;

        if (data['promociones'] != null) {
          promociones = (data['promociones'] as List)
              .map((p) => Promocion.fromJson(p as Map<String, dynamic>))
              .toList();
        }

        if (data['promociones_horarios'] != null) {
          promocionesHorarios = (data['promociones_horarios'] as List)
              .map((h) => PromocionHorario.fromJson(h as Map<String, dynamic>))
              .toList();
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        final dataString = prefs.getString('promomania_data');
        if (dataString == null) return;

        final data = json.decode(dataString) as Map<String, dynamic>;

        if (data['promociones'] != null) {
          promociones = (data['promociones'] as List)
              .map((p) => Promocion.fromJson(p as Map<String, dynamic>))
              .toList();
        }

        if (data['promociones_horarios'] != null) {
          promocionesHorarios = (data['promociones_horarios'] as List)
              .map((h) => PromocionHorario.fromJson(h as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Mantener comportamiento resiliente de la implementación original.
    }
  }

  Future<void> saveLocalData() async {
    try {
      final data = {
        'promociones': promociones.map((p) => p.toJson()).toList(),
        'promociones_horarios': promocionesHorarios
            .map((h) => h.toJson())
            .toList(),
      };

      if (!kIsWeb) {
        final file = await _getDataFile();
        await file.writeAsString(json.encode(data), flush: true);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('promomania_data', json.encode(data));
      }
    } catch (_) {
      // Mantener comportamiento resiliente de la implementación original.
    }
  }

  Usuario? getUsuario(int id) {
    try {
      return usuarios.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  Usuario? getUsuarioByEmail(String email) {
    try {
      return usuarios.firstWhere((u) => u.correo == email);
    } catch (_) {
      return null;
    }
  }

  List<Promocion> getPromocionesAprobadas() =>
      promociones.where((p) => p.estado == 'aprobada').toList();

  List<Promocion> getPromocionesById(int idUsuario) =>
      promociones.where((p) => p.idUsuario == idUsuario).toList();

  Promocion? getPromocionByCodigo(String codigo) {
    try {
      return promociones.firstWhere((p) => p.codigo == codigo);
    } catch (_) {
      return null;
    }
  }

  List<Promocion> getPromocionesByCategoria(int idCategoria) =>
      promociones.where((p) => p.idCategoria == idCategoria).toList();

  List<Promocion> getPromocionesBySupermercado(int idSupermercado) =>
      promociones.where((p) => p.idSupermercado == idSupermercado).toList();

  void addPromocion(Promocion promocion) {
    promociones.add(promocion);
  }

  void updatePromocion(Promocion promocion) {
    final index = promociones.indexWhere((p) => p.codigo == promocion.codigo);
    if (index != -1) {
      promociones[index] = promocion;
    }
  }

  void deletePromocion(String codigo) {
    promociones.removeWhere((p) => p.codigo == codigo);
  }

  List<PromocionHorario> getPromocionesHorariosByCodigo(
    String codigoPromocion,
  ) => promocionesHorarios
      .where((h) => h.codigoPromocion == codigoPromocion)
      .toList();

  void addPromocionHorario(PromocionHorario promocionHorario) {
    promocionesHorarios.add(promocionHorario);
  }

  void updatePromocionHorario(PromocionHorario promocionHorario) {
    final index = promocionesHorarios.indexWhere(
      (h) => h.id == promocionHorario.id,
    );
    if (index != -1) {
      promocionesHorarios[index] = promocionHorario;
    }
  }

  void deletePromocionHorario(int id) {
    promocionesHorarios.removeWhere((h) => h.id == id);
  }

  void incrementarVistas(String codigo) {
    final index = promociones.indexWhere((p) => p.codigo == codigo);
    if (index != -1) {
      final promo = promociones[index];
      promociones[index] = promo.copyWith(vistas: promo.vistas + 1);
    }
  }

  Supermercado? getSupermercado(int id) {
    try {
      return supermercados.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Categoria? getCategoria(int id) {
    try {
      return categorias.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  TipoPromocion? getTipoPromocion(int id) {
    try {
      return tiposPromocion.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Comentario> getComentariosByPromocion(String codigoPromocion) =>
      comentarios.where((c) => c.codigoPromocion == codigoPromocion).toList();

  void addComentario(Comentario comentario) {
    comentarios.add(comentario);
  }

  void deleteComentario(int id) {
    comentarios.removeWhere((c) => c.id == id);
  }

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
  }

  void deleteValoracion(int id) {
    valoraciones.removeWhere((v) => v.id == id);
  }

  List<Favorito> getFavoritosByUsuario(int idUsuario) =>
      favoritos.where((f) => f.idUsuario == idUsuario).toList();

  bool isFavorito(int idUsuario, String codigoPromocion) => favoritos.any(
    (f) => f.idUsuario == idUsuario && f.codigoPromocion == codigoPromocion,
  );

  void addFavorito(Favorito favorito) {
    if (!isFavorito(favorito.idUsuario, favorito.codigoPromocion)) {
      favoritos.add(favorito);
    }
  }

  void removeFavorito(int idUsuario, String codigoPromocion) {
    favoritos.removeWhere(
      (f) => f.idUsuario == idUsuario && f.codigoPromocion == codigoPromocion,
    );
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

  List<Reporte> getReportesByUsuario(int idUsuario) =>
      reportes.where((r) => r.idUsuario == idUsuario).toList();

  List<Reporte> getReportesByPromocion(String codigoPromocion) =>
      reportes.where((r) => r.codigoPromocion == codigoPromocion).toList();

  void addReporte(Reporte reporte) {
    reportes.add(reporte);
  }

  void updateReporte(Reporte reporte) {
    final index = reportes.indexWhere((r) => r.id == reporte.id);
    if (index != -1) {
      reportes[index] = reporte;
    }
  }

  void deleteReporte(int id) {
    reportes.removeWhere((r) => r.id == id);
  }

  List<Promocion> getFlashDeals({int limit = 5}) {
    final aprobadas = getPromocionesAprobadas();
    aprobadas.sort((a, b) {
      if (a.descuento != null && b.descuento != null) {
        return b.descuento!.compareTo(a.descuento!);
      }
      if (a.descuento != null) return -1;
      if (b.descuento != null) return 1;
      return b.vistas.compareTo(a.vistas);
    });
    return aprobadas.take(limit).toList();
  }

  List<Map<String, dynamic>> getNearbyStores({int limit = 5}) {
    final supermercadosConPromos = <int, List<Promocion>>{};

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

    nearbyStores.sort(
      (a, b) => a['supermercado'].id.compareTo(b['supermercado'].id),
    );
    return nearbyStores.take(limit).toList();
  }

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
      }
      return 'noRush';
    } catch (_) {
      return 'noRush';
    }
  }

  Map<String, List<Promocion>> getPromocionesByUrgency(int idUsuario) {
    final favoritosUsuario = getFavoritosByUsuario(idUsuario);
    final promocionesFavoritas = favoritosUsuario
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

  double getPrecioConDescuento(Promocion promo) {
    if (promo.descuento == null || promo.descuento == 0) {
      return promo.precio;
    }
    return promo.precio * (1 - promo.descuento! / 100);
  }

  double getPromocionRating(String codigoPromocion) {
    final valoracionesPromo = getValoracionesByPromocion(codigoPromocion);
    if (valoracionesPromo.isEmpty) return 0.0;

    final positivas = valoracionesPromo
        .where((v) => v.tipo == 'positiva')
        .length;
    return (positivas / valoracionesPromo.length) * 5.0;
  }

  int getPromocionReviewsCount(String codigoPromocion) {
    return getComentariosByPromocion(codigoPromocion).length;
  }

  Future<String?> savePromotionImage(
    String codigoPromocion,
    Uint8List bytes,
  ) async {
    try {
      if (!_isValidImageBytes(bytes)) {
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'promo_${codigoPromocion}_$timestamp.jpg';
      final savedFileName = await imageStorage.saveImageFromBytes(
        bytes,
        fileName: fileName,
      );

      final promocionIndex = promociones.indexWhere(
        (p) => p.codigo == codigoPromocion,
      );
      if (promocionIndex != -1) {
        final updatedPromocion = promociones[promocionIndex].copyWith(
          foto: savedFileName,
          fotoEsLocal: true,
        );
        promociones[promocionIndex] = updatedPromocion;
        await saveLocalData();
      }

      imageCache[codigoPromocion] = bytes;
      return savedFileName;
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List?> getPromotionImageBytes(String codigoPromocion) async {
    try {
      final promocion = getPromocionByCodigo(codigoPromocion);
      if (promocion == null || promocion.foto == null) {
        return null;
      }

      if (promocion.fotoEsLocal || !_isUrl(promocion.foto!)) {
        return await imageStorage.readImageBytes(promocion.foto!);
      }

      return await _downloadAndCacheImage(codigoPromocion, promocion.foto!);
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List?> _downloadAndCacheImage(
    String codigoPromocion,
    String url,
  ) async {
    try {
      if (imageCache.containsKey(codigoPromocion)) {
        return imageCache[codigoPromocion];
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        if (_isValidImageBytes(bytes)) {
          imageCache[codigoPromocion] = bytes;
          return bytes;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  bool _isUrl(String str) {
    return str.startsWith('http://') || str.startsWith('https://');
  }

  bool _isValidImageBytes(Uint8List bytes) {
    if (bytes.length < 4) return false;

    final headers = bytes.take(4).toList();

    if (headers[0] == 0xFF && headers[1] == 0xD8 && headers[2] == 0xFF)
      return true;
    if (headers[0] == 0x89 &&
        headers[1] == 0x50 &&
        headers[2] == 0x4E &&
        headers[3] == 0x47) {
      return true;
    }
    if (headers[0] == 0x47 &&
        headers[1] == 0x49 &&
        headers[2] == 0x46 &&
        headers[3] == 0x38) {
      return true;
    }
    if (headers[0] == 0x52 &&
        headers[1] == 0x49 &&
        headers[2] == 0x46 &&
        headers[3] == 0x46) {
      return true;
    }
    if (headers[0] == 0x42 && headers[1] == 0x4D) return true;

    return false;
  }

  Future<void> preloadPromotionImages(List<String> codigosPromocion) async {
    for (final codigo in codigosPromocion) {
      await getPromotionImageBytes(codigo);
    }
  }
}
