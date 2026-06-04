import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';

/// Servicio para gestionar ubicación manual del usuario.
/// Usa SharedPreferences para persistir entre sesiones.
/// Útil en web cuando la geolocalización no está disponible.
class ManualLocationService {
  static const String _latKey = 'manual_location_lat';
  static const String _lngKey = 'manual_location_lng';
  static const String _addressKey = 'manual_location_address';

  /// Guarda ubicación manual
  static Future<void> saveLocation(LatLng location, {String? address}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, location.latitude);
    await prefs.setDouble(_lngKey, location.longitude);
    if (address != null) {
      await prefs.setString(_addressKey, address);
    }
    if (kDebugMode) {
      debugPrint(
        'Ubicación manual guardada: ${location.latitude}, ${location.longitude}',
      );
    }
  }

  /// Obtiene ubicación manual guardada
  static Future<LatLng?> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey);
    final lng = prefs.getDouble(_lngKey);

    if (lat != null && lng != null) {
      // Validar rangos
      if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
        return LatLng(lat, lng);
      }
    }
    return null;
  }

  /// Obtiene dirección guardada
  static Future<String?> getSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_addressKey);
  }

  /// Elimina ubicación manual
  static Future<void> clearLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_latKey);
    await prefs.remove(_lngKey);
    await prefs.remove(_addressKey);
  }

  /// Verifica si hay ubicación manual guardada
  static Future<bool> hasSavedLocation() async {
    final location = await getSavedLocation();
    return location != null;
  }
}
