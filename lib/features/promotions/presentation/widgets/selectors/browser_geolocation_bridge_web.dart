import 'dart:html' as html;

/// Coordenada obtenida desde la API de geolocalizacion del navegador.
class BrowserGeolocationPoint {
  const BrowserGeolocationPoint({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

/// Solicita la ubicacion actual del navegador usando la implementacion web.
Future<BrowserGeolocationPoint> getBrowserGeolocation({
  required Duration timeout,
  required Duration maximumAge,
  bool enableHighAccuracy = false,
}) async {
  final geolocation = html.window.navigator.geolocation;
  final position = await geolocation.getCurrentPosition(
    enableHighAccuracy: enableHighAccuracy,
    timeout: timeout,
    maximumAge: maximumAge,
  );

  return BrowserGeolocationPoint(
    latitude: (position.coords?.latitude ?? 0).toDouble(),
    longitude: (position.coords?.longitude ?? 0).toDouble(),
  );
}
