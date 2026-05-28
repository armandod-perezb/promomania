import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../../../../../Core/di/app_scope.dart';
import '../../../../../features/promotions/domain/entities/promocion.dart';
import '../../../../../features/promotions/domain/entities/promocion_horario.dart';
import '../../../../../features/promotions/domain/entities/supermercado.dart';
import '../../../../../core/storage/image_storage_service.dart';
import '../../../../../Core/Routes/app_routes.dart';

/// Pantalla paso 5 (final) del wizard de creación de promociones: Vista previa
/// y publicación.
///
/// Responsabilidades:
/// - Mostrar una vista previa de la promoción usando los `draftData`
///   recibidos de los pasos anteriores.
/// - Resolver IDs de categoría/tipo/tienda si es necesario y generar un
///   código de promoción único.
/// - Procesar la imagen seleccionada (leer bytes y delegar a
///   `PromoService.savePromotionImage`).
/// - Crear la instancia de `Promocion`, añadirla al servicio y crear los
///   `PromocionHorario` asociados a partir del horario de la tienda.
/// - Mostrar diálogo de éxito al finalizar.

class AddPromotion5Screen extends StatefulWidget {
  // Datos opcionales que vienen de los pasos anteriores
  final String? promoTitle;
  final String? location;
  final String? imageFileName; // ✅ Cambiar a imageFileName
  final Map<String, dynamic> draftData;

  const AddPromotion5Screen({
    super.key,
    this.promoTitle,
    this.location,
    this.imageFileName, // ✅ Cambiar a imageFileName
    this.draftData = const <String, dynamic>{},
  });

  @override
  State<AddPromotion5Screen> createState() => _AddPromotion5ScreenState();
}

