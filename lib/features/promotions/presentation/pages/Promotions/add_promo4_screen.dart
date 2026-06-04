import 'package:flutter/material.dart';

import '../../../../../Core/di/app_scope.dart';
import '../../../../../features/promotions/domain/entities/supermercado.dart';
import '../../widgets/modals/crear_supermercado_modal.dart';
import '../../widgets/selectors/location_selector.dart';
import '../../widgets/selectors/promotion_schedule_selector.dart';
import '../../widgets/selectors/supermarket_selector.dart';
import 'add_promo5_screen.dart';

/// Pantalla paso 4 del wizard de creación de promociones: tienda y ubicación.
///
/// Permite escoger un supermercado existente o crear uno nuevo, y seleccionar
/// si la promoción aplica en local físico, virtual o en ambos canales.
class AddPromotion4Screen extends StatefulWidget {
  final Map<String, dynamic> draftData;

  const AddPromotion4Screen({
    super.key,
    this.draftData = const <String, dynamic>{},
  });

  @override
  State<AddPromotion4Screen> createState() => _AddPromotion4ScreenState();
}

class _AddPromotion4ScreenState extends State<AddPromotion4Screen> {
  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);
  static const Color _lightBg = Color(0xFFF5F6FA);

  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _locationDescriptionController =
      TextEditingController();
  final TextEditingController _scheduleController = TextEditingController(
    text: 'Lun-Sáb 9-7pm',
  );

  int? _supermercadoId;
  Set<TipoUbicacion> _tiposUbicacion = {TipoUbicacion.fisica};
  double? _latitud;
  double? _longitud;
  bool _isLoading = false;

  final Map<String, String?> _errors = {};

  @override
  void initState() {
    super.initState();
    final draft = widget.draftData;

    _urlController.addListener(_onLocationFieldsChanged);
    _locationDescriptionController.addListener(_onLocationFieldsChanged);

    _urlController.text =
        (draft['url'] as String?) ?? (draft['website'] as String?) ?? '';
    _locationDescriptionController.text =
        (draft['locationDescription'] as String?) ??
        (draft['address'] as String?) ??
        '';
    _scheduleController.text =
        (draft['schedule'] as String?) ?? _scheduleController.text;
    _supermercadoId =
        _draftInt(draft['supermarketId']) ?? _draftInt(draft['idSupermercado']);
    _latitud = (draft['lat'] as num?)?.toDouble();
    _longitud = (draft['lng'] as num?)?.toDouble();

    final savedTypes = draft['locationTypes'];
    if (savedTypes is Iterable) {
      _tiposUbicacion = savedTypes
          .map((value) => value.toString())
          .map(_tipoUbicacionFromName)
          .whereType<TipoUbicacion>()
          .toSet();
    } else if ((draft['onlineOnly'] as bool?) == true) {
      _tiposUbicacion = {TipoUbicacion.virtual};
    }

    if (_tiposUbicacion.isEmpty) {
      _tiposUbicacion = {TipoUbicacion.fisica};
    }
  }

  @override
  void dispose() {
    _urlController.removeListener(_onLocationFieldsChanged);
    _locationDescriptionController.removeListener(_onLocationFieldsChanged);
    _urlController.dispose();
    _locationDescriptionController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  TipoUbicacion? _tipoUbicacionFromName(String value) {
    switch (value) {
      case 'fisica':
        return TipoUbicacion.fisica;
      case 'virtual':
        return TipoUbicacion.virtual;
      case 'ambas':
        return TipoUbicacion.ambas;
    }
    return null;
  }

  int? _draftInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  bool get _hasFisica =>
      _tiposUbicacion.contains(TipoUbicacion.fisica) ||
      _tiposUbicacion.contains(TipoUbicacion.ambas);

  bool get _hasVirtual =>
      _tiposUbicacion.contains(TipoUbicacion.virtual) ||
      _tiposUbicacion.contains(TipoUbicacion.ambas);

  bool get _hasCoordinates => _latitud != null && _longitud != null;

  bool get _hasValidUrl {
    final url = _urlController.text.trim();
    return url.isNotEmpty && url.startsWith('https://');
  }

  void _onLocationFieldsChanged() {
    if (!mounted) return;
    setState(() {
      if (_locationDescriptionController.text.trim().isNotEmpty) {
        _errors.remove('ubicacion_fisica');
      }
      if (_hasValidUrl) {
        _errors.remove('url');
      }
    });
  }

  bool get _canContinue {
    if (_supermercadoId == null) return false;
    if (_tiposUbicacion.isEmpty) return false;
    if (_hasFisica &&
        _locationDescriptionController.text.trim().isEmpty &&
        !_hasCoordinates) {
      return false;
    }
    if (_hasVirtual && _urlController.text.trim().isEmpty) return false;
    return true;
  }

  Supermercado? get _selectedSupermercado {
    if (_supermercadoId == null) return null;
    try {
      return promoService.supermercados.firstWhere(
        (store) => store.id == _supermercadoId,
      );
    } catch (_) {
      return null;
    }
  }

  void _validateForSubmit() {
    _errors.clear();

    if (_supermercadoId == null) {
      _errors['supermercado'] = 'Selecciona un supermercado';
    }

    if (_tiposUbicacion.isEmpty) {
      _errors['ubicacion'] = 'Selecciona al menos una opción de ubicación';
    }

    if (_hasFisica &&
        _locationDescriptionController.text.trim().isEmpty &&
        !_hasCoordinates) {
      _errors['ubicacion_fisica'] =
          'Describe la ubicación o selecciónala en el mapa';
    }

    if (_hasVirtual) {
      final url = _urlController.text.trim();
      if (url.isEmpty) {
        _errors['url'] = 'Ingresa la URL del sitio web';
      } else if (!url.startsWith('https://')) {
        _errors['url'] = 'La URL debe comenzar con https://';
      }
    }
  }

  double? _roundCoordinate(double? value) {
    if (value == null) return null;
    return double.parse(value.toStringAsFixed(6));
  }

  String _buildLocationLabel() {
    if (_hasFisica) {
      final text = _locationDescriptionController.text.trim();
      if (text.isNotEmpty) return text;

      final store = _selectedSupermercado;
      final parts = [
        store?.direccion,
        store?.ciudad,
      ].whereType<String>().where((part) => part.trim().isNotEmpty);

      final fallback = parts.join(', ');
      if (fallback.isNotEmpty) return fallback;
      if (_hasCoordinates) {
        return 'Lat: ${_latitud!.toStringAsFixed(6)}, Lng: ${_longitud!.toStringAsFixed(6)}';
      }
    }

    return 'Promoción virtual';
  }

  Future<void> _onNext() async {
    setState(_validateForSubmit);

    if (_errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa la tienda y la ubicación de la promoción'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final store = _selectedSupermercado;
    final locationTypes = _tiposUbicacion
        .map((type) => type.name)
        .where((name) => name != 'ambas')
        .toList();
    final scheduleData = _hasFisica
        ? PromotionScheduleUtils.parse(_scheduleController.text)
        : null;

    final nextDraft = <String, dynamic>{
      ...widget.draftData,
      'supermarketId': _supermercadoId,
      'idSupermercado': _supermercadoId,
      'storeName': store?.nombre ?? '',
      'website': _hasVirtual ? _urlController.text.trim() : '',
      'url': _hasVirtual ? _urlController.text.trim() : null,
      'locationDescription': _hasFisica
          ? _locationDescriptionController.text.trim()
          : '',
      'schedule': _hasFisica ? _scheduleController.text.trim() : '',
      'scheduleDays': scheduleData?.days ?? const <String>[],
      'scheduleStartTime': scheduleData?.startTime,
      'scheduleEndTime': scheduleData?.endTime,
      'onlineOnly': _hasVirtual && !_hasFisica,
      'locationTypes': locationTypes,
      'location': _buildLocationLabel(),
      'lat': _hasFisica ? _roundCoordinate(_latitud) : null,
      'lng': _hasFisica ? _roundCoordinate(_longitud) : null,
    };

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPromotion5Screen(
          draftData: nextDraft,
          promoTitle: nextDraft['title'] as String?,
          location: nextDraft['location'] as String?,
          imageFileName: nextDraft['imageFileName'] as String?,
        ),
      ),
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showCreateSupermarket([String? initialName]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CrearSupermercadoModal(
        initialName: initialName,
        onSupermercadoCreated: (supermercado) {
          _upsertSupermercado(supermercado);
          setState(() {
            _supermercadoId = supermercado.id;
            _errors.remove('supermercado');
          });
        },
      ),
    );
  }

  void _upsertSupermercado(Supermercado supermercado) {
    final index = promoService.supermercados.indexWhere(
      (item) => item.id == supermercado.id,
    );
    if (index == -1) {
      promoService.addSupermercado(supermercado);
    } else {
      promoService.updateSupermercado(supermercado);
    }
  }

  @override
  Widget build(BuildContext context) {
    final supermercados = promoService.supermercados;

    return Scaffold(
      backgroundColor: _lightBg,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tienda y ubicación',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '¿Dónde pueden encontrar esta promoción?',
                    style: TextStyle(fontSize: 13.5, color: Color(0xFF8A8FA8)),
                  ),
                  const SizedBox(height: 20),
                  SupermarketSelector(
                    supermercados: supermercados,
                    selectedId: _supermercadoId,
                    onChanged: (id) {
                      setState(() {
                        _supermercadoId = id;
                        _errors.remove('supermercado');
                      });
                    },
                    onCreateNew: _showCreateSupermarket,
                    errorText: _errors['supermercado'],
                  ),
                  const SizedBox(height: 18),
                  LocationSelector(
                    selectedTypes: _tiposUbicacion,
                    onTypesChanged: (types) {
                      setState(() {
                        _tiposUbicacion = types;
                        _errors.remove('ubicacion');
                        _errors.remove('ubicacion_fisica');
                        _errors.remove('url');
                      });
                    },
                    descripcionUbicacionController:
                        _locationDescriptionController,
                    latitud: _latitud,
                    longitud: _longitud,
                    onLocationSelected: (latLng) {
                      setState(() {
                        _latitud = latLng?.latitude;
                        _longitud = latLng?.longitude;
                        _errors.remove('ubicacion_fisica');
                      });
                    },
                    urlController: _urlController,
                    urlError: _errors['url'],
                    ubicacionError:
                        _errors['ubicacion'] ?? _errors['ubicacion_fisica'],
                  ),
                  if (_hasFisica) ...[
                    const SizedBox(height: 18),
                    PromotionScheduleSelector(
                      controller: _scheduleController,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F1F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF1A1F2E),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Nueva Promo',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1F2E),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Descuento %',
                  style: TextStyle(
                    color: _primary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStepper(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    final steps = [
      _WizardStep(icon: Icons.percent_rounded, label: 'Tipo', done: true),
      _WizardStep(
        icon: Icons.inventory_2_outlined,
        label: 'Producto',
        done: true,
      ),
      _WizardStep(
        icon: Icons.attach_money_rounded,
        label: 'Precio',
        done: true,
      ),
      _WizardStep(icon: Icons.store_outlined, label: 'Tienda', active: true),
      _WizardStep(icon: Icons.send_outlined, label: 'Publicar'),
    ];

    return Row(
      children: List.generate(steps.length, (i) {
        final s = steps[i];
        final isLast = i == steps.length - 1;

        Color bgColor;
        Color iconColor;
        Color labelColor;
        Color lineColor;

        if (s.done) {
          bgColor = _primary;
          iconColor = Colors.white;
          labelColor = _primary;
          lineColor = _primary;
        } else if (s.active) {
          bgColor = _darkBg;
          iconColor = Colors.white;
          labelColor = _darkBg;
          lineColor = const Color(0xFFE0E2EA);
        } else {
          bgColor = const Color(0xFFF0F1F5);
          iconColor = const Color(0xFFB0B5CC);
          labelColor = const Color(0xFFB0B5CC);
          lineColor = const Color(0xFFE0E2EA);
        }

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: s.done
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : Icon(s.icon, color: iconColor, size: 18),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      s.label,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: labelColor,
                        fontWeight: s.active || s.done
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 16,
                  height: 2,
                  color: lineColor,
                  margin: const EdgeInsets.only(bottom: 16),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _darkBg,
                      side: const BorderSide(
                        color: Color(0xFFE0E2EA),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_rounded, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Atrás',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _canContinue ? _onNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkBg,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _darkBg.withValues(alpha: 0.4),
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Siguiente',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Paso 4 de 5 — 80% completado',
            style: TextStyle(fontSize: 12, color: Color(0xFFB0B5CC)),
          ),
        ],
      ),
    );
  }
}

class _WizardStep {
  final IconData icon;
  final String label;
  final bool done;
  final bool active;

  const _WizardStep({
    required this.icon,
    required this.label,
    this.done = false,
    this.active = false,
  });
}
