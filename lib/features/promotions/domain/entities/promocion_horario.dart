/// Modelo que representa un horario asociado a una promoción.
///
/// Cada instancia indica en qué día de la semana y en qué rango
/// de horas (inicio-fin) la promoción está activa, y está ligada
/// a una promoción mediante `codigoPromocion`.
class PromocionHorario {
  /// Identificador único del horario (entero incremental).
  final int id;

  /// Día de la semana en minúsculas, por ejemplo: 'lunes', 'martes', ...
  final String diaSemana;

  /// Hora de inicio en formato 'HH:MM' (24h), por ejemplo '09:00'.
  final String horaInicio;

  /// Hora de fin en formato 'HH:MM' (24h), por ejemplo '18:00'.
  final String horaFin;

  /// Código de la promoción a la que pertenece este horario.
  final String codigoPromocion;

  /// Constructor principal: todos los campos son obligatorios.
  PromocionHorario({
    required this.id,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.codigoPromocion,
  });

  /// Crea una instancia desde un `Map` obtenido al parsear JSON.
  ///
  /// Se espera que las claves del JSON sigan la convención usada
  /// por la aplicación: `dia_semana`, `hora_inicio`, `hora_fin` y
  /// `codigo_promocion`.
  factory PromocionHorario.fromJson(Map<String, dynamic> json) {
    return PromocionHorario(
      id: json['id'] as int,
      diaSemana: json['dia_semana'] as String,
      horaInicio: json['hora_inicio'] as String,
      horaFin: json['hora_fin'] as String,
      codigoPromocion: json['codigo_promocion'] as String,
    );
  }

  /// Serializa la instancia a `Map<String, dynamic>` para convertirla a JSON.
  ///
  /// Útil para persistir los horarios junto con las promociones.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'codigo_promocion': codigoPromocion,
    };
  }

  /// Devuelve una copia del objeto modificando solo los campos provistos.
  ///
  /// Esto facilita actualizar campos de forma inmutable (patrón `copyWith`).
  PromocionHorario copyWith({
    int? id,
    String? diaSemana,
    String? horaInicio,
    String? horaFin,
    String? codigoPromocion,
  }) {
    return PromocionHorario(
      id: id ?? this.id,
      diaSemana: diaSemana ?? this.diaSemana,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      codigoPromocion: codigoPromocion ?? this.codigoPromocion,
    );
  }
}
