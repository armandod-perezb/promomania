import 'package:flutter/material.dart';
import 'package:app/features/promotions/domain/entities/supermercado.dart';

/// Selector de supermercado con búsqueda y opción para registrar nuevo.
///
/// Muestra: Nombre - Dirección - Ciudad
/// Permite buscar y filtrar supermercados existentes.
class SupermarketSelector extends StatefulWidget {
  final List<Supermercado> supermercados;
  final int? selectedId;
  final ValueChanged<int?> onChanged;
  final ValueChanged<String>? onCreateNew;
  final String? label;
  final bool isRequired;
  final String? errorText;

  const SupermarketSelector({
    super.key,
    required this.supermercados,
    required this.selectedId,
    required this.onChanged,
    this.onCreateNew,
    this.label = 'Supermercado / Tienda',
    this.isRequired = true,
    this.errorText,
  });

  @override
  State<SupermarketSelector> createState() => _SupermarketSelectorState();
}

class _SupermarketSelectorState extends State<SupermarketSelector> {
  final TextEditingController _searchController = TextEditingController();
  bool _isOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Supermercado> get _filteredSupermercados {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return widget.supermercados;
    return widget.supermercados.where((s) {
      final nombre = s.nombre.toLowerCase();
      final direccion = (s.direccion ?? '').toLowerCase();
      final ciudad = (s.ciudad ?? '').toLowerCase();
      return nombre.contains(query) ||
          direccion.contains(query) ||
          ciudad.contains(query);
    }).toList();
  }

  Supermercado? get _selectedSupermercado {
    if (widget.selectedId == null) return null;
    try {
      return widget.supermercados.firstWhere((s) => s.id == widget.selectedId);
    } catch (e) {
      return null;
    }
  }

  String _formatSupermarketDisplay(Supermercado s) {
    final parts = <String>[s.nombre];
    if (s.direccion != null && s.direccion!.isNotEmpty) {
      parts.add(s.direccion!);
    }
    if (s.ciudad != null && s.ciudad!.isNotEmpty) {
      parts.add(s.ciudad!);
    }
    return parts.join(' - ');
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF5733);
    final textDark = const Color(0xFF1A1A2E);
    final textGray = const Color(0xFF8A8A9A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Text(
                  widget.label!.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textGray,
                    letterSpacing: 0.5,
                  ),
                ),
                if (widget.isRequired)
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
        GestureDetector(
          onTap: () {
            setState(() => _isOpen = !_isOpen);
            if (_isOpen) {
              // Limpiar búsqueda al abrir
              _searchController.clear();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.errorText != null
                    ? Colors.red
                    : const Color(0xFFEEEEF2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.store_outlined,
                  color: _selectedSupermercado != null
                      ? primaryColor
                      : Colors.grey.withOpacity(0.5),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedSupermercado != null
                        ? _formatSupermarketDisplay(_selectedSupermercado!)
                        : 'Selecciona un supermercado',
                    style: TextStyle(
                      color: _selectedSupermercado != null
                          ? textDark
                          : Colors.grey.withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: _selectedSupermercado != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF8A8FA8),
                ),
              ],
            ),
          ),
        ),
        if (_isOpen)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEEEEF2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Campo de búsqueda
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre, dirección o ciudad...',
                      hintStyle: TextStyle(
                        color: Colors.grey.withOpacity(0.5),
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF8A8FA8),
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                // Lista de supermercados
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: _filteredSupermercados.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredSupermercados.length,
                          itemBuilder: (context, index) {
                            final supermercado = _filteredSupermercados[index];
                            final isSelected =
                                supermercado.id == widget.selectedId;
                            return _buildSupermarketItem(
                              supermercado: supermercado,
                              isSelected: isSelected,
                              primaryColor: primaryColor,
                              textDark: textDark,
                            );
                          },
                        ),
                ),
                // Botón para crear nuevo
                if (widget.onCreateNew != null) ...[
                  const Divider(height: 1),
                  _buildCreateNewButton(primaryColor),
                ],
              ],
            ),
          ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.store_outlined,
            size: 40,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'No se encontraron supermercados',
            style: TextStyle(
              color: Colors.grey.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupermarketItem({
    required Supermercado supermercado,
    required bool isSelected,
    required Color primaryColor,
    required Color textDark,
  }) {
    return InkWell(
      onTap: () {
        widget.onChanged(supermercado.id);
        setState(() => _isOpen = false);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.05) : null,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withOpacity(0.15)
                    : const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.store,
                color: isSelected ? primaryColor : const Color(0xFF8A8FA8),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supermercado.nombre,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? primaryColor : textDark,
                    ),
                  ),
                  if (supermercado.direccion != null ||
                      supermercado.ciudad != null)
                    Text(
                      [
                        if (supermercado.direccion != null)
                          supermercado.direccion!,
                        if (supermercado.ciudad != null) supermercado.ciudad!,
                      ].where((s) => s.isNotEmpty).join(' - '),
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF8A8FA8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateNewButton(Color primaryColor) {
    return InkWell(
      onTap: () {
        setState(() => _isOpen = false);
        // Pasar el texto de búsqueda como sugerencia inicial
        widget.onCreateNew?.call(_searchController.text.trim());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.03),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Registrar nuevo supermercado',
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
}
