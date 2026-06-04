// Clase que representa un comentario dentro del sistema
/// Entidad de comentario publicado por un usuario sobre una promocion.
class Comentario {
  // Identificador único del comentario (clave primaria)
  final int id;

  // Contenido del comentario (texto escrito por el usuario)
  final String contenido;

  // Fecha en la que se realizó el comentario (formato String)
  final String fecha;

  // ID del usuario que hizo el comentario (relación con entidad Usuario)
  final int idUsuario;

  // Código de la promoción a la que pertenece el comentario
  final String codigoPromocion;

  // ID del comentario al que responde (permite replies o comentarios anidados)
  // Puede ser null si es un comentario principal
  final int? idCommentReply;

  // Constructor con parámetros nombrados
  // Los campos principales son obligatorios excepto el reply
  Comentario({
    required this.id,
    required this.contenido,
    required this.fecha,
    required this.idUsuario,
    required this.codigoPromocion,
    this.idCommentReply,
  });

  // Factory que convierte un JSON (Map) en un objeto Comentario
  // Se usa cuando los datos vienen de una API o base de datos
  factory Comentario.fromJson(Map<String, dynamic> json) {
    // Retorna una nueva instancia de Comentario
    return Comentario(
      // Convierte el campo 'id' del JSON a entero
      id: json['id'] as int,

      // Convierte el campo 'contenido' a String
      contenido: json['contenido'] as String,

      // Convierte el campo 'fecha' a String
      fecha: json['fecha'] as String,

      // Convierte el campo 'id_usuario' a entero
      idUsuario: json['id_usuario'] as int,

      // Convierte el campo 'codigo_promocion' a String
      codigoPromocion: json['codigo_promocion'] as String,

      // Convierte el campo 'id_comment_reply' a entero opcional (puede ser null)
      idCommentReply: json['id_comment_reply'] as int?,
    );
  }

  // Método que convierte el objeto Comentario a JSON (Map)
  // Se usa para enviar datos al backend o almacenarlos
  Map<String, dynamic> toJson() {
    // Retorna un mapa con todos los atributos del comentario
    return {
      // Clave 'id' con su valor correspondiente
      'id': id,

      // Clave 'contenido' con el texto del comentario
      'contenido': contenido,

      // Clave 'fecha' con la fecha del comentario
      'fecha': fecha,

      // Clave 'id_usuario' con el ID del usuario
      'id_usuario': idUsuario,

      // Clave 'codigo_promocion' con la referencia a la promoción
      'codigo_promocion': codigoPromocion,

      // Clave 'id_comment_reply' con el ID del comentario padre (si existe)
      'id_comment_reply': idCommentReply,
    };
  }
}
