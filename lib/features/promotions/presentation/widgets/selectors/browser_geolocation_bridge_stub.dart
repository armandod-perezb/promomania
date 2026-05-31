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
}) {
  throw UnsupportedError('Browser geolocation is only available on web.');
}
