import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'browser_geolocation_bridge.dart';

/// Tipos de ubicación soportados
enum TipoUbicacion {
  fisica,
  virtual,
  ambas;

  String get displayName {
    switch (this) {
      case TipoUbicacion.fisica:
        return 'Local Físico';
      case TipoUbicacion.virtual:
        return 'Local Virtual';
      case TipoUbicacion.ambas:
        return 'Ambos (Físico y Virtual)';
    }
  }

  IconData get icon {
    switch (this) {
      case TipoUbicacion.fisica:
        return Icons.store;
      case TipoUbicacion.virtual:
        return Icons.language;
      case TipoUbicacion.ambas:
        return Icons.sync_alt;
    }
  }
}

/// Selector de ubicación con soporte para física, virtual o ambas
class LocationSelector extends StatefulWidget {
  final Set<TipoUbicacion> selectedTypes;
  final ValueChanged<Set<TipoUbicacion>> onTypesChanged;

  // Para ubicación física
  final TextEditingController? descripcionUbicacionController;
  final double? latitud;
  final double? longitud;
  final ValueChanged<LatLng?>? onLocationSelected;

  // Para ubicación virtual
  final TextEditingController? urlController;
  final String? urlError;

  // Validaciones
  final String? ubicacionError;

  const LocationSelector({
    super.key,
    required this.selectedTypes,
    required this.onTypesChanged,
    this.descripcionUbicacionController,
    this.latitud,
    this.longitud,
    this.onLocationSelected,
    this.urlController,
    this.urlError,
    this.ubicacionError,
  });

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  bool _hasValidCoordinates(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (lat.isNaN || lng.isNaN || lat.isInfinite || lng.isInfinite) {
      return false;
    }

    final isInRange = lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
    if (!isInRange) return false;

    // (0, 0) suele representar "sin coordenadas" en persistencias antiguas.
    return !(lat == 0.0 && lng == 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF5733);
    final textDark = const Color(0xFF1A1A2E);
    final textGray = const Color(0xFF8A8A9A);

    final showFisica =
        widget.selectedTypes.contains(TipoUbicacion.fisica) ||
        widget.selectedTypes.contains(TipoUbicacion.ambas);
    final showVirtual =
        widget.selectedTypes.contains(TipoUbicacion.virtual) ||
        widget.selectedTypes.contains(TipoUbicacion.ambas);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Título
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text(
                'UBICACIÓN DE LA PROMOCIÓN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: textGray,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),

        // Selector de tipo de ubicación
        _buildTipoUbicacionSelector(primaryColor, textDark),

        const SizedBox(height: 16),

        // Campos de ubicación física
        if (showFisica) ...[
          _buildFisicaSection(primaryColor),
          const SizedBox(height: 16),
        ],

        // Campos de ubicación virtual
        if (showVirtual) ...[_buildVirtualSection(primaryColor)],
      ],
    );
  }

  Widget _buildTipoUbicacionSelector(Color primaryColor, Color textDark) {
    return Column(
      children: TipoUbicacion.values.map((tipo) {
        final isSelected =
            widget.selectedTypes.contains(tipo) ||
            (tipo == TipoUbicacion.fisica &&
                widget.selectedTypes.contains(TipoUbicacion.ambas)) ||
            (tipo == TipoUbicacion.virtual &&
                widget.selectedTypes.contains(TipoUbicacion.ambas));

        // Para "ambas" se comporta como checkbox, los demás como radio
        final isAmbas = tipo == TipoUbicacion.ambas;

        return GestureDetector(
          onTap: () {
            final newSet = Set<TipoUbicacion>.from(widget.selectedTypes);
            if (isAmbas) {
              // Si selecciona ambas, limpiamos las individuales
              if (newSet.contains(TipoUbicacion.ambas)) {
                newSet.remove(TipoUbicacion.ambas);
              } else {
                newSet
                  ..remove(TipoUbicacion.fisica)
                  ..remove(TipoUbicacion.virtual)
                  ..add(TipoUbicacion.ambas);
              }
            } else {
              // Si selecciona una individual, quitamos ambas
              newSet.remove(TipoUbicacion.ambas);
              if (newSet.contains(tipo)) {
                newSet.remove(tipo);
              } else {
                newSet.add(tipo);
              }
            }
            widget.onTypesChanged(newSet);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? primaryColor : const Color(0xFFEEEEF2),
                width: isSelected ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  tipo.icon,
                  color: isSelected ? primaryColor : const Color(0xFF8A8FA8),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tipo.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected ? primaryColor : textDark,
                    ),
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : const Color(0xFFCDD0DB),
                      width: 2,
                    ),
                    color: isSelected ? primaryColor : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFisicaSection(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.ubicacionError != null
              ? Colors.red.withOpacity(0.3)
              : const Color(0xFFE8EAF0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.store, color: primaryColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'Ubicación Física',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Descripción de ubicación
          _buildLabel('Describe con tus palabras dónde está ubicado el local'),
          TextField(
            controller: widget.descripcionUbicacionController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText:
                  'Ej: Frente al centro comercial, al lado de la farmacia',
              hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.5),
                fontSize: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEEEEF2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEEEEF2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Botón para elegir ubicación en mapa
          if (widget.onLocationSelected != null) _buildMapButton(primaryColor),

          // Mostrar coordenadas seleccionadas
          if (widget.latitud != null && widget.longitud != null)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ubicación confirmada',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'Lat: ${widget.latitud!.toStringAsFixed(6)}, Lng: ${widget.longitud!.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          if (widget.ubicacionError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.ubicacionError!,
                style: const TextStyle(color: Colors.red, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapButton(Color primaryColor) {
    final hasCoordinates = _hasValidCoordinates(
      widget.latitud,
      widget.longitud,
    );

    return GestureDetector(
      onTap: () => _showMapPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              hasCoordinates
                  ? 'Cambiar ubicación en mapa'
                  : 'Elegir ubicación en mapa',
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVirtualSection(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.urlError != null
              ? Colors.red.withOpacity(0.3)
              : const Color(0xFFE8EAF0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language, color: primaryColor, size: 18),
              const SizedBox(width: 8),
              Text(
                'Ubicación Virtual',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLabel('URL del sitio web (debe comenzar con https://)'),
          TextField(
            controller: widget.urlController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'https://tienda.com/promocion',
              hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.5),
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.link,
                color: Color(0xFF8A8FA8),
                size: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEEEEF2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: widget.urlError != null
                      ? Colors.red
                      : const Color(0xFFEEEEF2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: widget.urlError != null ? Colors.red : primaryColor,
                  width: 1.5,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              errorText: widget.urlError,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8A8A9A),
        ),
      ),
    );
  }

  /// Redondea coordenadas GPS a 6 decimales (~0.1m de precisión)
  /// para cumplir con la validación del backend (máx 10 dígitos total)
  LatLng _redondearLatLng(LatLng valor) {
    return LatLng(
      double.parse(valor.latitude.toStringAsFixed(6)),
      double.parse(valor.longitude.toStringAsFixed(6)),
    );
  }

  void _showMapPicker(BuildContext context) async {
    final bool hasCoordinates = _hasValidCoordinates(
      widget.latitud,
      widget.longitud,
    );

    final result = await showDialog<LatLng>(
      context: context,
      builder: (context) => MapPickerDialog(
        initialLat: hasCoordinates ? widget.latitud : null,
        initialLng: hasCoordinates ? widget.longitud : null,
        useCurrentLocationAsDefault: !hasCoordinates,
      ),
    );

    if (result != null) {
      widget.onLocationSelected?.call(_redondearLatLng(result));
    }
  }
}

/// Diálogo para seleccionar ubicación en mapa usando flutter_map (OpenStreetMap)
/// Incluye buscador de direcciones y botón para ubicación actual.
class MapPickerDialog extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final bool useCurrentLocationAsDefault;

  const MapPickerDialog({
    super.key,
    this.initialLat,
    this.initialLng,
    this.useCurrentLocationAsDefault = false,
  });

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  LatLng _selectedLocation = _defaultLocation;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Estado de búsqueda
  bool _isSearching = false;
  bool _isLoadingLocation = false;
  List<Map<String, dynamic>> _searchResults = [];

  // Coordenadas por defecto (Bogotá, Colombia)
  static const LatLng _defaultLocation = LatLng(4.7110, -74.0721);

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Inicializa la ubicación del mapa
  Future<void> _initializeLocation() async {
    final hasValidInitialCoordinates =
        widget.initialLat != null &&
        widget.initialLng != null &&
        widget.initialLat! >= -90 &&
        widget.initialLat! <= 90 &&
        widget.initialLng! >= -180 &&
        widget.initialLng! <= 180 &&
        !(widget.initialLat == 0.0 && widget.initialLng == 0.0);

    // Si hay coordenadas previas, usarlas
    if (hasValidInitialCoordinates) {
      _selectedLocation = LatLng(widget.initialLat!, widget.initialLng!);
      return;
    }

    // Si se solicita usar ubicación actual por defecto
    if (widget.useCurrentLocationAsDefault) {
      await _goToCurrentLocation();
    }
  }

  /// Obtiene la ubicación actual del dispositivo
  Future<void> _goToCurrentLocation() async {
    if (_isLoadingLocation) return;
    setState(() => _isLoadingLocation = true);

    try {
      if (kIsWeb) {
        final scheme = Uri.base.scheme.toLowerCase();
        final host = Uri.base.host.toLowerCase();
        final isLocalHost =
            host == 'localhost' || host == '127.0.0.1' || host == '::1';
        final isSecureContext = scheme == 'https' || isLocalHost;

        if (!isSecureContext) {
          setState(() => _isLoadingLocation = false);
          _showError('En web, la ubicación actual requiere HTTPS o localhost.');
          return;
        }
      }

      if (!kIsWeb) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          setState(() => _isLoadingLocation = false);
          _showError('Activa el servicio de ubicación del dispositivo.');
          return;
        }

        // Verificar permisos solo en móvil/desktop.
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            setState(() => _isLoadingLocation = false);
            _showError('Permiso de ubicación denegado.');
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          setState(() => _isLoadingLocation = false);
          _showError('Permiso bloqueado. Habilítalo en ajustes del sistema.');
          return;
        }
      } else {
        // En web no usamos requestPermission por inconsistencias del plugin:
        // requestPermission intenta obtener posición y puede devolver deniedForever
        // en errores de proveedor, aunque el permiso del sitio esté concedido.
        final webPermission = await Geolocator.checkPermission();
        if (webPermission == LocationPermission.deniedForever) {
          setState(() => _isLoadingLocation = false);
          _showError(
            'Permiso bloqueado. Habilítalo en el candado del navegador y recarga la página.',
          );
          return;
        }
      }

      final position = await _getCurrentPositionWithWatchdog();

      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = newLocation;
        _isLoadingLocation = false;
      });

      // Mover el mapa a la ubicación actual
      _mapController.move(newLocation, 16);

      // Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación actual obtenida'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      Position? lastKnownPosition;
      if (!kIsWeb) {
        try {
          lastKnownPosition = await Geolocator.getLastKnownPosition();
        } catch (_) {
          lastKnownPosition = null;
        }
      }

      if (lastKnownPosition != null) {
        final fallbackLocation = LatLng(
          lastKnownPosition.latitude,
          lastKnownPosition.longitude,
        );

        setState(() {
          _selectedLocation = fallbackLocation;
          _isLoadingLocation = false;
        });

        _mapController.move(fallbackLocation, 16);
        _showError(
          'No se pudo obtener la ubicación en tiempo real. Se usó la última ubicación conocida.',
        );
        return;
      }

      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
      _showError(_buildFriendlyLocationError(e));
    }
  }

  Future<Position> _getCurrentPositionWithWatchdog() {
    return Future.any<Position>([
      _getCurrentPositionForPlatform(),
      Future<Position>.delayed(
        const Duration(seconds: 25),
        () => throw TimeoutException('Hard timeout waiting for location'),
      ),
    ]);
  }

  Future<Position> _getCurrentPositionForPlatform() async {
    if (!kIsWeb) {
      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    }

    // Intento 1 (web): usar API nativa del navegador.
    try {
      final browserPoint = await getBrowserGeolocation(
        timeout: const Duration(seconds: 20),
        maximumAge: const Duration(minutes: 5),
        enableHighAccuracy: false,
      );

      return Position(
        longitude: browserPoint.longitude,
        latitude: browserPoint.latitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    } catch (browserError) {
      if (kDebugMode) {
        debugPrint('Browser geolocation fallo: $browserError');
      }
    }

    // Intento 2 (web): fallback a Geolocator con configuración tolerante.
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: WebSettings(
          accuracy: LocationAccuracy.medium,
          maximumAge: const Duration(minutes: 5),
          timeLimit: const Duration(seconds: 20),
        ),
      );
    } catch (firstError) {
      if (kDebugMode) {
        debugPrint('Geolocator web fallback 1 fallo: $firstError');
      }
    }

    // Intento 3 (web): más permisivo en tiempo/caché
    return Geolocator.getCurrentPosition(
      locationSettings: WebSettings(
        accuracy: LocationAccuracy.low,
        maximumAge: const Duration(minutes: 15),
        timeLimit: const Duration(seconds: 35),
      ),
    );
  }

  String _buildFriendlyLocationError(Object error) {
    final raw = error.toString().toLowerCase();

    if (raw.contains('permission') || raw.contains('denied')) {
      return kIsWeb
          ? 'Permiso de ubicación denegado. Revisa el candado del navegador y permite ubicación.'
          : 'Permiso de ubicación denegado. Revisa los ajustes del dispositivo.';
    }

    if (raw.contains('secure') || raw.contains('https')) {
      return 'La ubicación en web requiere HTTPS o localhost.';
    }

    if (raw.contains('timeout')) {
      return 'No se pudo obtener la ubicación a tiempo. Intenta nuevamente.';
    }

    if (raw.contains('position updates')) {
      return 'El navegador no pudo leer la ubicación en este momento. Intenta recargar la página y permitir ubicación.';
    }

    if (raw.contains('position unavailable')) {
      return 'La ubicación no está disponible ahora mismo. Verifica GPS/Wi-Fi y vuelve a intentar.';
    }

    if (raw.contains('listening for position updates')) {
      return 'No se pudo conectar con el proveedor de ubicación del navegador en este momento. Intenta nuevamente.';
    }

    return 'No se pudo obtener tu ubicación actual. Intenta nuevamente.';
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  /// Busca ubicaciones usando Nominatim (OpenStreetMap)
  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final encodedQuery = Uri.encodeComponent(query.trim());
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&limit=5&accept-language=es',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'PromomaniaApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);

        setState(() {
          _searchResults = results
              .map(
                (item) => {
                  'display_name': item['display_name'],
                  'lat': double.parse(item['lat']),
                  'lon': double.parse(item['lon']),
                },
              )
              .toList();
          _isSearching = false;
        });
      } else {
        throw Exception('Error en la búsqueda');
      }
    } catch (e) {
      setState(() => _isSearching = false);
      _showError('Error al buscar: $e');
    }
  }

  /// Selecciona un resultado de búsqueda
  void _selectSearchResult(Map<String, dynamic> result) {
    final lat = result['lat'] as double;
    final lon = result['lon'] as double;
    final location = LatLng(lat, lon);

    setState(() {
      _selectedLocation = location;
      _searchResults = [];
      _searchController.text = result['display_name'].toString().split(',')[0];
    });

    _mapController.move(location, 16);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF5733);

    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header con buscador
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.map, color: primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Buscar y seleccionar ubicación',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Campo de búsqueda
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar dirección, ciudad, lugar...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: primaryColor,
                        size: 20,
                      ),
                      suffixIcon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchResults = []);
                              },
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: primaryColor.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: primaryColor.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: _searchLocation,
                  ),

                  // Resultados de búsqueda
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      constraints: const BoxConstraints(maxHeight: 150),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.location_on,
                              color: primaryColor,
                              size: 20,
                            ),
                            title: Text(
                              result['display_name'].toString().split(',')[0],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              result['display_name'].toString(),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectSearchResult(result),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // Mapa con botón de ubicación actual
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedLocation,
                        initialZoom: 15,
                        onTap: (tapPosition, latLng) {
                          setState(() {
                            _selectedLocation = latLng;
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.promomania.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocation,
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.location_pin,
                                color: primaryColor,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Botón de ubicación actual
                  Positioned(
                    right: 12,
                    bottom: 80,
                    child: FloatingActionButton.small(
                      heroTag: 'locationButton',
                      onPressed: _isLoadingLocation
                          ? null
                          : _goToCurrentLocation,
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      elevation: 4,
                      child: _isLoadingLocation
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Info y botones
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ubicación seleccionada:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}, Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cancelButton = OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      );

                      final confirmButton = ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context, _selectedLocation);
                        },
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text(
                          'Confirmar ubicación',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );

                      final useVerticalButtons = constraints.maxWidth < 360;

                      if (useVerticalButtons) {
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: confirmButton,
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: cancelButton,
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: cancelButton),
                          const SizedBox(width: 10),
                          Expanded(flex: 2, child: confirmButton),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
