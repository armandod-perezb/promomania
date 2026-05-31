import 'dart:html' as html;

class BrowserGeolocationPoint {
  const BrowserGeolocationPoint({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

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
