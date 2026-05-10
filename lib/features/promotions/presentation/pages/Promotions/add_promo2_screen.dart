import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../main.dart';
import 'add_promo3_screen.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/storage/image_storage_service.dart';

/// Pantalla paso 2 del wizard de creación de promociones.
///
/// Responsabilidades principales:
/// - Recoger datos del producto: título, descripción, código, fotos.
/// - Permitir seleccionar hasta 5 imágenes (la primera es la principal).
/// - Al avanzar, guarda temporalmente la primera imagen en disco y añade
///   su nombre al `draftData` que se pasa al siguiente paso.
///
/// Nota: los datos parciales se transmiten entre pantallas mediante el
/// mapa `draftData` para componer la promoción al final del wizard.

class AddPromotion2Screen extends StatefulWidget {
  final String promoType;
  final Map<String, dynamic> draftData;

  const AddPromotion2Screen({
    super.key,
    this.promoType = 'descuento',
    this.draftData = const <String, dynamic>{},
  });

  @override
  State<AddPromotion2Screen> createState() => _AddPromotion2ScreenState();
}

class _AddPromotion2ScreenState extends State<AddPromotion2Screen> {
  static const Color _primary = Color(0xFFFF4D2E);
  static const Color _darkBg = Color(0xFF1A1F2E);
  static const Color _lightBg = Color(0xFFF5F6FA);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  // Fotos: máximo 5, primera es principal
  final List<Uint8List?> _photos = List.filled(5, null);
  final List<String?> _photoPaths = List.filled(5, null);

  final ImagePicker _picker = ImagePicker();

  String _condition = 'Nuevo';
  String _category = 'Electrónica';
  bool _isLoading = false;

  late final List<String> _categories;
  static const List<String> _fallbackCategories = [
    'Electrónica',
    'Alimentos',
    'Ropa',
  ];

  final List<_ConditionOption> _conditions = const [
    _ConditionOption(
      id: 'Nuevo',
      label: 'Nuevo',
      subtitle: 'Sin uso, en empaque original',
    ),
    _ConditionOption(
      id: 'Usado',
      label: 'Usado',
      subtitle: 'Buen estado, con desgaste normal',
    ),
    _ConditionOption(
      id: 'Reacondicionado',
      label: 'Reacondicionado',
      subtitle: 'Restaurado a condición funcional',
    ),
  ];

