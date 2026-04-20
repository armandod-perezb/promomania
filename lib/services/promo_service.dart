import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/usuario.dart';
import '../models/supermercado.dart';
import '../models/categoria.dart';
import '../models/tipo_promocion.dart';
import '../models/promocion.dart';
import '../models/comentario.dart';
import '../models/valoracion.dart';
import '../models/favorito.dart';

class PromoService {
  // "Base de datos" en memoria
  List<Usuario> usuarios = [];
  List<Supermercado> supermercados = [];
  List<Categoria> categorias = [];
  List<TipoPromocion> tiposPromocion = [];
  List<Promocion> promociones = [];
  List<Comentario> comentarios = [];
  List<Valoracion> valoraciones = [];
  List<Favorito> favoritos = [];

  bool loaded = false;

  /// Inicializa los datos desde el JSON
  Future<void> init() async {
    if (loaded) return;

    try {
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

      loaded = true;
    } catch (e) {
      print('Error cargando datos: $e');
      loaded = false;
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
  }

  void updateUsuario(Usuario usuario) {
    final index = usuarios.indexWhere((u) => u.id == usuario.id);
    if (index != -1) {
      usuarios[index] = usuario;
    }
  }

  void deleteUsuario(int id) {
    usuarios.removeWhere((u) => u.id == id);
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

  void incrementarVistas(String codigo) {
    final index = promociones.indexWhere((p) => p.codigo == codigo);
    if (index != -1) {
      final promo = promociones[index];
      promociones[index] = promo.copyWith(vistas: promo.vistas + 1);
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
  }

  void deleteComentario(int id) {
    comentarios.removeWhere((c) => c.id == id);
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
  }

  void deleteValoracion(int id) {
    valoraciones.removeWhere((v) => v.id == id);
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
}
