/// Entidad que vincula un usuario con una promocion guardada como favorita.
class Favorito {
  final int id;
  final int idUsuario;
  final String codigoPromocion;
  final String fecha;

  Favorito({
    required this.id,
    required this.idUsuario,
    required this.codigoPromocion,
    required this.fecha,
  });

  factory Favorito.fromJson(Map<String, dynamic> json) {
    return Favorito(
      id: json['id'] as int,
      idUsuario: json['id_usuario'] as int,
      codigoPromocion: json['codigo_promocion'] as String,
      fecha: json['fecha'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_usuario': idUsuario,
      'codigo_promocion': codigoPromocion,
      'fecha': fecha,
    };
  }
}
