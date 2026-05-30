import 'package:flutter/material.dart';
import 'package:app/features/catalog/domain/entities/categoria.dart';

/// Selector de categoría con dropdown que carga datos desde la base de datos.
///
/// Muestra el nombre de la categoría al usuario pero internamente
/// maneja el ID correspondiente.
class CategorySelector extends StatelessWidget {
  final List<Categoria> categorias;
  final int? selectedId;
  final ValueChanged<int?> onChanged;
  final String? label;
  final String? hint;
  final bool isRequired;
  final String? errorText;

  const CategorySelector({
    super.key,
    required this.categorias,
    required this.selectedId,
    required this.onChanged,
    this.label = 'Categoría',
    this.hint = 'Selecciona una categoría',
    this.isRequired = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFFF5733);
    final textDark = const Color(0xFF1A1A2E);
    final textGray = const Color(0xFF8A8A9A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
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
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: errorText != null ? Colors.red : const Color(0xFFEEEEF2),
              width: 1.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<int?>(
                isExpanded: true,
                value: selectedId,
                hint: Text(
                  hint ?? 'Selecciona...',
                  style: TextStyle(
                    color: Colors.grey.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF8A8FA8),
                ),
                borderRadius: BorderRadius.circular(10),
                dropdownColor: Colors.white,
                style: TextStyle(
                  color: textDark,
                  fontSize: 14,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                items: [
                  // Opción placeholder
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      hint ?? 'Selecciona una categoría',
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  // Categorías de la base de datos
                  ...categorias.map((categoria) {
                    return DropdownMenuItem<int?>(
                      value: categoria.id,
                      child: Text(
                        categoria.nombre,
                        style: TextStyle(
                          color: textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }
}

/// Versión con búsqueda para listas largas de categorías
class CategorySelectorWithSearch extends StatefulWidget {
  final List<Categoria> categorias;
  final int? selectedId;
  final ValueChanged<int?> onChanged;
  final String? label;
  final bool isRequired;
  final String? errorText;

  const CategorySelectorWithSearch({
    super.key,
    required this.categorias,
    required this.selectedId,
    required this.onChanged,
    this.label = 'Categoría',
    this.isRequired = true,
    this.errorText,
  });

  @override
  State<CategorySelectorWithSearch> createState() => _CategorySelectorWithSearchState();
}

class _CategorySelectorWithSearchState extends State<CategorySelectorWithSearch> {
  final TextEditingController _searchController = TextEditingController();
  bool _isOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Categoria> get _filteredCategorias {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return widget.categorias;
    return widget.categorias
        .where((c) => c.nombre.toLowerCase().contains(query))
        .toList();
  }

  Categoria? get _selectedCategoria {
    if (widget.selectedId == null) return null;
    try {
      return widget.categorias.firstWhere((c) => c.id == widget.selectedId);
    } catch (e) {
      return null;
    }
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
                Expanded(
                  child: Text(
                    _selectedCategoria?.nombre ?? 'Selecciona una categoría',
                    style: TextStyle(
                      color: _selectedCategoria != null
                          ? textDark
                          : Colors.grey.withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: _selectedCategoria != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Campo de búsqueda
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Buscar categoría...',
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
                // Lista de categorías
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredCategorias.length,
                    itemBuilder: (context, index) {
                      final categoria = _filteredCategorias[index];
                      final isSelected = categoria.id == widget.selectedId;
                      return ListTile(
                        dense: true,
                        title: Text(
                          categoria.nombre,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected ? primaryColor : textDark,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: primaryColor, size: 18)
                            : null,
                        onTap: () {
                          widget.onChanged(categoria.id);
                          setState(() => _isOpen = false);
                        },
                      );
                    },
                  ),
                ),
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
}