  Future<void> _pickImage(int index) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      _photos[index] = bytes;
      _photoPaths[index] = image.path;
    });
  }

  /// Abre el selector de imágenes y guarda los bytes en memoria temporal.
  ///
  /// - `index` indica la posición (0 = principal). Se almacenan los bytes
  ///   en `_photos` y la ruta original en `_photoPaths` como referencia.
  /// - La imagen todavía no se sube al servidor; se guarda localmente y
  ///   más adelante se copiará a la ubicación gestionada por
  ///   `ImageStorageService` cuando se confirme el siguiente paso.

  @override
  void initState() {
    super.initState();

    final categoriasServicio = promoService
        .getCategorias()
        .map((c) => c.nombre)
        .where((n) => n.trim().isNotEmpty)
        .toList();
    _categories = categoriasServicio.isNotEmpty
        ? categoriasServicio
        : _fallbackCategories;

    _category = _categories.first;

    final draft = widget.draftData;
    _titleController.text = (draft['title'] as String?) ?? '';
    _descController.text = (draft['description'] as String?) ?? '';
    _codeController.text = (draft['code'] as String?) ?? '';

    final draftCondition = draft['condition'] as String?;
    if (draftCondition != null &&
        _conditions.any((c) => c.id == draftCondition)) {
      _condition = draftCondition;
    }

    final draftCategory = draft['category'] as String?;
    if (draftCategory != null && _categories.contains(draftCategory)) {
      _category = draftCategory;
    }
  }

  /// Inicializa el estado de la pantalla usando los valores parciales
  /// disponibles en `widget.draftData` (si el usuario viene del paso 1).
  ///
  /// Además, carga las categorías desde `promoService` y utiliza una lista
  /// de respaldo si el servicio no tiene categorías registradas.

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _titleController.text.isNotEmpty && _descController.text.isNotEmpty;

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
                    'Detalles del producto',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Información completa para que tus clientes confíen',
                    style: TextStyle(fontSize: 13.5, color: Color(0xFF8A8FA8)),
                  ),
                  const SizedBox(height: 24),

                  // Fotos
                  _buildPhotosSection(),
                  const SizedBox(height: 24),

                  // Título
                  _buildLabeledField(
                    label: 'Título de la promo',
                    required: true,
                    child: _buildTextField(
                      controller: _titleController,
                      hint: 'Ej: 50% OFF Zapatillas Nike Air Max',
                      maxLength: 80,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Descripción
                  _buildLabeledField(
                    label: 'Descripción completa',
                    required: true,
                    child: _buildTextField(
                      controller: _descController,
                      hint:
                          'Describe qué incluye, condiciones especiales, cómo ap...',
                      maxLength: 300,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Código
                  _buildLabeledField(
                    label: 'Código',
                    required: false,
                    child: _buildTextField(
                      controller: _codeController,
                      hint: 'ABC-001',
                      prefixIcon: Icons.barcode_reader,
                      maxLength: 30,
                      showCounter: false,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Condición
                  _buildConditionSelector(),
                  const SizedBox(height: 20),

                  // Categoría
                  _buildCategoryDropdown(),
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
        active: true,
      ),
      _WizardStep(icon: Icons.attach_money_rounded, label: 'Precio'),
      _WizardStep(icon: Icons.store_outlined, label: 'Tienda'),
      _WizardStep(icon: Icons.send_outlined, label: 'Publicar'),
    ];

    return Row(
      children: List.generate(steps.length, (i) {
        final s = steps[i];
        final isLast = i == steps.length - 1;

        Color bgColor;
        Color iconColor;
        Color labelColor;

        if (s.done) {
          bgColor = _primary;
          iconColor = Colors.white;
          labelColor = _primary;
        } else if (s.active) {
          bgColor = Colors.white;
          iconColor = _primary;
          labelColor = _primary;
        } else {
          bgColor = const Color(0xFFF0F1F5);
          iconColor = const Color(0xFFB0B5CC);
          labelColor = const Color(0xFFB0B5CC);
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
                        border: s.active
                            ? Border.all(color: _primary, width: 2)
                            : null,
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
                  height: 1.5,
                  color: const Color(0xFFE0E2EA),
                  margin: const EdgeInsets.only(bottom: 16),
                ),
            ],
          ),
        );
      }),
    );
  }

  // ── Fotos ────────────────────────────────────────────────────────────────────

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Fotos del producto',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1F2E),
              ),
            ),
            SizedBox(width: 4),
            Text('*', style: TextStyle(color: Color(0xFFFF4D2E), fontSize: 14)),
            SizedBox(width: 8),
            Text(
              '— Hasta 5 imágenes',
              style: TextStyle(fontSize: 12, color: Color(0xFFB0B5CC)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1,
          children: List.generate(5, (i) => _buildPhotoSlot(i)),
        ),
      ],
    );
  }

  Widget _buildPhotoSlot(int index) {
    final isMain = index == 0;
    final hasPhoto = _photos[index] != null;

    return GestureDetector(
      onTap: () => _pickImage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: hasPhoto
              ? Colors.grey.shade200
              : isMain
              ? _primary.withOpacity(0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isMain && !hasPhoto ? _primary : const Color(0xFFE0E2EA),
            width: isMain && !hasPhoto ? 2 : 1.5,
          ),
        ),
        child: hasPhoto
            ? ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.memory(_photos[index]!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isMain ? Icons.camera_alt_outlined : Icons.add_rounded,
                    color: isMain ? _primary : const Color(0xFFB0B5CC),
                    size: isMain ? 28 : 22,
                  ),
                  if (isMain) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Foto principal',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFFF4D2E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  // ── Campos ───────────────────────────────────────────────────────────────────

  Widget _buildLabeledField({
    required String label,
    required bool required,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1F2E),
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Color(0xFFFF4D2E), fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLength = 100,
    int maxLines = 1,
    bool showCounter = true,
    IconData? prefixIcon,
  }) {
    return Stack(
      children: [
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1F2E)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFCDD0DB),
              fontSize: 13.5,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: const Color(0xFFB0B5CC), size: 20)
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.fromLTRB(
              16,
              14,
              showCounter ? 52 : 16,
              14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE8EAF0),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE8EAF0),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _primary, width: 1.8),
            ),
          ),
        ),
        if (showCounter)
          Positioned(
            right: 12,
            bottom: 10,
            child: Text(
              '${controller.text.length}/$maxLength',
              style: const TextStyle(fontSize: 10.5, color: Color(0xFFB0B5CC)),
            ),
          ),
      ],
    );
  }

  // ── Condición ────────────────────────────────────────────────────────────────

  Widget _buildConditionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Condición del producto',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F2E),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _conditions.map((c) {
            final isSelected = _condition == c.id;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _condition = c.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(
                    right: c.id == _conditions.last.id ? 0 : 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? _darkBg : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? _darkBg : const Color(0xFFE8EAF0),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        c.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1A1F2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isSelected
                              ? Colors.white.withOpacity(0.7)
                              : const Color(0xFF8A8FA8),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Categoría ────────────────────────────────────────────────────────────────

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categoría de la promo',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F2E),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8EAF0), width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _category,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_up_rounded,
                color: Color(0xFF8A8FA8),
              ),
              style: const TextStyle(fontSize: 14.5, color: Color(0xFF1A1F2E)),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
          ),
        ),
      ],
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
              // Botón Atrás
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
              // Botón Siguiente
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _canContinue ? _onNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkBg,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _darkBg.withOpacity(0.4),
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
            'Paso 2 de 5 — 40% completado',
            style: TextStyle(fontSize: 12, color: Color(0xFFB0B5CC)),
          ),
        ],
      ),
    );
  }

  Future<void> _onNext() async {
    setState(() => _isLoading = true);

    try {
      // Guardar la primera imagen si existe
      String? savedImageName;
      if (_photos.first != null) {
        final imageStorageService = ImageStorageService();
        savedImageName = await imageStorageService.saveImageFromBytes(
          _photos.first!,
        );
        print('Imagen guardada: $savedImageName');
      }

      final nextDraft = <String, dynamic>{
        ...widget.draftData,
        'promoType': widget.promoType,
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'code': _codeController.text.trim(),
        'condition': _condition,
        'category': _category,
        'imageFileName': savedImageName, // ✅ Nombre del archivo guardado
        'imagePath': _photoPaths.first, // Ruta temporal como respaldo
      };

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddPromotion3Screen(draftData: nextDraft),
        ),
      );
    } catch (e) {
      print('Error guardando imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar la imagen')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Acción al pulsar "Siguiente":
  /// 1. Si hay una foto principal seleccionada, la guarda usando
  ///    `ImageStorageService` y obtiene el nombre del archivo.
  /// 2. Combina los datos recogidos en este paso con `widget.draftData`
  ///    y crea `nextDraft` que se pasa al siguiente paso (`AddPromotion3Screen`).
  ///
  /// Observaciones:
  /// - `imageFileName` contiene el nombre del archivo almacenado (metadato).
  /// - `imagePath` guarda la ruta temporal del selector como respaldo.
  /// - El guardado de la imagen es local; la promoción final podrá procesar
  ///   la imagen (p. ej. renombrarla o subirla) cuando se publique.
}

// ── Modelos auxiliares ────────────────────────────────────────────────────────

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

class _ConditionOption {
  final String id;
  final String label;
  final String subtitle;

  const _ConditionOption({
    required this.id,
    required this.label,
    required this.subtitle,
  });
}
