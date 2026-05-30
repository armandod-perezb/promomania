import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF5733);
    final textDark = const Color(0xFF1A1A2E);
    final textGray = const Color(0xFF8A8A9A);

    final showFisica = widget.selectedTypes.contains(TipoUbicacion.fisica) ||
        widget.selectedTypes.contains(TipoUbicacion.ambas);
    final showVirtual = widget.selectedTypes.contains(TipoUbicacion.virtual) ||
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
        if (showVirtual) ...[
          _buildVirtualSection(primaryColor),
        ],
      ],
    );
  }

  Widget _buildTipoUbicacionSelector(Color primaryColor, Color textDark) {
    return Column(
      children: TipoUbicacion.values.map((tipo) {
        final isSelected = widget.selectedTypes.contains(tipo) ||
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
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
                      color: isSelected ? primaryColor : const Color(0xFFCDD0DB),
                      width: 2,
                    ),
                    color: isSelected ? primaryColor : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        )
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
              hintText: 'Ej: Frente al centro comercial, al lado de la farmacia',
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
          if (widget.onLocationSelected != null)
            _buildMapButton(primaryColor),

          // Mostrar coordenadas seleccionadas
          if (widget.latitud != null && widget.longitud != null)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.green,
                    size: 18,
                  ),
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
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapButton(Color primaryColor) {
    return GestureDetector(
      onTap: () => _showMapPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: primaryColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              color: primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              widget.latitud != null
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
    final result = await showDialog<LatLng>(
      context: context,
      builder: (context) => MapPickerDialog(
        initialLat: widget.latitud,
        initialLng: widget.longitud,
      ),
    );

    if (result != null) {
      widget.onLocationSelected?.call(_redondearLatLng(result));
    }
  }
}

/// Diálogo para seleccionar ubicación en mapa usando flutter_map (OpenStreetMap)
class MapPickerDialog extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPickerDialog({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  late LatLng _selectedLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    // Ubicación por defecto: Bogotá, Colombia
    _selectedLocation = LatLng(
      widget.initialLat ?? 4.7110,
      widget.initialLng ?? -74.0721,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF5733);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.map, color: primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seleccionar ubicación',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Toca el mapa para seleccionar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Mapa
            Expanded(
              child: ClipRRect(
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
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
            ),

            // Info y botones
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Coordenadas seleccionadas:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}\nLng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context, _selectedLocation);
                          },
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text(
                            'Confirmar ubicación',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
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
