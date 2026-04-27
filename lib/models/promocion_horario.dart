class PromocionHorario {
  final int id;
  final String diaSemana; // 'lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'
  final String horaInicio;
  final String horaFin;
  final String codigoPromocion;

  PromocionHorario({
    required this.id,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.codigoPromocion,
  });

  factory PromocionHorario.fromJson(Map<String, dynamic> json) {
    return PromocionHorario(
      id: json['id'] as int,
      diaSemana: json['dia_semana'] as String,
      horaInicio: json['hora_inicio'] as String,
      horaFin: json['hora_fin'] as String,
      codigoPromocion: json['codigo_promocion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'codigo_promocion': codigoPromocion,
    };
  }

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