class _AddPromotion5ScreenState extends State<AddPromotion5Screen> {
  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);
  static const Color _lightBg = Color(0xFFF5F6FA);

  bool _isPublishing = false;

  String get _previewTitle {
    // Devuelve el título que se mostrará en la vista previa. Prioriza
    // los valores presentes en `draftData`, luego el parámetro `promoTitle`
    // y finalmente un texto por defecto.
    final draftTitle = (widget.draftData['title'] as String?)?.trim();
    if (draftTitle != null && draftTitle.isNotEmpty) {
      return draftTitle;
    }
    return (widget.promoTitle?.trim().isNotEmpty ?? false)
        ? widget.promoTitle!.trim()
        : 'Título de tu promo';
  }

  String get _previewLocation {
    // Devuelve la ubicación que aparecerá en la vista previa.
    final draftLocation = (widget.draftData['location'] as String?)?.trim();
    if (draftLocation != null && draftLocation.isNotEmpty) {
      return draftLocation;
    }
    return (widget.location?.trim().isNotEmpty ?? false)
        ? widget.location!.trim()
        : 'Ubicación';
  }

  String? get _previewImage {
    // Determina el nombre de archivo de la imagen para la vista previa.
    // - Primero busca en `draftData['imageFileName']` (resultado del paso 2).
    // - Si no existe, usa `widget.imageFileName`.
    // - Si ninguno existe, retorna null.
    final draftImage = (widget.draftData['imageFileName'] as String?)?.trim();
    if (draftImage != null && draftImage.isNotEmpty) {
      return draftImage;
    }

    // Buscar el parámetro del widget
    final image = widget.imageFileName?.trim();
    if (image != null && image.isNotEmpty) {
      return image;
    }

    return null;
  }

  String _normalizeCondition(String? condition) {
    final value = condition?.toLowerCase().trim() ?? '';
    if (value == 'usado') return 'usado';
    if (value == 'reacondicionado') return 'reacondicionado';
    return 'nuevo';
  }

  int _resolveCategoriaId(String? categoryName) {
    final categorias = promoService.getCategorias();
    if (categorias.isEmpty) return 1;

    final normalized = categoryName?.toLowerCase().trim();
    if (normalized == null || normalized.isEmpty) {
      return categorias.first.id;
    }

    for (final categoria in categorias) {
      if (categoria.nombre.toLowerCase().trim() == normalized) {
        return categoria.id;
      }
    }
    return categorias.first.id;
  }

  int _resolveTipoPromocionId(String? wizardType) {
    final tipos = promoService.getTiposPromocion();
    if (tipos.isEmpty) return 1;

    String expectedName;
    switch (wizardType) {
      case 'combo':
        expectedName = '2x1';
        break;
      case 'descuento':
        expectedName = 'descuento';
        break;
      default:
        expectedName = 'rebaja';
        break;
    }

    for (final tipo in tipos) {
      if (tipo.nombre.toLowerCase().contains(expectedName)) {
        return tipo.id;
      }
    }
    return tipos.first.id;
  }

  int _resolveSupermercadoId(Map<String, dynamic> draft) {
    // Resuelve un `idSupermercado` para la promoción:
    // - Si la promo es online o no se proporcionó nombre, devuelve el primer
    //   supermercado conocido (fallback).
    // - Si encuentra una tienda con el mismo nombre, devuelve su id.
    // - Si no existe, crea un nuevo `Supermercado` en `promoService` y
    //   devuelve el id recién generado.
    final allStores = promoService.getSupermercados();
    final onlineOnly = (draft['onlineOnly'] as bool?) ?? false;
    final storeName = (draft['storeName'] as String?)?.trim() ?? '';
    final address = (draft['address'] as String?)?.trim();
    final city = (draft['city'] as String?)?.trim();

    if (onlineOnly || storeName.isEmpty) {
      return allStores.isNotEmpty ? allStores.first.id : 1;
    }

    for (final store in allStores) {
      if (store.nombre.toLowerCase().trim() == storeName.toLowerCase()) {
        return store.id;
      }
    }

    final newId = (allStores.isEmpty ? 0 : allStores.last.id) + 1;
    final nuevoSupermercado = Supermercado(
      id: newId,
      nombre: storeName,
      direccion: address,
      ciudad: city,
      estado: 'activo',
    );
    promoService.addSupermercado(nuevoSupermercado);
    return newId;
  }

  String _buildPromoCode(String? requestedCode) {
    // Genera o valida un código único para la promoción.
    // - Si el usuario pidió un código y no existe, lo usa.
    // - En caso contrario, genera `PROMO###` buscando un candidato libre.
    final raw = requestedCode?.trim().toUpperCase() ?? '';
    if (raw.isNotEmpty && promoService.getPromocionByCodigo(raw) == null) {
      return raw;
    }

    var next = promoService.getPromociones().length + 1;
    while (true) {
      final candidate = 'PROMO${next.toString().padLeft(3, '0')}';
      if (promoService.getPromocionByCodigo(candidate) == null) {
        return candidate;
      }
      next++;
    }
  }

  int _nextHorarioId() {
    final horarios = promoService.getPromocionesHorarios();
    return (horarios.isEmpty ? 0 : horarios.last.id) + 1;
  }

  String _normalizeHourTo24h(String rawHour, String? period) {
    var hour = int.tryParse(rawHour.trim()) ?? 0;
    var suffix = period?.toLowerCase().trim() ?? '';

    if (suffix == 'pm' && hour < 12) hour += 12;
    if (suffix == 'am' && hour == 12) hour = 0;
    if (hour < 0) hour = 0;
    if (hour > 23) hour = 23;

    return '${hour.toString().padLeft(2, '0')}:00';
  }

  List<String> _extractDaysFromSchedule(String schedule) {
    final normalized = schedule.toLowerCase();
    final dayOrder = [
      'lunes',
      'martes',
      'miercoles',
      'jueves',
      'viernes',
      'sabado',
      'domingo',
    ];

    final dayAliases = <String, String>{
      'lun': 'lunes',
      'lunes': 'lunes',
      'mar': 'martes',
      'martes': 'martes',
      'mie': 'miercoles',
      'mié': 'miercoles',
      'mier': 'miercoles',
      'miércoles': 'miercoles',
      'miercoles': 'miercoles',
      'jue': 'jueves',
      'jueves': 'jueves',
      'vie': 'viernes',
      'viernes': 'viernes',
      'sab': 'sabado',
      'sáb': 'sabado',
      'sabado': 'sabado',
      'sábado': 'sabado',
      'dom': 'domingo',
      'domingo': 'domingo',
    };

    final range = RegExp(r'([a-záéíóú]{3,10})\s*-\s*([a-záéíóú]{3,10})');
    final match = range.firstMatch(normalized);
    if (match != null) {
      final startAlias = match.group(1) ?? '';
      final endAlias = match.group(2) ?? '';
      final startDay = dayAliases[startAlias];
      final endDay = dayAliases[endAlias];
      if (startDay != null && endDay != null) {
        final startIndex = dayOrder.indexOf(startDay);
        final endIndex = dayOrder.indexOf(endDay);
        if (startIndex != -1 && endIndex != -1 && startIndex <= endIndex) {
          return dayOrder.sublist(startIndex, endIndex + 1);
        }
      }
    }

    final explicitDays = <String>[];
    for (final entry in dayAliases.entries) {
      if (normalized.contains(entry.key) &&
          !explicitDays.contains(entry.value)) {
        explicitDays.add(entry.value);
      }
    }

    if (explicitDays.isNotEmpty) return explicitDays;
    return ['lunes', 'martes', 'miercoles', 'jueves', 'viernes'];
  }

  List<String> _extractTimeRange(String schedule) {
    final normalized = schedule.toLowerCase();
    final timeRange = RegExp(
      r'(\d{1,2})(?::\d{2})?\s*(am|pm)?\s*-\s*(\d{1,2})(?::\d{2})?\s*(am|pm)?',
    );
    final match = timeRange.firstMatch(normalized);
    if (match == null) {
      return ['09:00', '18:00'];
    }

    final start = _normalizeHourTo24h(match.group(1) ?? '9', match.group(2));
    final end = _normalizeHourTo24h(match.group(3) ?? '18', match.group(4));
    return [start, end];
  }

  void _savePromocionHorarios(Promocion promo, Map<String, dynamic> draft) {
    // Crea entradas `PromocionHorario` a partir del campo `schedule` del
    // draft. Si la promo es solo online, no crea horarios.
    final onlineOnly = (draft['onlineOnly'] as bool?) ?? false;
    if (onlineOnly) return;

    final schedule = (draft['schedule'] as String?)?.trim() ?? '';
    final days = _extractDaysFromSchedule(schedule);
    final timeRange = _extractTimeRange(schedule);
    var nextId = _nextHorarioId();

    for (final day in days) {
      promoService.addPromocionHorario(
        PromocionHorario(
          id: nextId,
          diaSemana: day,
          horaInicio: timeRange[0],
          horaFin: timeRange[1],
          codigoPromocion: promo.codigo,
        ),
      );
      nextId++;
    }
  }

  void _publishPromo() async {
    final draft = widget.draftData;
    final title = (draft['title'] as String?)?.trim() ?? '';

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Faltan datos del título de la promoción'),
        ),
      );
      return;
    }

    setState(() => _isPublishing = true);

    // Generar código de promoción primero
    final promoCode = _buildPromoCode(draft['code'] as String?);

    // Guardar la imagen si existe
    String? finalImageName = _previewImage;
    bool isLocalImage = false;

    if (_previewImage != null && !_previewImage!.startsWith('http')) {
      // Es una imagen local (guardada previamente), procesarla con el servicio
      try {
        // Leer los bytes de la imagen guardada
        final imageStorageService = ImageStorageService();
        final imageBytes = await imageStorageService.readImageBytes(
          _previewImage!,
        );

        if (imageBytes != null) {
          final savedName = await promoService.savePromotionImage(
            promoCode,
            imageBytes,
          );
          if (savedName != null) {
            finalImageName = savedName;
            isLocalImage = true;
            print('✅ Imagen procesada para promoción $promoCode: $savedName');
          }
        }
      } catch (e) {
        print('❌ Error procesando imagen para promoción: $e');
      }
    }

    final promo = Promocion(
      codigo: promoCode,
      titulo: title,
      descripcion: (draft['description'] as String?)?.trim(),
      precio: (draft['price'] as num?)?.toDouble() ?? 0,
      descuento: draft['discount'] as int?,
      condicionProducto: _normalizeCondition(draft['condition'] as String?),
      ubicacion: (draft['location'] as String?)?.trim(),
      url: (draft['website'] as String?)?.trim(),
      foto: finalImageName,
      fotoEsLocal: isLocalImage,
      tipoVigencia: (draft['vigenciaType'] == 'permanente')
          ? 'permanente'
          : 'por_fecha',
      fechaInicio: draft['fechaInicio'] as String?,
      fechaFin: draft['fechaFin'] as String?,
      estado: 'pendiente',
      vistas: 0,
      idUsuario: sessionManager.usuarioActual?.id ?? 1,
      idSupermercado: _resolveSupermercadoId(draft),
      idCategoria: _resolveCategoriaId(draft['category'] as String?),
      idTipoPromocion: _resolveTipoPromocionId(draft['promoType'] as String?),
    );

    promoService.addPromocion(promo);
    _savePromocionHorarios(promo, draft);

    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isPublishing = false);

    if (mounted) {
      // Navegar a pantalla de éxito
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: _primary, size: 34),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Promo enviada!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1F2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Está en revisión y será publicada pronto.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: Color(0xFF8A8FA8)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.userHome,
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Ir al inicio',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  // Encabezado
                  const Text(
                    'Vista previa',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Así verán tu promo los usuarios de PromoMap',
                    style: TextStyle(fontSize: 13.5, color: Color(0xFF8A8FA8)),
                  ),
                  const SizedBox(height: 20),

                  // Card de vista previa
                  _buildPreviewCard(),
                  const SizedBox(height: 20),

                  // Estimados de impacto
                  _buildImpactCard(),
                  const SizedBox(height: 16),

                  // Banner de revisión
                  _buildReviewBanner(),
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

  // ── Top bar ──────────────────────────────────────────────────────────────────

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
      _WizardStep(icon: Icons.store_outlined, label: 'Tienda', done: true),
      _WizardStep(icon: Icons.send_outlined, label: 'Publicar', active: true),
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

  // ── Preview card ─────────────────────────────────────────────────────────────

  Widget _buildPreviewCard() {
    // Crear un widget de vista previa personalizado que no depende del servicio
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen con manejo directo
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                // Imagen de fondo
                FutureBuilder<Uint8List?>(
                  future: _getPreviewImageBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.grey[300]!, Colors.grey[400]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasData && snapshot.data != null) {
                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      );
                    }

                    return _buildPlaceholder();
                  },
                ),

                // Overlay con gradiente para el texto
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _previewTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_previewLocation != 'Ubicación') ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _previewLocation,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> _getPreviewImageBytes() async {
    if (_previewImage == null) return null;

    try {
      if (_previewImage!.startsWith('http')) {
        // Es URL, descargarla
        final response = await http.get(Uri.parse(_previewImage!));
        if (response.statusCode == 200) {
          return response.bodyBytes;
        }
      } else {
        // Es archivo local, leerlo directamente
        final imageStorageService = ImageStorageService();
        return await imageStorageService.readImageBytes(_previewImage!);
      }
    } catch (e) {
      print('❌ Error obteniendo imagen de vista previa: $e');
    }

    return null;
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[300]!, Colors.grey[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Sin imagen',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ── Estimados de impacto ─────────────────────────────────────────────────────

  Widget _buildImpactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _darkBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ESTIMADOS DE IMPACTO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF8A8FA8),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _ImpactStat(
                icon: Icons.visibility_outlined,
                iconColor: Color(0xFF60A5FA),
                value: '12.4K',
                label: 'Vistas/día',
              ),
              _ImpactDivider(),
              _ImpactStat(
                icon: Icons.people_outline_rounded,
                iconColor: Color(0xFF34D399),
                value: '2,800',
                label: 'Alcance',
              ),
              _ImpactDivider(),
              _ImpactStat(
                icon: Icons.trending_up_rounded,
                iconColor: Color(0xFFFBBF24),
                value: '8.3%',
                label: 'CTR est.',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Banner de revisión ───────────────────────────────────────────────────────

  Widget _buildReviewBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE082), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revisión en 15 minutos',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92651A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tu promo será revisada por nuestro equipo antes de aparecer en el mapa. Recibirás una notificación al ser aprobada.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF92651A),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar ───────────────────────────────────────────────────────────────

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
              // Atrás
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
              // Publicar
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isPublishing ? null : _publishPromo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _primary.withOpacity(0.5),
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isPublishing
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
                              Icon(Icons.bolt_rounded, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Publicar Promo',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Paso 5 de 5 — 100% completado',
            style: TextStyle(fontSize: 12, color: Color(0xFFB0B5CC)),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _ImpactStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _ImpactStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8A8FA8), fontSize: 11.5),
        ),
      ],
    );
  }
}

class _ImpactDivider extends StatelessWidget {
  const _ImpactDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: Colors.white.withOpacity(0.08),
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
