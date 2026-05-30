import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:app/Core/di/app_scope.dart';
import 'package:app/features/catalog/domain/entities/categoria.dart';
import 'package:app/features/catalog/domain/entities/tipo_promocion.dart';
import 'package:app/features/promotions/domain/entities/promocion.dart';
import 'package:app/features/promotions/domain/entities/supermercado.dart';
import 'package:app/features/promotions/infrastructure/services/promo_service.dart';
import '../selectors/category_selector.dart';
import '../selectors/location_selector.dart';
import '../selectors/supermarket_selector.dart';
import '../selectors/tipo_promocion_selector.dart';
import 'crear_supermercado_modal.dart';

/// Modal unificado para crear promociones con todos los campos mejorados.
///
/// Incluye:
/// - Selector de tipo de promoción con campos dinámicos
/// - Selector de categoría (cargado desde BD)
/// - Selector de supermercado con búsqueda y opción de crear nuevo
/// - Ubicación física/virtual/ambos con mapa
/// - Validaciones completas
class CrearPromoModal extends StatefulWidget {
  const CrearPromoModal({super.key});

  @override
  State<CrearPromoModal> createState() => _CrearPromoModalState();
}

class _CrearPromoModalState extends State<CrearPromoModal> {
  // Form key para validaciones
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _codigoController = TextEditingController();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _descuentoController = TextEditingController();
  final _descripcionTipoController = TextEditingController();
  final _descripcionUbicacionController = TextEditingController();
  final _urlController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();

  // Estados
  String? _tipoPromocionId;
  int? _categoriaId;
  int? _supermercadoId;
  Set<TipoUbicacion> _tiposUbicacion = {};
  double? _latitud;
  double? _longitud;
  String _condicionProducto = 'nuevo';
  String _tipoVigencia = 'por_fecha';

  // Errores de validación
  final Map<String, String?> _errors = {};
  bool _isLoading = false;

  static const Color primaryOrange = Color(0xFFFF5733);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGray = Color(0xFF8A8A9A);

  @override
  void dispose() {
    _codigoController.dispose();
    _tituloController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _descuentoController.dispose();
    _descripcionTipoController.dispose();
    _descripcionUbicacionController.dispose();
    _urlController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }

  // ============================================================================
  // VALIDACIONES
  // ============================================================================

