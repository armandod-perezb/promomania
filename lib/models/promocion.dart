class Promocion {
  final String codigo;
  final String titulo;
  final String? descripcion;
  final double precio;
  final int? descuento;
  final String condicionProducto; // 'nuevo', 'usado', 'reacondicionado'
  final String? ubicacion;
  final String? url;
  final String? foto;
  final String tipoVigencia; // 'por_fecha' o 'permanente'
  final String? fechaInicio;
  final String? fechaFin;
  final String estado; // 'pendiente', 'aprobada', 'rechazada'
  final int vistas;
  final int idUsuario;
  final int idSupermercado;
  final int idCategoria;
  final int idTipoPromocion;

  Promocion({
    required this.codigo,
    required this.titulo,
    this.descripcion,
    required this.precio,
    this.descuento,
    required this.condicionProducto,
    this.ubicacion,
    this.url,
    this.foto,
    required this.tipoVigencia,
    this.fechaInicio,
    this.fechaFin,
    required this.estado,
    required this.vistas,
    required this.idUsuario,
    required this.idSupermercado,
    required this.idCategoria,
    required this.idTipoPromocion,
  });

  factory Promocion.fromJson(Map<String, dynamic> json) {
    return Promocion(
      codigo: json['codigo'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      precio: (json['precio'] as num).toDouble(),
      descuento: json['descuento'] as int?,
      condicionProducto: json['condicion_producto'] as String? ?? 'nuevo',
      ubicacion: json['ubicacion'] as String?,
      url: json['url'] as String?,
      foto: json['foto'] as String?,
      tipoVigencia: json['tipo_vigencia'] as String? ?? 'por_fecha',
      fechaInicio: json['fecha_inicio'] as String?,
      fechaFin: json['fecha_fin'] as String?,
      estado: json['estado'] as String? ?? 'pendiente',
      vistas: json['vistas'] as int? ?? 0,
      idUsuario: json['id_usuario'] as int,
      idSupermercado: json['id_supermercado'] as int,
      idCategoria: json['id_categoria'] as int,
      idTipoPromocion: json['id_tipo_promocion'] as int,
    );
  }

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
      'tipo_vigencia': tipoVigencia,
      'fecha_inicio': fechaInicio,
      'fecha_fin': fechaFin,
      'estado': estado,
      'vistas': vistas,
      'id_usuario': idUsuario,
      'id_supermercado': idSupermercado,
      'id_categoria': idCategoria,
      'id_tipo_promocion': idTipoPromocion,
    };
  }

  Promocion copyWith({
    String? codigo,
    String? titulo,
    String? descripcion,
    double? precio,
    int? descuento,
    String? condicionProducto,
    String? ubicacion,
    String? url,
    String? foto,
    String? tipoVigencia,
    String? fechaInicio,
    String? fechaFin,
    String? estado,
    int? vistas,
    int? idUsuario,
    int? idSupermercado,
    int? idCategoria,
    int? idTipoPromocion,
  }) {
    return Promocion(
      codigo: codigo ?? this.codigo,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      descuento: descuento ?? this.descuento,
      condicionProducto: condicionProducto ?? this.condicionProducto,
      ubicacion: ubicacion ?? this.ubicacion,
      url: url ?? this.url,
      foto: foto ?? this.foto,
      tipoVigencia: tipoVigencia ?? this.tipoVigencia,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      estado: estado ?? this.estado,
      vistas: vistas ?? this.vistas,
      idUsuario: idUsuario ?? this.idUsuario,
      idSupermercado: idSupermercado ?? this.idSupermercado,
      idCategoria: idCategoria ?? this.idCategoria,
      idTipoPromocion: idTipoPromocion ?? this.idTipoPromocion,
    );
  }
}
