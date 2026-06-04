/// Entidad que modela una campana de notificaciones push.
class PushCampaign {
  final int id;
  final String titulo;
  final String mensaje;
  final String estado;
  final int enviados;
  final int aperturas;
  final int clicks;
  final DateTime? programadaEn;
  final DateTime? enviadaEn;

  PushCampaign({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.estado,
    required this.enviados,
    required this.aperturas,
    required this.clicks,
    this.programadaEn,
    this.enviadaEn,
  });

  PushCampaign copyWith({
    int? id,
    String? titulo,
    String? mensaje,
    String? estado,
    int? enviados,
    int? aperturas,
    int? clicks,
    DateTime? programadaEn,
    DateTime? enviadaEn,
  }) {
    return PushCampaign(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      mensaje: mensaje ?? this.mensaje,
      estado: estado ?? this.estado,
      enviados: enviados ?? this.enviados,
      aperturas: aperturas ?? this.aperturas,
      clicks: clicks ?? this.clicks,
      programadaEn: programadaEn ?? this.programadaEn,
      enviadaEn: enviadaEn ?? this.enviadaEn,
    );
  }
}
