import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show LatLng;

import '../../../../../Core/Routes/app_routes.dart';
import '../../../../../Core/config/map_config.dart';
import '../../../../../Core/di/app_scope.dart';
import '../../../../../Core/services/manual_location_service.dart';
import '../../../../../Core/storage/image_storage_service.dart';
import '../../../../../features/promotions/domain/entities/promocion.dart';
import '../../../../../features/promotions/domain/entities/supermercado.dart';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen>
    with TickerProviderStateMixin {
  static const Color _primary = Color(0xFFFF4D2E);
  static const LatLng _defaultCenter = LatLng(4.7110, -74.0721);
  static const double _nearbyRadiusKm = 5.0;

  int _selectedTab = 0;
  double _zoomLevel = 14;
  String? _selectedPromoCode;
  bool _isLoadingMapData = false;
  bool _isRefreshingLocation = false;
  String? _locationWarning;

  LatLng _userLocation = _defaultCenter;
  List<Promocion> _allActivePromotions = const [];
  List<_MapPromo> _promos = const [];

  final MapController _mapController = MapController();

  late final AnimationController _cardController;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardFade;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cardSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
        );
    _cardFade = CurvedAnimation(parent: _cardController, curve: Curves.easeOut);
    _cardController.forward();

    _loadMapData();
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _loadMapData() async {
    if (mounted) {
      setState(() => _isLoadingMapData = true);
    }

    final locationResult = await _resolveUserLocation();
    final activePromos = await _loadActivePromotions();
    final nearbyPromos = _buildNearbyPromos(
      activePromotions: activePromos,
      userLocation: locationResult.location,
    );

    if (!mounted) return;

    setState(() {
      _isLoadingMapData = false;
      _locationWarning = locationResult.warning;
      _userLocation = locationResult.location;
      _allActivePromotions = activePromos;
      _promos = nearbyPromos;
      _selectedPromoCode = nearbyPromos.isEmpty
          ? null
          : nearbyPromos.first.code;
    });

    _mapController.move(_userLocation, _zoomLevel);
    if (_locationWarning != null) {
      _showInfoSnackBar(_locationWarning!);
    }
  }

  Future<List<Promocion>> _loadActivePromotions() async {
    try {
      final remote = await promotionsController.getActivePromotions();
      if (remote.isNotEmpty) return remote;
    } catch (_) {
      // Fallback a caché local.
    }
    return promotionsController.getActivePromotionsSync();
  }

  Future<void> _refreshWithCurrentLocation() async {
    if (_isRefreshingLocation) return;

    setState(() => _isRefreshingLocation = true);
    final locationResult = await _resolveUserLocation();
    final nearbyPromos = _buildNearbyPromos(
      activePromotions: _allActivePromotions,
      userLocation: locationResult.location,
    );

    if (!mounted) return;

    setState(() {
      _isRefreshingLocation = false;
      _locationWarning = locationResult.warning;
      _userLocation = locationResult.location;
      _promos = nearbyPromos;
      _selectedPromoCode = nearbyPromos.isEmpty
          ? null
          : nearbyPromos.first.code;
    });

    _mapController.move(_userLocation, _zoomLevel);
    if (_locationWarning != null) {
      _showInfoSnackBar(_locationWarning!);
    }
  }

  Future<_LocationResult> _resolveUserLocation() async {
    try {
      if (kIsWeb) {
        final scheme = Uri.base.scheme.toLowerCase();
        final host = Uri.base.host.toLowerCase();
        final isLocalHost =
            host == 'localhost' || host == '127.0.0.1' || host == '::1';
        final isSecureContext = scheme == 'https' || isLocalHost;
        if (!isSecureContext) {
          return const _LocationResult(
            location: _defaultCenter,
            warning: 'En web, la ubicación actual requiere HTTPS o localhost.',
          );
        }
      } else {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return const _LocationResult(
            location: _defaultCenter,
            warning: 'Activa el servicio de ubicación del dispositivo.',
          );
        }
      }

      final permissionResult = await _ensureLocationPermission();
      if (permissionResult != null) {
        return _LocationResult(
          location: _defaultCenter,
          warning: permissionResult,
        );
      }

      if (!kIsWeb) {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          _getCurrentPositionForPlatform()
              .then((position) {
                if (!mounted) return;
                final preciseLocation = LatLng(
                  position.latitude,
                  position.longitude,
                );
                final nearbyPromos = _buildNearbyPromos(
                  activePromotions: _allActivePromotions,
                  userLocation: preciseLocation,
                );
                setState(() {
                  _userLocation = preciseLocation;
                  _promos = nearbyPromos;
                  _selectedPromoCode = nearbyPromos.isEmpty
                      ? null
                      : nearbyPromos.first.code;
                });
                _mapController.move(preciseLocation, _zoomLevel);
              })
              .catchError((_) {});

          return _LocationResult(
            location: LatLng(lastKnown.latitude, lastKnown.longitude),
          );
        }
      }

      final position = await _getCurrentPositionForPlatform();
      return _LocationResult(
        location: LatLng(position.latitude, position.longitude),
      );
    } catch (_) {
      if (!kIsWeb) {
        try {
          final lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown != null) {
            return _LocationResult(
              location: LatLng(lastKnown.latitude, lastKnown.longitude),
              warning:
                  'No se pudo obtener la ubicación en tiempo real. Se usó la última ubicación conocida.',
            );
          }
        } catch (_) {
          // Ignorar y usar fallback por defecto.
        }
      }

      // Intentar usar ubicación manual guardada (especialmente útil en web)
      final manualLocation = await ManualLocationService.getSavedLocation();
      if (manualLocation != null) {
        final address = await ManualLocationService.getSavedAddress();
        return _LocationResult(
          location: manualLocation,
          warning: address != null
              ? 'Usando ubicación manual: $address'
              : 'Usando ubicación manual configurada.',
        );
      }

      return const _LocationResult(
        location: _defaultCenter,
        warning:
            'No se pudo obtener tu ubicación actual. Se muestra una ubicación por defecto.',
      );
    }
  }

  Future<String?> _ensureLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (kIsWeb) {
        return 'Permiso de ubicación denegado en el navegador.';
      }
      final requested = await Geolocator.requestPermission();
      if (requested == LocationPermission.denied) {
        return 'Permiso de ubicación denegado.';
      }
      if (requested == LocationPermission.deniedForever) {
        return 'Permiso bloqueado. Habilítalo en ajustes del sistema.';
      }
      return null;
    }
    if (permission == LocationPermission.deniedForever) {
      return kIsWeb
          ? 'Permiso bloqueado en navegador. Habilítalo y recarga la página.'
          : 'Permiso bloqueado. Habilítalo en ajustes del sistema.';
    }
    return null;
  }

  Future<Position> _getCurrentPositionForPlatform() {
    if (!kIsWeb) {
      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    }
    return Geolocator.getCurrentPosition(
      locationSettings: WebSettings(
        accuracy: LocationAccuracy.medium,
        maximumAge: const Duration(minutes: 5),
        timeLimit: const Duration(seconds: 20),
      ),
    );
  }

  List<_MapPromo> _buildNearbyPromos({
    required List<Promocion> activePromotions,
    required LatLng userLocation,
  }) {
    final promos = <_MapPromo>[];
    for (final promo in activePromotions) {
      if (!_hasValidCoordinates(promo.lat, promo.lng)) continue;

      final distanceMeters = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        promo.lat!,
        promo.lng!,
      );
      final distanceKm = distanceMeters / 1000.0;
      if (distanceKm > _nearbyRadiusKm) continue;

      final supermercado = promotionsController.getSupermercadoSync(
        promo.idSupermercado,
      );
      final categoria = catalogController.getCategoriaByIdSync(
        promo.idCategoria,
      );
      final categoriaStyle = catalogController.getCategoriaStyleSync(
        promo.idCategoria,
      );
      final categoryColor =
          _parseHexColor(categoriaStyle['color']) ??
          _fallbackCategoryColor(promo.idCategoria);
      final discountLabel = _buildDiscountLabel(promo.descuento);

      promos.add(
        _MapPromo(
          code: promo.codigo,
          label: discountLabel,
          color: categoryColor,
          latLng: LatLng(promo.lat!, promo.lng!),
          detail: _PromoDetail(
            code: promo.codigo,
            category: categoria?.nombre ?? 'General',
            categoryColor: categoryColor,
            discount: discountLabel,
            title: promo.titulo,
            store: _resolveStoreLabel(supermercado, promo),
            emoji: categoriaStyle['emoji'] ?? '📦',
            image: promo.foto,
          ),
          distanceKm: distanceKm,
        ),
      );
    }

    promos.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return promos;
  }

  bool _hasValidCoordinates(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (lat.isNaN || lng.isNaN || lat.isInfinite || lng.isInfinite) {
      return false;
    }
    final inRange = lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
    if (!inRange) return false;
    return !(lat == 0.0 && lng == 0.0);
  }

  String _buildDiscountLabel(int? discount) {
    if (discount == null || discount <= 0) return 'Oferta';
    return '-$discount%';
  }

  String _resolveStoreLabel(Supermercado? supermercado, Promocion promo) {
    if (supermercado?.nombre != null &&
        supermercado!.nombre.trim().isNotEmpty) {
      return supermercado.nombre;
    }
    if (promo.ubicacion != null && promo.ubicacion!.trim().isNotEmpty) {
      return promo.ubicacion!;
    }
    return 'Sin ubicación';
  }

  Color _fallbackCategoryColor(int categoryId) {
    const colors = [
      Color(0xFFFF4D2E),
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFE91E8C),
      Color(0xFFF59E0B),
    ];
    return colors[categoryId % colors.length];
  }

  Color? _parseHexColor(String? value) {
    if (value == null) return null;
    final hex = value.replaceAll('#', '').trim();
    if (hex.length != 6 && hex.length != 8) return null;
    final normalized = hex.length == 6 ? 'FF$hex' : hex;
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) return null;
    return Color(parsed);
  }

  void _showInfoSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  _MapPromo? get _selectedPromoData {
    if (_promos.isEmpty) return null;
    final selectedCode = _selectedPromoCode;
    if (selectedCode == null) return _promos.first;
    for (final promo in _promos) {
      if (promo.code == selectedCode) return promo;
    }
    return _promos.first;
  }

  void _selectPromo(String code) {
    setState(() => _selectedPromoCode = code);
    _cardController.forward(from: 0);
    HapticFeedback.lightImpact();
  }

  void _openSelectedPromotionDetails() {
    final selected = _selectedPromoData;
    if (selected == null) return;
    Navigator.pushNamed(
      context,
      AppRoutes.promotionDetails,
      arguments: selected.code,
    );
  }

  void _navigateToCreatePromotion() {
    debugPrint('>>> BOTON + PRESIONADO - navegando a crear promocion...');
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, AppRoutes.addPromotions);
  }

  /// Muestra diálogo para configurar ubicación manual
  void _showManualLocationDialog() async {
    final savedLocation = await ManualLocationService.getSavedLocation();
    final savedAddress = await ManualLocationService.getSavedAddress();

    final latController = TextEditingController(
      text: savedLocation?.latitude.toString() ?? '',
    );
    final lngController = TextEditingController(
      text: savedLocation?.longitude.toString() ?? '',
    );
    final addressController = TextEditingController(text: savedAddress ?? '');

    if (!mounted) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit_location_alt, color: _primary),
            const SizedBox(width: 8),
            const Text('Configurar ubicación manual'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ingresa las coordenadas de tu ubicación:',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: latController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Latitud',
                  hintText: 'Ej: 4.7110',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lngController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Longitud',
                  hintText: 'Ej: -74.0721',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la ubicación (opcional)',
                  hintText: 'Ej: Mi casa, Oficina',
                  prefixIcon: Icon(Icons.label_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta ubicación se usará cuando no se pueda obtener la ubicación actual del dispositivo.',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await ManualLocationService.clearLocation();
              if (context.mounted) {
                Navigator.pop(context);
                _showInfoSnackBar('Ubicación manual eliminada');
              }
            },
            child: const Text('Borrar', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              final lat = double.tryParse(
                latController.text.replaceAll(',', '.'),
              );
              final lng = double.tryParse(
                lngController.text.replaceAll(',', '.'),
              );

              if (lat == null || lng == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingresa coordenadas válidas')),
                );
                return;
              }

              if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coordenadas fuera de rango')),
                );
                return;
              }

              Navigator.pop(context, {
                'location': LatLng(lat, lng),
                'address': addressController.text,
              });
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    latController.dispose();
    lngController.dispose();
    addressController.dispose();

    if (result != null && result['location'] != null) {
      final address = result['address'] as String?;
      await ManualLocationService.saveLocation(
        result['location'] as LatLng,
        address: address?.isNotEmpty == true ? address : null,
      );

      // Recargar con la nueva ubicación
      await _refreshWithCurrentLocation();

      if (mounted) {
        _showInfoSnackBar('Ubicación manual guardada y aplicada');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            _buildOsmMap(),
            _buildSearchBar(),
            _buildZoomBadge(),
            _buildMapControls(),
            _buildBottomPromoSheet(),
            _buildFloatingAddButton(),
            if (_isLoadingMapData)
              Positioned(
                top: MediaQuery.of(context).padding.top + 126,
                left: 16,
                right: 16,
                child: const LinearProgressIndicator(minHeight: 3),
              ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildOsmMap() {
    return Positioned.fill(
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _userLocation,
          initialZoom: _zoomLevel,
          minZoom: 5,
          maxZoom: 19,
        ),
        children: [
          TileLayer(
            urlTemplate: AppMapConfig.tileUrlTemplate,
            subdomains: AppMapConfig.tileSubdomains,
            userAgentPackageName: AppMapConfig.userAgentPackageName,
          ),
          MarkerLayer(markers: _buildPromoMarkers()),
          MarkerLayer(markers: [_buildUserPin()]),
        ],
      ),
    );
  }

  List<Marker> _buildPromoMarkers() {
    return _promos.map((promo) {
      final isSelected = _selectedPromoCode == promo.code;
      return Marker(
        point: promo.latLng,
        width: 86,
        height: 56,
        child: GestureDetector(
          onTap: () {
            _selectPromo(promo.code);
            _mapController.move(promo.latLng, _zoomLevel);
          },
          child: AnimatedScale(
            scale: isSelected ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: _PromoMarker(
              label: promo.label,
              color: promo.color,
              isSelected: isSelected,
            ),
          ),
        ),
      );
    }).toList();
  }

  Marker _buildUserPin() {
    return Marker(
      point: _userLocation,
      width: 22,
      height: 22,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.search_rounded,
                    color: Color(0xFFB0B5CC),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _promos.isEmpty
                          ? 'No hay promos en ${_nearbyRadiusKm.toInt()} km'
                          : '${_promos.length} promociones cerca de ti',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.layers_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomBadge() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 72,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'Zoom: ${((_zoomLevel - 5) / 14 * 100).clamp(0, 100).toInt()}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1F2E),
          ),
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).padding.top + 72,
      child: Column(
        children: [
          _mapControlBtn(
            icon: _isRefreshingLocation ? Icons.sync : Icons.near_me_outlined,
            onTap: () async {
              HapticFeedback.lightImpact();
              await _refreshWithCurrentLocation();
            },
          ),
          const SizedBox(height: 8),
          _mapControlBtn(
            icon: Icons.add_rounded,
            onTap: () {
              final nextZoom = (_zoomLevel + 1).clamp(5, 19).toDouble();
              setState(() => _zoomLevel = nextZoom);
              _mapController.move(_mapController.camera.center, _zoomLevel);
            },
          ),
          const SizedBox(height: 8),
          _mapControlBtn(
            icon: Icons.remove_rounded,
            onTap: () {
              final nextZoom = (_zoomLevel - 1).clamp(5, 19).toDouble();
              setState(() => _zoomLevel = nextZoom);
              _mapController.move(_mapController.camera.center, _zoomLevel);
            },
          ),
          // Botón para configurar ubicación manual (visible siempre pero especialmente útil en web)
          const SizedBox(height: 8),
          _mapControlBtn(
            icon: Icons.edit_location_alt_outlined,
            onTap: () => _showManualLocationDialog(),
          ),
        ],
      ),
    );
  }

  Widget _mapControlBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF1A1F2E), size: 20),
      ),
    );
  }

  Widget _buildBottomPromoSheet() {
    final selected = _selectedPromoData;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _cardSlide,
        child: FadeTransition(
          opacity: _cardFade,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Card de promoción
              Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 24,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: selected == null
                    ? _buildEmptyBottomSheet()
                    : _buildSelectedPromoBottomSheet(selected),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingAddButton() {
    return Positioned(
      right: 15,
      bottom: 175 + MediaQuery.of(context).padding.bottom,
      child: GestureDetector(
        onTap: _navigateToCreatePromotion,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: _primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildEmptyBottomSheet() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF1F8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.location_off_outlined,
              color: Color(0xFF8A8FA8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sin promociones cercanas',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1F2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No encontramos promociones dentro de ${_nearbyRadiusKm.toInt()} km.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF8A8FA8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPromoBottomSheet(_MapPromo selected) {
    final promo = selected.detail;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _buildSelectedPromoImage(promo),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _categoryBadge(promo.category, promo.categoryColor),
                    const SizedBox(width: 8),
                    _discountBadge(promo.discount),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  promo.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1F2E),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFB0B5CC),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${promo.store} · ${selected.distanceKm.toStringAsFixed(2)} km',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF8A8FA8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _openSelectedPromotionDetails,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPromoImage(_PromoDetail promo) {
    final dataUrlBytes = ImageStorageService.dataUrlToBytes(promo.image);
    final cachedBytes = promotionsController.getCachedImageBytes(promo.code);
    final imageBytes = cachedBytes ?? dataUrlBytes;
    final imageUrl = promo.image?.trim();
    final canUseNetworkImage =
        imageUrl != null &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) &&
        !imageUrl.toLowerCase().contains('via.placeholder.com');

    Widget child;
    if (imageBytes != null) {
      child = Image.memory(imageBytes, fit: BoxFit.cover);
    } else if (canUseNetworkImage) {
      child = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildSelectedPromoImageFallback(promo),
      );
    } else {
      child = _buildSelectedPromoImageFallback(promo);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(width: 68, height: 68, child: child),
    );
  }

  Widget _buildSelectedPromoImageFallback(_PromoDetail promo) {
    return Container(
      color: promo.categoryColor.withValues(alpha: 0.1),
      child: Center(
        child: Text(promo.emoji, style: const TextStyle(fontSize: 30)),
      ),
    );
  }

  Widget _categoryBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _discountBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final tabs = [
      _NavTab(icon: Icons.map_rounded, label: 'Inicio'),
      _NavTab(icon: Icons.explore_outlined, label: 'Explorar'),
      _NavTab(icon: Icons.favorite_border_rounded, label: 'Favoritos'),
      _NavTab(icon: Icons.person_outline_rounded, label: 'Perfil'),
    ];
    final routesByTab = [
      AppRoutes.userHome,
      AppRoutes.explore,
      AppRoutes.userFavorites,
      AppRoutes.userProfile,
    ];

    return Container(
      height: 68 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (i) {
          final isActive = _selectedTab == i;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();

              if (_selectedTab != i) {
                setState(() => _selectedTab = i);
              }

              final route = routesByTab[i];
              final currentRoute = ModalRoute.of(context)?.settings.name;
              if (route != currentRoute) {
                Navigator.pushNamed(context, route);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 72,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? _primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      tabs[i].icon,
                      color: isActive ? _primary : const Color(0xFFB0B5CC),
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tabs[i].label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? _primary : const Color(0xFFB0B5CC),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LocationResult {
  final LatLng location;
  final String? warning;

  const _LocationResult({required this.location, this.warning});
}

class _MapPromo {
  final String code;
  final String label;
  final Color color;
  final LatLng latLng;
  final _PromoDetail detail;
  final double distanceKm;

  const _MapPromo({
    required this.code,
    required this.label,
    required this.color,
    required this.latLng,
    required this.detail,
    required this.distanceKm,
  });
}

class _PromoDetail {
  final String code;
  final String category;
  final Color categoryColor;
  final String discount;
  final String title;
  final String store;
  final String emoji;
  final String? image;

  const _PromoDetail({
    required this.code,
    required this.category,
    required this.categoryColor,
    required this.discount,
    required this.title,
    required this.store,
    required this.emoji,
    this.image,
  });
}

class _NavTab {
  final IconData icon;
  final String label;
  const _NavTab({required this.icon, required this.label});
}

class _PromoMarker extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;

  const _PromoMarker({
    required this.label,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: isSelected ? 0 : 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isSelected ? 0.4 : 0.2),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(10, 6),
          painter: _MarkerTipPainter(
            color: isSelected ? color : Colors.white,
            borderColor: color,
          ),
        ),
      ],
    );
  }
}

class _MarkerTipPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  const _MarkerTipPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MarkerTipPainter old) => false;
}