  bool _validarFormulario() {
    setState(() => _errors.clear());

    // Validar tipo de promoción
    if (_tipoPromocionId == null) {
      _errors['tipo_promocion'] = 'Selecciona un tipo de promoción';
    }

    // Validar campos según tipo
    final tipo = TipoPromocionEnum.fromId(_tipoPromocionId);
    if (tipo?.requiereDescuento == true) {
      if (_descuentoController.text.trim().isEmpty) {
        _errors['descuento'] = 'Ingresa el porcentaje de descuento';
      } else {
        final descuento = int.tryParse(_descuentoController.text);
        if (descuento == null || descuento <= 0 || descuento > 100) {
          _errors['descuento'] = 'Ingresa un valor entre 1 y 100';
        }
      }
    }

    if (tipo?.requiereDescripcion == true) {
      if (_descripcionTipoController.text.trim().isEmpty) {
        _errors['descripcion_tipo'] = 'Describe el tipo de promoción';
      }
    }

    // Validar categoría
    if (_categoriaId == null) {
      _errors['categoria'] = 'Selecciona una categoría';
    }

    // Validar supermercado
    if (_supermercadoId == null) {
      _errors['supermercado'] = 'Selecciona un supermercado';
    }

    // Validar ubicación
    if (_tiposUbicacion.isEmpty) {
      _errors['ubicacion'] = 'Selecciona al menos una opción de ubicación';
    } else {
      final tieneFisica = _tiposUbicacion.contains(TipoUbicacion.fisica) ||
          _tiposUbicacion.contains(TipoUbicacion.ambas);
      final tieneVirtual = _tiposUbicacion.contains(TipoUbicacion.virtual) ||
          _tiposUbicacion.contains(TipoUbicacion.ambas);

      if (tieneFisica) {
        if (_descripcionUbicacionController.text.trim().isEmpty &&
            (_latitud == null || _longitud == null)) {
          _errors['ubicacion_fisica'] =
              'Ingresa una descripción o selecciona una ubicación en el mapa';
        }
      }

      if (tieneVirtual) {
        final url = _urlController.text.trim();
        if (url.isEmpty) {
          _errors['url'] = 'Ingresa la URL del sitio web';
        } else if (!url.startsWith('https://')) {
          _errors['url'] = 'La URL debe comenzar con https://';
        }
      }
    }

    // Validar campos básicos
    if (_codigoController.text.trim().isEmpty) {
      _errors['codigo'] = 'El código es obligatorio';
    }

    if (_tituloController.text.trim().isEmpty) {
      _errors['titulo'] = 'El título es obligatorio';
    }

    if (_precioController.text.trim().isEmpty) {
      _errors['precio'] = 'El precio es obligatorio';
    } else {
      final precio = double.tryParse(_precioController.text);
      if (precio == null || precio < 0) {
        _errors['precio'] = 'Ingresa un precio válido';
      }
    }

    // Validar fechas si aplica
    if (_tipoVigencia == 'por_fecha') {
      if (_fechaInicioController.text.isEmpty) {
        _errors['fecha_inicio'] = 'Ingresa la fecha de inicio';
      }
      if (_fechaFinController.text.isEmpty) {
        _errors['fecha_fin'] = 'Ingresa la fecha de fin';
      }
    }

    setState(() {});
    return _errors.isEmpty;
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  /// Redondea coordenadas GPS a 6 decimales (~0.1m de precisión)
  /// para cumplir con la validación del backend (máx 10 dígitos total)
  double? _redondearCoordenada(double? valor) {
    if (valor == null) return null;
    return double.parse(valor.toStringAsFixed(6));
  }

  // ============================================================================
  // CREAR PROMOCIÓN
  // ============================================================================

  Future<void> _crearPromocion() async {
    if (!_validarFormulario()) {
      // Scroll al primer error
      _scrollToFirstError();
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Usar promoService singleton desde app_scope

      // Calcular ID de tipo de promoción basado en el enum
      int idTipoPromocion = 1;
      final tipoEnum = TipoPromocionEnum.fromId(_tipoPromocionId);
      if (tipoEnum != null) {
        // Buscar el tipo en la lista del servicio o usar el índice + 1
        final tipos = promoService.tiposPromocion;
        final tipoEncontrado = tipos.firstWhere(
          (t) => t.nombre.toLowerCase().contains(
                tipoEnum.displayName.toLowerCase(),
              ),
          orElse: () => tipos.isNotEmpty
              ? tipos.first
              : TipoPromocion(
                  id: 1,
                  nombre: tipoEnum.displayName,
                  estado: 'activo',
                ),
        );
        idTipoPromocion = tipoEncontrado.id;
      }

      final nuevaPromo = Promocion(
        codigo: _codigoController.text.trim(),
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        precio: double.tryParse(_precioController.text) ?? 0.0,
        descuento: tipoEnum?.requiereDescuento == true
            ? int.tryParse(_descuentoController.text)
            : null,
        condicionProducto: _condicionProducto,
        ubicacion: _descripcionUbicacionController.text.trim().isEmpty
            ? null
            : _descripcionUbicacionController.text.trim(),
        url: _urlController.text.trim().isEmpty
            ? null
            : _urlController.text.trim(),
        foto: null,
        fotoEsLocal: false,
        tipoVigencia: _tipoVigencia,
        fechaInicio: _tipoVigencia == 'por_fecha'
            ? _fechaInicioController.text
            : null,
        fechaFin:
            _tipoVigencia == 'por_fecha' ? _fechaFinController.text : null,
        estado: 'pendiente',
        vistas: 0,
        idUsuario: sessionManager.usuarioActual?.id ?? 1,
        idSupermercado: _supermercadoId!,
        idCategoria: _categoriaId!,
        idTipoPromocion: idTipoPromocion,
        lat: _redondearCoordenada(_latitud),
        lng: _redondearCoordenada(_longitud),
      );

      await promotionsController.createPromotion(nuevaPromo);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Promoción creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear promoción: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scrollToFirstError() {
    // Mostrar mensaje general
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor completa todos los campos obligatorios'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // ============================================================================
  // UI HELPERS
  // ============================================================================

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: primaryOrange),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      controller.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  void _mostrarCrearSupermercado() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CrearSupermercadoModal(
        onSupermercadoCreated: (supermercado) {
          // Agregar al servicio (async sin await)
          promoService.addSupermercado(supermercado);

          // Seleccionar el nuevo supermercado
          setState(() {
            _supermercadoId = supermercado.id;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usar promoService singleton desde app_scope
    final categorias = promoService.categorias;
    final supermercados = promoService.supermercados;
    final tiposPromocion = promoService.tiposPromocion;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_offer,
                    color: primaryOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Crear Promoción',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      Text(
                        'Completa todos los campos obligatorios',
                        style: TextStyle(
                          fontSize: 13,
                          color: textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: textGray,
                ),
              ],
            ),
          ),

          // Formulario
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // ==== SECCIÓN 1: INFORMACIÓN BÁSICA ====
                  _buildSectionTitle('1. Información Básica'),
                  const SizedBox(height: 16),

                  // Código
                  _buildLabel('CÓDIGO *'),
                  _buildTextField(
                    controller: _codigoController,
                    hint: 'Ej: PROMO2024',
                    errorText: _errors['codigo'],
                  ),
                  const SizedBox(height: 14),

                  // Título
                  _buildLabel('TÍTULO *'),
                  _buildTextField(
                    controller: _tituloController,
                    hint: 'Ej: Descuento especial en frutas',
                    errorText: _errors['titulo'],
                  ),
                  const SizedBox(height: 14),

                  // Descripción
                  _buildLabel('DESCRIPCIÓN'),
                  _buildTextField(
                    controller: _descripcionController,
                    hint: 'Detalles de la promoción...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  // ==== SECCIÓN 2: TIPO DE PROMOCIÓN ====
                  _buildSectionTitle('2. Tipo de Promoción'),
                  const SizedBox(height: 16),

                  TipoPromocionSelector(
                    selectedId: _tipoPromocionId,
                    onChanged: (id) => setState(() => _tipoPromocionId = id),
                    tiposFromDb: tiposPromocion,
                    errorText: _errors['tipo_promocion'],
                  ),
                  const SizedBox(height: 16),

                  // Campos dinámicos según tipo
                  TipoPromocionDynamicFields(
                    tipoPromocionId: _tipoPromocionId,
                    descuentoController: _descuentoController,
                    descripcionTipoController: _descripcionTipoController,
                    errorText: _errors['descuento'] ?? _errors['descripcion_tipo'],
                  ),

                  const SizedBox(height: 20),

                  // ==== SECCIÓN 3: CATEGORÍA Y SUPERMERCADO ====
                  _buildSectionTitle('3. Categoría y Supermercado'),
                  const SizedBox(height: 16),

                  // Categoría
                  CategorySelectorWithSearch(
                    categorias: categorias,
                    selectedId: _categoriaId,
                    onChanged: (id) => setState(() => _categoriaId = id),
                    errorText: _errors['categoria'],
                  ),
                  const SizedBox(height: 16),

                  // Supermercado
                  SupermarketSelector(
                    supermercados: supermercados,
                    selectedId: _supermercadoId,
                    onChanged: (id) => setState(() => _supermercadoId = id),
                    onCreateNew: _mostrarCrearSupermercado,
                    errorText: _errors['supermercado'],
                  ),
                  const SizedBox(height: 20),

                  // ==== SECCIÓN 4: UBICACIÓN ====
                  _buildSectionTitle('4. Ubicación'),
                  const SizedBox(height: 16),

                  LocationSelector(
                    selectedTypes: _tiposUbicacion,
                    onTypesChanged: (types) =>
                        setState(() => _tiposUbicacion = types),
                    descripcionUbicacionController:
                        _descripcionUbicacionController,
                    latitud: _latitud,
                    longitud: _longitud,
                    onLocationSelected: (latLng) {
                      setState(() {
                        _latitud = latLng?.latitude;
                        _longitud = latLng?.longitude;
                      });
                    },
                    urlController: _urlController,
                    urlError: _errors['url'],
                    ubicacionError: _errors['ubicacion'] ??
                        _errors['ubicacion_fisica'],
                  ),
                  const SizedBox(height: 20),

                  // ==== SECCIÓN 5: PRECIO Y VIGENCIA ====
                  _buildSectionTitle('5. Precio y Vigencia'),
                  const SizedBox(height: 16),

                  // Precio
                  _buildLabel('PRECIO *'),
                  _buildTextField(
                    controller: _precioController,
                    hint: 'Ej: 19.99',
                    keyboard: TextInputType.number,
                    prefix: '\$',
                    errorText: _errors['precio'],
                  ),
                  const SizedBox(height: 14),

                  // Condición del producto
                  _buildLabel('CONDICIÓN DEL PRODUCTO'),
                  _buildChipSelector(
                    options: ['nuevo', 'usado', 'reacondicionado'],
                    labels: ['Nuevo', 'Usado', 'Reacondicionado'],
                    selected: _condicionProducto,
                    onSelect: (v) => setState(() => _condicionProducto = v),
                  ),
                  const SizedBox(height: 14),

                  // Tipo de vigencia
                  _buildLabel('TIPO DE VIGENCIA'),
                  _buildChipSelector(
                    options: ['por_fecha', 'permanente'],
                    labels: ['Por fecha', 'Permanente'],
                    selected: _tipoVigencia,
                    onSelect: (v) => setState(() => _tipoVigencia = v),
                  ),
                  const SizedBox(height: 14),

                  // Fechas
                  if (_tipoVigencia == 'por_fecha') ...[
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('FECHA INICIO *'),
                              _buildTextField(
                                controller: _fechaInicioController,
                                hint: 'YYYY-MM-DD',
                                readOnly: true,
                                onTap: () => _pickDate(_fechaInicioController),
                                suffixIcon: Icons.calendar_today_outlined,
                                errorText: _errors['fecha_inicio'],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('FECHA FIN *'),
                              _buildTextField(
                                controller: _fechaFinController,
                                hint: 'YYYY-MM-DD',
                                readOnly: true,
                                onTap: () => _pickDate(_fechaFinController),
                                suffixIcon: Icons.calendar_today_outlined,
                                errorText: _errors['fecha_fin'],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Botones inferiores
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textGray,
                      side: const BorderSide(color: Color(0xFFEEEEF2)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _crearPromocion,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.add_outlined, size: 20),
                    label: Text(
                      _isLoading ? 'Creando...' : 'Crear Promoción',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
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

  // ============================================================================
  // WIDGETS AUXILIARES
  // ============================================================================

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: primaryOrange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: primaryOrange,
            width: 3,
          ),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: primaryOrange,
        ),
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
          fontWeight: FontWeight.w700,
          color: textGray,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    String? prefix,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboard,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.withOpacity(0.5),
              fontSize: 13,
            ),
            prefixText: prefix,
            prefixStyle: const TextStyle(
              color: textDark,
              fontWeight: FontWeight.w500,
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: textGray, size: 18)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : const Color(0xFFEEEEF2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : const Color(0xFFEEEEF2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : primaryOrange,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 13,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChipSelector({
    required List<String> options,
    required List<String> labels,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Wrap(
      spacing: 8,
      children: List.generate(options.length, (i) {
        final isSelected = options[i] == selected;
        return GestureDetector(
          onTap: () => onSelect(options[i]),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primaryOrange : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? primaryOrange : const Color(0xFFE0E0E8),
                width: 1.5,
              ),
            ),
            child: Text(
              labels[i],
              style: TextStyle(
                color: isSelected ? Colors.white : textGray,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }
}
