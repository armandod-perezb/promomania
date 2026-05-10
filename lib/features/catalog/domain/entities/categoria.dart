// Clase que representa una categoría dentro del sistema (modelo de datos)
class Categoria {
  // Identificador único de la categoría (clave primaria)
  final int id;

  // Nombre de la categoría (campo obligatorio)
  final String nombre;

  // Descripción opcional (puede ser null)
  final String? descripcion;

  // Constructor de la clase con parámetros nombrados
  // "required" obliga a enviar id y nombre
  Categoria({required this.id, required this.nombre, this.descripcion});

  // Factory constructor que crea una instancia desde un JSON (Map)
  // Se usa cuando los datos vienen de una API o base de datos
  factory Categoria.fromJson(Map<String, dynamic> json) {
    // Retorna un nuevo objeto Categoria con los datos del JSON
    return Categoria(
      // Convierte el valor 'id' del JSON a entero
      id: json['id'] as int,

      // Convierte el valor 'nombre' del JSON a String
      nombre: json['nombre'] as String,

      // Convierte el valor 'descripcion' a String opcional (puede ser null)
      descripcion: json['descripcion'] as String?,
    );
  }

  // Método que convierte el objeto Categoria a JSON (Map)
  // Se usa para enviar datos al backend o guardar en base de datos
  Map<String, dynamic> toJson() {
    // Retorna un mapa con las propiedades del objeto
    return {
      // Clave 'id' con su valor correspondiente
      'id': id,

      // Clave 'nombre' con su valor correspondiente
      'nombre': nombre,

      // Clave 'descripcion' con su valor (puede ser null)
      'descripcion': descripcion,
    };
  }

  // Método copyWith para crear una copia del objeto con cambios parciales
  // Aplica el principio de inmutabilidad (no modifica el objeto original)
  Categoria copyWith({
    // Parámetro opcional para nuevo id
    int? id,

    // Parámetro opcional para nuevo nombre
    String? nombre,

    // Parámetro opcional para nueva descripción
    String? descripcion,
  }) {
    // Retorna una nueva instancia de Categoria
    return Categoria(
      // Si id es null, mantiene el valor actual
      id: id ?? this.id,

      // Si nombre es null, mantiene el valor actual
      nombre: nombre ?? this.nombre,

      // Si descripcion es null, mantiene el valor actual
      descripcion: descripcion ?? this.descripcion,
    );
  }
}
