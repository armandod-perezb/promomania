class Comentario {
  final int id;
  final String contenido;
  final String fecha;
  final int idUsuario;
  final String codigoPromocion;
  final int? idCommentReply;

  Comentario({
    required this.id,
    required this.contenido,
    required this.fecha,
    required this.idUsuario,
    required this.codigoPromocion,
    this.idCommentReply,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['id'] as int,
      contenido: json['contenido'] as String,
      fecha: json['fecha'] as String,
      idUsuario: json['id_usuario'] as int,
      codigoPromocion: json['codigo_promocion'] as String,
      idCommentReply: json['id_comment_reply'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contenido': contenido,
      'fecha': fecha,
      'id_usuario': idUsuario,
      'codigo_promocion': codigoPromocion,
      'id_comment_reply': idCommentReply,
    };
  }
}
