class Valoracion {
  final int id;
  final String tipo; // 'positiva' o 'negativa'
  final int idUsuario;
  final String codigoPromocion;

  Valoracion({
    required this.id,
    required this.tipo,
    required this.idUsuario,
    required this.codigoPromocion,
  });

  factory Valoracion.fromJson(Map<String, dynamic> json) {
    return Valoracion(
      id: json['id'] as int,
      tipo: json['tipo'] as String,
      idUsuario: json['id_usuario'] as int,
      codigoPromocion: json['codigo_promocion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'id_usuario': idUsuario,
      'codigo_promocion': codigoPromocion,
    };
  }
}
