/// Coordenada compatible con la implementacion web de geolocalizacion.
class BrowserGeolocationPoint {
  const BrowserGeolocationPoint({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

/// Implementacion de reserva para plataformas donde `dart:html` no existe.
Future<BrowserGeolocationPoint> getBrowserGeolocation({
  required Duration timeout,
  required Duration maximumAge,
  bool enableHighAccuracy = false,
}) {
  throw UnsupportedError('Browser geolocation is only available on web.');
}
