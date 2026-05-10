/// DTO para crear una nueva promoción.
///
/// Encapsula los datos del usuario para crear una promoción.
class CreatePromotionDTO {
  final String codigo;
  final String titulo;
  final String? descripcion;
  final double precio;
  final int? descuento;
  final String condicionProducto;
  final String? ubicacion;
  final String? url;
  final String? foto;
  final bool fotoEsLocal;
  final String tipoVigencia;
  final String? fechaInicio;
  final String? fechaFin;
  final int idSupermercado;
  final int idCategoria;
  final int idTipoPromocion;
  final double? lat;
  final double? lng;

  CreatePromotionDTO({
    required this.codigo,
    required this.titulo,
    this.descripcion,
    required this.precio,
    this.descuento,
    required this.condicionProducto,
    this.ubicacion,
    this.url,
    this.foto,
    this.fotoEsLocal = false,
    required this.tipoVigencia,
    this.fechaInicio,
    this.fechaFin,
    required this.idSupermercado,
    required this.idCategoria,
    required this.idTipoPromocion,
    this.lat,
    this.lng,
  });

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'titulo': titulo,
      'descripcion': descripcion,
      'precio': precio,
      'descuento': descuento,
      'condicion_producto': condicionProducto,
      'ubicacion': ubicacion,
      'url': url,
      'foto': foto,
      'foto_es_local': fotoEsLocal,
      'tipo_vigencia': tipoVigencia,
      'fecha_inicio': fechaInicio,
      'fecha_fin': fechaFin,
      'id_supermercado': idSupermercado,
      'id_categoria': idCategoria,
      'id_tipo_promocion': idTipoPromocion,
      'lat': lat,
      'lng': lng,
    };
  }
}

/// DTO para actualizar una promoción existente.
///
/// Permite actualizar campos seleccionados de una promoción.
class UpdatePromotionDTO {
  final String codigo;
  final String? titulo;
  final String? descripcion;
  final double? precio;
  final int? descuento;
  final String? estado;
  final String? fechaFin;

  UpdatePromotionDTO({
    required this.codigo,
    this.titulo,
    this.descripcion,
    this.precio,
    this.descuento,
    this.estado,
    this.fechaFin,
  });

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'titulo': titulo,
      'descripcion': descripcion,
      'precio': precio,
      'descuento': descuento,
      'estado': estado,
      'fecha_fin': fechaFin,
    };
  }
}

/// DTO para filtrar promociones.
///
/// Encapsula los criterios de búsqueda y filtrado.
class PromotionFilterDTO {
  final int? categoryId;
  final int? supermarketId;
  final int? typeId;
  final String? estado;
  final int? page;
  final int? pageSize;

  PromotionFilterDTO({
    this.categoryId,
    this.supermarketId,
    this.typeId,
    this.estado,
    this.page,
    this.pageSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_categoria': categoryId,
      'id_supermercado': supermarketId,
      'id_tipo_promocion': typeId,
      'estado': estado,
      'page': page,
      'page_size': pageSize,
    };
  }
}
