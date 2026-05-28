/// Modelo que representa una promoción publicada en la app.
///
/// Este objeto contiene los metadatos necesarios para mostrar
/// una promoción en listados y en su detalle, así como la
/// información necesaria para la persistencia en JSON.
class Promocion {
  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  static double _asDouble(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    final normalized = value.toString().replaceAll(',', '.').trim();
    return double.tryParse(normalized) ?? fallback;
  }

  /// Código único alfanumérico de la promoción (por ejemplo 'PROMO001').
  final String codigo;

  /// Título principal de la promoción que verá el usuario.
  final String titulo;

  /// Descripción opcional con detalles y condiciones.
  final String? descripcion;

  /// Precio del producto/oferta en COP.
  final double precio;

  /// Descuento en porcentaje (si aplica).
  final int? descuento;

  /// Condición del producto: 'nuevo' | 'usado' | 'reacondicionado'.
  final String condicionProducto;

  /// Ubicación o dirección donde aplica la promoción.
  final String? ubicacion;

  /// URL externa asociada (sitio de la tienda, compra, etc.).
  final String? url;

  /// Nombre de archivo o URL de la foto principal de la promoción.
  final String? foto;

  /// Indica si `foto` es un archivo local gestionado por la app.
  final bool fotoEsLocal;

  /// Tipo de vigencia: 'por_fecha' (tiene fechas) o 'permanente'.
  final String tipoVigencia;

  /// Fecha de inicio (ISO yyyy-mm-dd) si `tipoVigencia` == 'por_fecha'.
  final String? fechaInicio;

  /// Fecha de fin (ISO yyyy-mm-dd) si `tipoVigencia` == 'por_fecha'.
  final String? fechaFin;

  /// Estado de la promoción en el flujo de revisión: 'pendiente', 'aprobada', 'rechazada'.
  final String estado;

  /// Contador de vistas para métricas internas.
  final int vistas;

  /// ID del usuario que creó la promoción (referencia a `Usuario`).
  final int idUsuario;

  /// ID del supermercado/tienda asociado (referencia a `Supermercado`).
  final int idSupermercado;

  /// ID de la categoría a la que pertenece la promoción.
  final int idCategoria;

  /// ID del tipo de promoción (por ejemplo, descuento, combo, etc.).
  final int idTipoPromocion;

  /// Coordenadas opcionales (lat, lng) para mapas.
  final double? lat;
  final double? lng;

  /// Constructor principal. Campos obligatorios aseguran que la promo tenga
  /// los metadatos mínimos necesarios para mostrarse y persistirse.
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
    this.fotoEsLocal = false,
    required this.tipoVigencia,
    this.fechaInicio,
    this.fechaFin,
    required this.estado,
    required this.vistas,
    required this.idUsuario,
    required this.idSupermercado,
    required this.idCategoria,
    required this.idTipoPromocion,
    this.lat,
    this.lng,
  });

  /// Crea una instancia a partir de un `Map` (por ejemplo, parseado desde JSON).
  ///
  /// El `fromJson` normaliza tipos numéricos y aplica valores por defecto
  /// cuando la información no está presente en el JSON.
  factory Promocion.fromJson(Map<String, dynamic> json) {
    return Promocion(
      codigo: json['codigo'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      precio: _asDouble(json['precio']),
      descuento: json['descuento'] == null ? null : _asInt(json['descuento']),
      condicionProducto: json['condicion_producto'] as String? ?? 'nuevo',
      ubicacion: json['ubicacion'] as String?,
      url: json['url'] as String?,
      foto: json['foto'] as String?,
      fotoEsLocal: json['foto_es_local'] as bool? ?? false,
      tipoVigencia: json['tipo_vigencia'] as String? ?? 'por_fecha',
      fechaInicio: json['fecha_inicio'] as String?,
      fechaFin: json['fecha_fin'] as String?,
      estado: json['estado'] as String? ?? 'pendiente',
      vistas: _asInt(json['vistas']),
      idUsuario: _asInt(json['id_usuario']),
      idSupermercado: _asInt(json['id_supermercado']),
      idCategoria: _asInt(json['id_categoria']),
      idTipoPromocion: _asInt(json['id_tipo_promocion']),
      lat: json['lat'] == null ? null : _asDouble(json['lat']),
      lng: json['lng'] == null ? null : _asDouble(json['lng']),
    );
  }

  /// Convierte la instancia a un `Map` listo para serializar a JSON.
  ///
  /// Las claves siguen la convención esperada por el servicio de persistencia
  /// y por el archivo `promomania_data.json` empaquetado.
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
      'estado': estado,
      'vistas': vistas,
      'id_usuario': idUsuario,
      'id_supermercado': idSupermercado,
      'id_categoria': idCategoria,
      'id_tipo_promocion': idTipoPromocion,
      'lat': lat,
      'lng': lng,
    };
  }

  /// Crea una copia inmutable del objeto, permitiendo sobrescribir campos.
  ///
  /// Útil para actualizar un solo campo (por ejemplo incrementar vistas)
  /// sin recrear todos los valores manualmente.
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
    bool? fotoEsLocal,
    String? tipoVigencia,
    String? fechaInicio,
    String? fechaFin,
    String? estado,
    int? vistas,
    int? idUsuario,
    int? idSupermercado,
    int? idCategoria,
    int? idTipoPromocion,
    double? lat,
    double? lng,
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
      fotoEsLocal: fotoEsLocal ?? this.fotoEsLocal,
      tipoVigencia: tipoVigencia ?? this.tipoVigencia,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      estado: estado ?? this.estado,
      vistas: vistas ?? this.vistas,
      idUsuario: idUsuario ?? this.idUsuario,
      idSupermercado: idSupermercado ?? this.idSupermercado,
      idCategoria: idCategoria ?? this.idCategoria,
      idTipoPromocion: idTipoPromocion ?? this.idTipoPromocion,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}
