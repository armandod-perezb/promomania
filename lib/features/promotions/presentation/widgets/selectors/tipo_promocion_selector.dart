import 'package:flutter/material.dart';
import 'package:app/features/catalog/domain/entities/tipo_promocion.dart';

/// Tipos de promoción soportados con sus configuraciones
enum TipoPromocionEnum {
  descuento,
  dosxuno,
  envioGratis,
  otro;

  String get displayName {
    switch (this) {
      case TipoPromocionEnum.descuento:
        return 'Descuento';
      case TipoPromocionEnum.dosxuno:
        return '2x1';
      case TipoPromocionEnum.envioGratis:
        return 'Envío Gratis';
      case TipoPromocionEnum.otro:
        return 'Otro';
    }
  }

  String get id {
    switch (this) {
      case TipoPromocionEnum.descuento:
        return 'descuento';
      case TipoPromocionEnum.dosxuno:
        return '2x1';
      case TipoPromocionEnum.envioGratis:
        return 'envio_gratis';
      case TipoPromocionEnum.otro:
        return 'otro';
    }
  }

  IconData get icon {
    switch (this) {
      case TipoPromocionEnum.descuento:
        return Icons.percent_rounded;
      case TipoPromocionEnum.dosxuno:
        return Icons.layers_rounded;
      case TipoPromocionEnum.envioGratis:
        return Icons.local_shipping_outlined;
      case TipoPromocionEnum.otro:
        return Icons.auto_awesome_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TipoPromocionEnum.descuento:
        return const Color(0xFFFF4D2E);
      case TipoPromocionEnum.dosxuno:
        return const Color(0xFFFF9800);
      case TipoPromocionEnum.envioGratis:
        return const Color(0xFF4CAF50);
      case TipoPromocionEnum.otro:
        return const Color(0xFF9C27B0);
    }
  }

  /// Indica si este tipo requiere campo de descuento
  bool get requiereDescuento => this == TipoPromocionEnum.descuento;

  /// Indica si este tipo requiere descripción personalizada
  bool get requiereDescripcion => this == TipoPromocionEnum.otro;

  /// Indica si este tipo muestra precio
  bool get muestraPrecio =>
      this == TipoPromocionEnum.descuento ||
      this == TipoPromocionEnum.dosxuno ||
      this == TipoPromocionEnum.otro;

  static TipoPromocionEnum? fromId(String? id) {
    if (id == null) return null;
    try {
      return TipoPromocionEnum.values.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  static TipoPromocionEnum fromTipoPromocion(TipoPromocion tipo) {
    final nombre = tipo.nombre.toLowerCase();
    if (nombre.contains('descuento')) return TipoPromocionEnum.descuento;
    if (nombre.contains('2x1') || nombre.contains('combo')) {
      return TipoPromocionEnum.dosxuno;
    }
    if (nombre.contains('envio') || nombre.contains('domicilio')) {
      return TipoPromocionEnum.envioGratis;
    }
    return TipoPromocionEnum.otro;
  }
}

/// Selector de tipo de promoción con tarjetas visuales
class TipoPromocionSelector extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final List<TipoPromocion>? tiposFromDb;
  final String? label;
  final bool isRequired;
  final String? errorText;

  const TipoPromocionSelector({
    super.key,
    required this.selectedId,
    required this.onChanged,
    this.tiposFromDb,
    this.label = 'Tipo de Promoción',
    this.isRequired = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF5733);
    final textDark = const Color(0xFF1A1A2E);
    final textGray = const Color(0xFF8A8A9A);

    // Usar tipos de la base de datos si están disponibles, sino usar los estáticos
    final tipos = tiposFromDb ?? [];
    final tiposEnum = TipoPromocionEnum.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(
                  label!.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textGray,
                    letterSpacing: 0.5,
                  ),
                ),
                if (isRequired)
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
        ...tiposEnum.map((tipo) {
          final isSelected = selectedId == tipo.id;
          return _buildTipoCard(
            tipo: tipo,
            isSelected: isSelected,
            onTap: () => onChanged(tipo.id),
          );
        }).toList(),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 11),
            ),
          ),
      ],
    );
  }

  Widget _buildTipoCard({
    required TipoPromocionEnum tipo,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? tipo.color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? tipo.color.withOpacity(0.12)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icono/Color block
            Container(
              width: 64,
              height: 72,
              decoration: BoxDecoration(
                color: tipo.color.withOpacity(0.12),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Icon(tipo.icon, color: tipo.color, size: 28),
            ),
            const SizedBox(width: 14),
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tipo.displayName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _getSubtitle(tipo),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A8FA8),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            // Indicador de selección
            Container(
              margin: const EdgeInsets.only(right: 14),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? tipo.color : const Color(0xFFCDD0DB),
                  width: 2,
                ),
                color: isSelected ? tipo.color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _getSubtitle(TipoPromocionEnum tipo) {
    switch (tipo) {
      case TipoPromocionEnum.descuento:
        return 'Precio reducido con porcentaje visible';
      case TipoPromocionEnum.dosxuno:
        return 'Lleva 2 y paga 1 o paquetes especiales';
      case TipoPromocionEnum.envioGratis:
        return 'Sin costo de domicilio o entrega';
      case TipoPromocionEnum.otro:
        return 'Describe el tipo de promoción personalizado';
    }
  }
}

/// Campos dinámicos según el tipo de promoción seleccionado
class TipoPromocionDynamicFields extends StatelessWidget {
  final String? tipoPromocionId;
  final TextEditingController? descuentoController;
  final TextEditingController? descripcionTipoController;
  final String? errorText;

  const TipoPromocionDynamicFields({
    super.key,
    required this.tipoPromocionId,
    this.descuentoController,
    this.descripcionTipoController,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final tipo = TipoPromocionEnum.fromId(tipoPromocionId);

    if (tipo == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tipo.requiereDescuento) ...[
          _buildLabel('DESCUENTO % *'),
          _buildField(
            controller: descuentoController,
            hint: 'Ej: 20',
            keyboard: TextInputType.number,
            suffix: '%',
          ),
          const SizedBox(height: 14),
        ],
        if (tipo.requiereDescripcion) ...[
          _buildLabel('DESCRIPCIÓN DEL TIPO *'),
          _buildField(
            controller: descripcionTipoController,
            hint: 'Describe el tipo de promoción...',
            maxLines: 2,
          ),
          const SizedBox(height: 14),
        ],
      ],
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
          color: Color(0xFF8A8A9A),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController? controller,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 13),
        suffixText: suffix,
        suffixStyle: const TextStyle(
          color: Color(0xFF8A8A9A),
          fontWeight: FontWeight.w500,
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
          borderSide: const BorderSide(color: Color(0xFFFF5733), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
      ),
    );
  }
}
